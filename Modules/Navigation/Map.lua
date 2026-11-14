local Private = select(2, ...)

local KnownFlightTexture = "Interface\\TaxiFrame\\UI-Taxi-Icon-Green"
local UnknownFlightTexture = "Interface\\TaxiFrame\\UI-Taxi-Icon-White"
local MapFlightSize = 16

local MapVector = CreateVector2D(0, 0)

local function GetMapPosition(MapID, Continent, X, Y)
    MapVector:SetXY(X, Y)
    local _, Position = C_Map.GetMapPosFromWorldPos(Continent, MapVector, MapID)
    if not Position then return end
    return Position:GetXY()
end

function Private:DrawNavigationMap()
    local Pool = Private.NavigationMapIcons
    Pool:ReleaseAll()

    local DB = Private.DB.global.Miscellaneous.Navigation
    if not DB.Enable or not DB.FlightPaths or not WorldMapFrame:IsShown() then return end
    local MapID = WorldMapFrame:GetMapID()
    if not MapID or C_Map.GetMapInfo(MapID).mapType < Enum.UIMapType.Continent then return end

    local Overlay = Private.NavigationMapOverlay
    local Canvas = WorldMapFrame:GetCanvas()
    local Width, Height = Canvas:GetWidth(), Canvas:GetHeight()
    local FlightSize = MapFlightSize / Canvas:GetScale()
    local Faction = UnitFactionGroup("player") == "Horde" and 2 or 1
    local KnownTaxiNodes = Private.DB.char.Navigation.KnownTaxiNodes
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

local function ResizeNavigationMap()
    local FlightSize = MapFlightSize / WorldMapFrame:GetCanvas():GetScale()
    for Icon in Private.NavigationMapIcons:EnumerateActive() do Icon:SetSize(FlightSize, FlightSize) end
end

function Private:CreateNavigationMap()
    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_WAYPOINT_LOCATION"))
    Private.NavigationMapOverlay = Overlay
    Private.NavigationMapIcons = CreateUnsecuredTexturePool(Overlay, "OVERLAY")

    hooksecurefunc(WorldMapFrame, "OnMapChanged", Private.DrawNavigationMap)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeNavigationMap)
    WorldMapFrame:HookScript("OnShow", Private.DrawNavigationMap)
end
