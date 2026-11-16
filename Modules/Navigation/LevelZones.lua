local Private = select(2, ...)

local AreaLevelZones = {}
local AreaNameLabelType = MAP_AREA_LABEL_TYPE.AREA_NAME
local BorderThickness = 2
local LastName = ""
local DrawnArtID, DrawnLevel = 0, 0

local function GetLevelZoneColour(LevelZone)
    return GetQuestDifficultyColor(math.min(math.max(UnitLevel("player"), LevelZone[1]), LevelZone[2]))
end

local function DrawBorder(Pin, Border, Colour, Opacity)
    local Count = #Border
    local LastX, LastY = Border[Count - 1], Border[Count]
    for Index = 1, Count, 2 do
        local X, Y = Border[Index], Border[Index + 1]
        local Line = Private.LevelZonePool:Acquire()
        Line:SetStartPoint("TOPLEFT", Pin, LastX, -LastY)
        Line:SetEndPoint("TOPLEFT", Pin, X, -Y)
        Line:SetThickness(BorderThickness)
        Line:SetColorTexture(Colour.r, Colour.g, Colour.b, Opacity)
        Line:Show()
        LastX, LastY = X, Y
    end
end

local function DrawLevel(Pin, LevelZone, Colour, Opacity, Font, FontSize, FontStyle)
    local Level = Private.LevelZoneTextPool:Acquire()
    Private.E:SetFont(Level, Font, FontSize, FontStyle)
    Level:SetPoint("CENTER", Pin, "TOPLEFT", LevelZone[3], -LevelZone[4])
    Level:SetText(LevelZone.Level)
    Level:SetTextColor(Colour.r, Colour.g, Colour.b, Opacity)
    Level:Show()
end

local function DrawLevelZones(Pin)
    local MapID = Pin:GetMap():GetMapID()
    local ArtID = Private.DB.global.Miscellaneous.Navigation.Enable and not issecretvalue(MapID) and MapID and C_Map.GetMapArtID(MapID) or 0
    local PlayerLevel = UnitLevel("player")
    if ArtID == DrawnArtID and PlayerLevel == DrawnLevel then return end
    DrawnArtID, DrawnLevel = ArtID, PlayerLevel

    Private.LevelZonePool:ReleaseAll()
    Private.LevelZoneTextPool:ReleaseAll()
    wipe(AreaLevelZones)
    LastName = ""

    local LevelZones = Private.LevelZones[ArtID]
    if not LevelZones then return end

    local DB = Private.DB.global.Miscellaneous.Navigation.LevelZones
    local Font, FontStyle = Private:FetchFont(Private.E.db.general.font), Private.E.db.general.fontStyle
    for _, LevelZone in ipairs(LevelZones) do
        local Colour = GetLevelZoneColour(LevelZone)
        for Index = 6, #LevelZone do DrawBorder(Pin, LevelZone[Index], Colour, DB.Opacity) end
        DrawLevel(Pin, LevelZone, Colour, DB.Opacity, Font, DB.FontSize, FontStyle)
        for _, AreaID in ipairs(LevelZone[5]) do
            local Name = C_Map.GetAreaInfo(AreaID)
            if Name then AreaLevelZones[Name] = LevelZone end
        end
    end
end

function Private:CreateLevelZones()
    if not Private.DB.global.Miscellaneous.Navigation.LevelZones.Enable then return end

    for _, Zones in pairs(Private.LevelZones) do
        for _, LevelZone in ipairs(Zones) do
            LevelZone.Level = LevelZone[1] == LevelZone[2] and tostring(LevelZone[1]) or LevelZone[1] .. "-" .. LevelZone[2]
            LevelZone.Text = "(" .. LevelZone.Level .. ")"
        end
    end

    for Pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
        local DrawLayer, SubLevel = Pin.dataProvider:GetDrawLayer()
        Private.LevelZonePool = CreateUnsecuredRegionPoolInstance(nil, function() return Pin:CreateLine(nil, DrawLayer, nil, SubLevel + 2) end)
        Private.LevelZoneTextPool = CreateUnsecuredFontStringPool(Pin, "OVERLAY")
        Private.LevelZonePin = Pin
        hooksecurefunc(Pin, "RefreshOverlays", DrawLevelZones)
    end

    local AreaLabel = Private:GetWorldMapAreaLabel()
    if not AreaLabel then return end

    local LevelText = AreaLabel:CreateFontString(nil, "OVERLAY", "WorldMapTextFont")
    LevelText:SetPoint("TOP", AreaLabel.Name, "BOTTOM", 0, -5)
    LevelText:Hide()

    AreaLabel:HookScript("OnUpdate", function(Label)
        local Name = Label.Name:GetText()
        if Name == LastName then return end
        LastName = Name

        local AreaNameInfo = Label.labelInfoByType[AreaNameLabelType]
        local LevelZone = AreaNameInfo and AreaNameInfo.name == Name and AreaLevelZones[Name]
        if not LevelZone then
            LevelText:Hide()
            return
        end

        local Colour = GetLevelZoneColour(LevelZone)
        LevelText:SetText(LevelZone.Text)
        LevelText:SetTextColor(Colour.r, Colour.g, Colour.b)
        LevelText:Show()
    end)
end

function Private:UpdateLevelZones()
    DrawnArtID = -1
    if Private.LevelZonePin then DrawLevelZones(Private.LevelZonePin) end
end
