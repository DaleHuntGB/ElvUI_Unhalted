local Private = select(2, ...)

local KnownFlightTexture = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green"
local UnknownFlightTexture = "Interface\\TaxiFrame\\UI-Taxi-Icon-White"

-- World map dots and flight path icons, in screen pixels.
local MapDotSize, MapDotSpacing, MapFlightSize = 7, 14, 16
-- Minimap dots: the line holds this many, spaced this many to the minimap's radius.
local MinimapDotCount, MinimapDotsPerRadius, MinimapDotSize = 10, 6, 6

local MapVector = CreateVector2D(0, 0)
local MinimapDots = {}
-- The world map's size and the dot look, set once per draw for DrawMapDots.
local MapLine = { Width = 0, Height = 0, Size = 0, Spacing = 0, Texture = "" }

local function GetMapPosition(MapID, Continent, X, Y)
    MapVector:SetXY(X, Y)
    local _, Position = C_Map.GetMapPosFromWorldPos(Continent, MapVector, MapID)
    if not Position then return end
    return Position:GetXY()
end

-- Dots along a straight run, in map fractions. Offset is how far into the run the next dot falls; what is left over
-- is returned for the run after it, so a line that turns keeps its spacing.
local function DrawMapDots(FromX, FromY, ToX, ToY, Offset)
    if not FromX or not ToX then return 0 end
    local DeltaX, DeltaY = ToX - FromX, ToY - FromY
    local Length = math.sqrt((DeltaX * MapLine.Width) ^ 2 + (DeltaY * MapLine.Height) ^ 2)
    local Overlay, Colour = Private.NavigationMapOverlay, Private.E.db.general.valuecolor

    while Offset <= Length do
        local Along = Length > 0 and Offset / Length or 0
        local X, Y = FromX + DeltaX * Along, FromY + DeltaY * Along
        if X >= 0 and X <= 1 and Y >= 0 and Y <= 1 then
            local Dot = Private.NavigationMapDots:Acquire()
            Dot:SetTexture(MapLine.Texture)
            Dot:SetSize(MapLine.Size, MapLine.Size)
            Dot:SetVertexColor(Colour.r, Colour.g, Colour.b, 1)
            Dot:SetPoint("CENTER", Overlay, "TOPLEFT", X * MapLine.Width, -Y * MapLine.Height)
            Dot:Show()
        end
        Offset = Offset + MapLine.Spacing
    end
    return Offset - Length
end

-- Dots from (FromX, FromY) on the map through Turns, world X, Y pairs; returns where they end and the next offset.
local function DrawMapTurns(MapID, Continent, FromX, FromY, Turns, Offset)
    for Index = 1, #Turns, 2 do
        local X, Y = GetMapPosition(MapID, Continent, Turns[Index], Turns[Index + 1])
        Offset = DrawMapDots(FromX, FromY, X, Y, Offset)
        FromX, FromY = X, Y
    end
    return FromX, FromY, Offset
end

-- Draws the faction's flight paths and the route's dotted line on the world map.
function Private:DrawNavigationMap()
    local Pool = Private.NavigationMapDots
    Pool:ReleaseAll()

    local DB = Private.DB.global.Miscellaneous.Navigation
    if not DB.Enable or not WorldMapFrame:IsShown() then return end
    local MapID = WorldMapFrame:GetMapID()
    if not MapID then return end

    local Overlay = Private.NavigationMapOverlay
    local Canvas = WorldMapFrame:GetCanvas()
    local Width, Height, Scale = Canvas:GetWidth(), Canvas:GetHeight(), Canvas:GetScale()

    -- The whole-world map is too small to hold every flight path.
    if DB.FlightPaths and C_Map.GetMapInfo(MapID).mapType >= Enum.UIMapType.Continent then
        local Faction = UnitFactionGroup("player") == "Horde" and 2 or 1
        local KnownTaxiNodes = Private.DB.char.Navigation.KnownTaxiNodes
        local FlightSize = MapFlightSize / Scale
        for TaxiNodeID, TaxiNode in pairs(Private.NavigationTaxiNodes) do
            local X, Y = GetMapPosition(MapID, TaxiNode[1], TaxiNode[2], TaxiNode[3])
            if X and bit.band(TaxiNode[5], Faction) ~= 0 and X >= 0 and X <= 1 and Y >= 0 and Y <= 1 then
                local isKnown = KnownTaxiNodes[TaxiNodeID]
                local Icon = Pool:Acquire()
                Icon:SetTexture(isKnown and KnownFlightTexture or UnknownFlightTexture)
                Icon:SetSize(FlightSize, FlightSize)
                Icon:SetVertexColor(1, 1, 1, isKnown and 1 or 0.6)
                Icon:SetPoint("CENTER", Overlay, "TOPLEFT", X * Width, -Y * Height)
                Icon:Show()
            end
        end
    end

    local Route = Private.NavigationRoute
    if not Route or not DB.WorldMapLine then return end
    MapLine.Width, MapLine.Height = Width, Height
    MapLine.Size, MapLine.Spacing = MapDotSize / Scale, MapDotSpacing / Scale
    MapLine.Texture = Private.NavigationDots[DB.DotTexture].Path

    for _, Leg in ipairs(Route) do
        local Points, Offset = Leg.Points, 0
        if Leg.Path then
            -- A walk follows its path along the roads.
            local From = Points[1]
            local FromX, FromY = GetMapPosition(MapID, From[1], From[2], From[3])
            DrawMapTurns(MapID, From[1], FromX, FromY, Leg.Path, Offset)
        else
            for Index = 1, #Points - 1 do
                local From, To = Points[Index], Points[Index + 1]
                local Continent = From[1]
                -- A leg that crosses continents, or lies off this map's continent, has no line to draw.
                if Continent == To[1] then
                    local FromX, FromY = GetMapPosition(MapID, Continent, From[2], From[3])
                    -- A flight follows its path's turns rather than flying straight between flight masters.
                    local Turns = Leg.Mode == "Flight Path" and Private.NavigationFlightRoutes[From.TaxiNodeID][To.TaxiNodeID]
                    if Turns then FromX, FromY, Offset = DrawMapTurns(MapID, Continent, FromX, FromY, Turns, Offset) end
                    local ToX, ToY = GetMapPosition(MapID, Continent, To[2], To[3])
                    Offset = DrawMapDots(FromX, FromY, ToX, ToY, Offset)
                end
            end
        end
    end
