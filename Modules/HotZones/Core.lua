local Private = select(2, ...)

local AreaHotZones = {}
local AreaNameLabelType = MAP_AREA_LABEL_TYPE.AREA_NAME
local BorderThickness = 2
local LastName = ""

local function GetHotZoneColour(HotZone)
    return GetQuestDifficultyColor(math.min(math.max(UnitLevel("player"), HotZone[1]), HotZone[2]))
end

local function DrawBorder(Pin, Border, Colour, Opacity)
    local Count = #Border
    local LastX, LastY = Border[Count - 1], Border[Count]
    for Index = 1, Count, 2 do
        local X, Y = Border[Index], Border[Index + 1]
        local Line = Private.HotZonePool:Acquire()
        Line:SetStartPoint("TOPLEFT", Pin, LastX, -LastY)
        Line:SetEndPoint("TOPLEFT", Pin, X, -Y)
        Line:SetThickness(BorderThickness)
        Line:SetColorTexture(Colour.r, Colour.g, Colour.b, Opacity)
        Line:Show()
        LastX, LastY = X, Y
    end
end

local function DrawLevel(Pin, HotZone, Colour, Opacity, Font, FontSize, FontStyle)
    local Level = Private.HotZoneLevelPool:Acquire()
    Private.E:SetFont(Level, Font, FontSize, FontStyle)
    Level:SetPoint("CENTER", Pin, "TOPLEFT", HotZone[3], -HotZone[4])
    Level:SetText(HotZone.Level)
    Level:SetTextColor(Colour.r, Colour.g, Colour.b, Opacity)
    Level:Show()
end

local function DrawHotZones(Pin)
    Private.HotZonePool:ReleaseAll()
    Private.HotZoneLevelPool:ReleaseAll()
    wipe(AreaHotZones)
    LastName = ""

    local MapID = Pin:GetMap():GetMapID()
    if not MapID or issecretvalue(MapID) then return end
    local HotZones = Private.HotZones[C_Map.GetMapArtID(MapID)]
    if not HotZones then return end

    local DB = Private.DB.global.HotZones
    local Font, FontStyle = Private:FetchFont(Private.E.db.general.font), Private.E.db.general.fontStyle
    for _, HotZone in ipairs(HotZones) do
        local Colour = GetHotZoneColour(HotZone)
        for Index = 6, #HotZone do DrawBorder(Pin, HotZone[Index], Colour, DB.Opacity) end
        DrawLevel(Pin, HotZone, Colour, DB.Opacity, Font, DB.FontSize, FontStyle)
        for _, AreaID in ipairs(HotZone[5]) do
            local Name = C_Map.GetAreaInfo(AreaID)
            if Name then AreaHotZones[Name] = HotZone end
        end
    end
end

function Private:SetupHotZones()
    if not Private.DB.global.HotZones.Enable then return end

    for _, Zones in pairs(Private.HotZones) do
        for _, HotZone in ipairs(Zones) do
            HotZone.Level = HotZone[1] == HotZone[2] and tostring(HotZone[1]) or HotZone[1] .. " - " .. HotZone[2]
            HotZone.Text = "(" .. HotZone.Level .. ")"
        end
    end

    for Pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
        local DrawLayer, SubLevel = Pin.dataProvider:GetDrawLayer()
        Private.HotZonePool = CreateUnsecuredRegionPoolInstance(nil, function() return Pin:CreateLine(nil, DrawLayer, nil, SubLevel + 2) end)
        Private.HotZoneLevelPool = CreateUnsecuredFontStringPool(Pin, "OVERLAY")
        Private.HotZonePin = Pin
        hooksecurefunc(Pin, "RefreshOverlays", DrawHotZones)
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
        local HotZone = AreaNameInfo and AreaNameInfo.name == Name and AreaHotZones[Name]
        if not HotZone then
            LevelText:Hide()
            return
        end

        local Colour = GetHotZoneColour(HotZone)
        LevelText:SetText(HotZone.Text)
        LevelText:SetTextColor(Colour.r, Colour.g, Colour.b)
        LevelText:Show()
    end)
end

function Private:UpdateHotZones()
    if Private.HotZonePin then DrawHotZones(Private.HotZonePin) end
end
