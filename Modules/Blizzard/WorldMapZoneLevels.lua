local Private = select(2, ...)

local ZoneLevels = {
    -- Eastern Kingdoms
    ["Dun Morogh"] = {1, 12},
    ["Elwynn Forest"] = {1, 10},
    ["Tirisfal Glades"] = {1, 12},
    ["Westfall"] = {9, 18},
    ["Loch Modan"] = {10, 18},
    ["Silverpine Forest"] = {10, 20},
    ["Redridge Mountains"] = {15, 25},
    ["Duskwood"] = {19, 30},
    ["Hillsbrad Foothills"] = {20, 31},
    ["Wetlands"] = {20, 30},
    ["Alterac Mountains"] = {27, 39},
    ["Arathi Highlands"] = {30, 40},
    ["Stranglethorn Vale"] = {30, 44},
    ["Badlands"] = {36, 45},
    ["Riverglades"] = {36, 44},
    ["Swamp of Sorrows"] = {36, 43},
    ["The Hinterlands"] = {41, 49},
    ["Searing Gorge"] = {43, 48},
    ["Blasted Lands"] = {46, 55},
    ["Western Plaguelands"] = {46, 57},
    ["Burning Steppes"] = {50, 59},
    ["Deadwind Pass"] = {50, 60},
    ["Eastern Plaguelands"] = {54, 59},
    -- Kalimdor
    ["Durotar"] = {1, 10},
    ["Mulgore"] = {1, 10},
    ["Teldrassil"] = {1, 11},
    ["The Barrens"] = {10, 25},
    ["Darkshore"] = {11, 19},
    ["Stonetalon Mountains"] = {15, 25},
    ["Ashenvale"] = {19, 30},
    ["Thousand Needles"] = {24, 35},
    ["Desolace"] = {30, 39},
    ["Dustwallow Marsh"] = {36, 43},
    ["Tanaris"] = {40, 50},
    ["Feralas"] = {41, 60},
    ["Azshara"] = {42, 55},
    ["Felwood"] = {47, 54},
    ["Un'Goro Crater"] = {48, 55},
    ["Silithus"] = {55, 59},
    ["Winterspring"] = {55, 60},
}

local function GetAreaLabel()
    for DataProvider in pairs(WorldMapFrame.dataProviders) do
        if DataProvider.OnSetAreaLabel == AreaLabelDataProviderMixin.OnSetAreaLabel then return DataProvider.Label end
    end
end

local function GetLevelColour(MinLevel, MaxLevel)
    local PlayerLevel = UnitLevel("player")
    if PlayerLevel < MinLevel then return GetQuestDifficultyColor(MinLevel) end
    if PlayerLevel > MaxLevel then return GetQuestDifficultyColor(MaxLevel - 2) end
    return QuestDifficultyColors["difficult"]
end

function Private:SetupWorldMapZoneLevels()
    if not Private.DB.global.Blizzard.WorldMapZoneLevels then return end

    local AreaLabel = GetAreaLabel()
    if not AreaLabel then return end

    for _, Levels in pairs(ZoneLevels) do
        Levels.Text = "(" .. Levels[1] .. " - " .. Levels[2] .. ")"
    end

    local LevelText = AreaLabel:CreateFontString(nil, "OVERLAY", "WorldMapTextFont")
    LevelText:SetPoint("TOP", AreaLabel.Name, "BOTTOM", 0, -5)
    LevelText:Hide()

    local AreaNameLabelType = MAP_AREA_LABEL_TYPE.AREA_NAME
    local LastName = ""

    AreaLabel:HookScript("OnUpdate", function(Label)
        local Name = Label.Name:GetText()
        if Name == LastName then return end
        LastName = Name

        local AreaNameInfo = Label.labelInfoByType[AreaNameLabelType]
        local Levels = AreaNameInfo and AreaNameInfo.name == Name and ZoneLevels[Name]
        if not Levels then
            LevelText:Hide()
            return
        end

        local Colour = GetLevelColour(Levels[1], Levels[2])
        LevelText:SetText(Levels.Text)
        LevelText:SetTextColor(Colour.r, Colour.g, Colour.b)
        LevelText:Show()
    end)
end