end

-- Applies the chosen dot texture to both lines.
function Private:UpdateNavigationLines()
    local DotTexture = Private.NavigationDots[Private.DB.global.Miscellaneous.Navigation.DotTexture].Path
    for _, Dot in ipairs(MinimapDots) do Dot:SetTexture(DotTexture) end
    Private:DrawNavigationMap()
end

function Private:HideNavigationMinimapLine()
    for _, Dot in ipairs(MinimapDots) do Dot:Hide() end
end

-- Dots from the player at (X, Y) along Path, an X, Y list whose turn at Index is next and Distance yards from its end.
-- Facing is the way the minimap's top points.
function Private:UpdateNavigationMinimapLine(X, Y, Path, Index, Distance, Facing)
    local Radius = C_Minimap.GetViewRadius()
    local HalfWidth, HalfHeight = Minimap:GetWidth() / 2, Minimap:GetHeight() / 2
    local PixelsPerYard = HalfWidth / Radius
    local Sin, Cos = math.sin(Facing) * PixelsPerYard, math.cos(Facing) * PixelsPerYard
    local Spacing = Radius / MinimapDotsPerRadius
    -- Measured from the end, so the dots stay put on the ground while the player moves.
    local Along = Distance % Spacing

    local FromX, FromY, ToX, ToY = X, Y, Path[Index], Path[Index + 1]
    local Start, Length = 0, math.sqrt((ToX - X) ^ 2 + (ToY - Y) ^ 2)
    for _, Dot in ipairs(MinimapDots) do
        Along = Along + Spacing
        while Along > Start + Length and Index < #Path - 1 do
            Index, Start = Index + 2, Start + Length
            FromX, FromY, ToX, ToY = ToX, ToY, Path[Index], Path[Index + 1]
            Length = math.sqrt((ToX - FromX) ^ 2 + (ToY - FromY) ^ 2)
        end
        local isOnPath = Along <= Start + Length
        local Share = Length > 0 and (Along - Start) / Length or 0
        -- The dot's yards north and west of the player, turned to the minimap.
        local North, West = FromX + (ToX - FromX) * Share - X, FromY + (ToY - FromY) * Share - Y
        local DotX, DotY = North * Sin - West * Cos, North * Cos + West * Sin
        if isOnPath and math.abs(DotX) < HalfWidth - MinimapDotSize and math.abs(DotY) < HalfHeight - MinimapDotSize then
            Dot:SetPoint("CENTER", Minimap, "CENTER", DotX, DotY)
            Dot:Show()
        else
            Dot:Hide()
        end
    end
end

function Private:CreateNavigationLines()
    local Colour = Private.E.db.general.valuecolor
    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_WAYPOINT_LOCATION"))
    Private.NavigationMapOverlay = Overlay
    Private.NavigationMapDots = CreateUnsecuredTexturePool(Overlay, "OVERLAY")

    hooksecurefunc(WorldMapFrame, "OnMapChanged", Private.DrawNavigationMap)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", Private.DrawNavigationMap)
    WorldMapFrame:HookScript("OnShow", Private.DrawNavigationMap)

    for Index = 1, MinimapDotCount do
        local Dot = Minimap:CreateTexture(nil, "OVERLAY")
        Dot:SetSize(MinimapDotSize, MinimapDotSize)
        Dot:SetVertexColor(Colour.r, Colour.g, Colour.b)
        Dot:Hide()
        MinimapDots[Index] = Dot
    end
    Private:UpdateNavigationLines()
end
