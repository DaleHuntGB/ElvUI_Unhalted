local Private = select(2, ...)

local AreaLevelZones = {}
local AreaNameLabelType = MAP_AREA_LABEL_TYPE.AREA_NAME
local BorderThickness = 2
local GapDistance, SampleSpread, MinSamples = 6, 6, 5
local MaxCreatureLevel, MaxLevelSpan = 63, 8
local CritterFactions = { [31] = true, [188] = true, [190] = true }

local QuestieDB = Private:GetQuestieDB()
local LastName = ""
local DrawnArtID, DrawnLevel = 0, 0

local function GetLevelZoneColour(LevelZone)
    return GetQuestDifficultyColor(math.min(math.max(UnitLevel("player"), LevelZone.MinLevel), LevelZone.MaxLevel))
end

local function FindLevelZone(Zones, X, Y)
    for _, LevelZone in ipairs(Zones) do
        local Bounds = LevelZone.Bounds
        if X >= Bounds[1] and X <= Bounds[3] and Y >= Bounds[2] and Y <= Bounds[4] then
            local isInside = false
            for Ring = 4, #LevelZone do
                local Border = LevelZone[Ring]
                local Count = #Border
                local LastX, LastY = Border[Count - 1], Border[Count]
                for Index = 1, Count, 2 do
                    local PointX, PointY = Border[Index], Border[Index + 1]
                    if (PointY > Y) ~= (LastY > Y) and X < (LastX - PointX) * (Y - PointY) / (LastY - PointY) + PointX then isInside = not isInside end
                    LastX, LastY = PointX, PointY
                end
            end
            if isInside then return LevelZone end
        end
    end

    local Nearest, NearestDistance = 0, GapDistance * GapDistance
    for ZoneIndex, LevelZone in ipairs(Zones) do
        local Bounds = LevelZone.Bounds
        if X >= Bounds[1] - GapDistance and X <= Bounds[3] + GapDistance and Y >= Bounds[2] - GapDistance and Y <= Bounds[4] + GapDistance then
            for Ring = 4, #LevelZone do
                local Border = LevelZone[Ring]
                local Count = #Border
                local LastX, LastY = Border[Count - 1], Border[Count]
                for Index = 1, Count, 2 do
                    local PointX, PointY = Border[Index], Border[Index + 1]
                    local EdgeX, EdgeY = PointX - LastX, PointY - LastY
                    local Length = EdgeX * EdgeX + EdgeY * EdgeY
                    local Along = Length > 0 and math.min(math.max(((X - LastX) * EdgeX + (Y - LastY) * EdgeY) / Length, 0), 1) or 0
                    local DeltaX, DeltaY = X - LastX - Along * EdgeX, Y - LastY - Along * EdgeY
                    local Distance = DeltaX * DeltaX + DeltaY * DeltaY
                    if Distance <= NearestDistance then Nearest, NearestDistance = ZoneIndex, Distance end
                    LastX, LastY = PointX, PointY
                end
            end
        end
    end
    return Zones[Nearest]
end

local function DrawLevelZones(Pin)
    local MapID = Pin:GetMap():GetMapID()
    local ArtID = Private.DB.global.Miscellaneous.Navigation.Enable and not Private:IsSecret(MapID) and MapID and C_Map.GetMapArtID(MapID) or 0
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
        if LevelZone.Level then
            local Colour = GetLevelZoneColour(LevelZone)
            for Ring = 4, #LevelZone do
                local Border = LevelZone[Ring]
                local Count = #Border
                local LastX, LastY = Border[Count - 1], Border[Count]
                for Index = 1, Count, 2 do
                    local X, Y = Border[Index], Border[Index + 1]
                    local Line = Private.LevelZonePool:Acquire()
                    Line:SetStartPoint("TOPLEFT", Pin, LastX, -LastY)
                    Line:SetEndPoint("TOPLEFT", Pin, X, -Y)
                    Line:SetThickness(BorderThickness)
                    Line:SetColorTexture(Colour.r, Colour.g, Colour.b, DB.Opacity)
                    Line:Show()
                    LastX, LastY = X, Y
                end
            end

            local Level = Private.LevelZoneTextPool:Acquire()
            Private.E:SetFont(Level, Font, DB.FontSize, FontStyle)
            Level:SetPoint("CENTER", Pin, "TOPLEFT", LevelZone[1], -LevelZone[2])
            Level:SetText(LevelZone.Level)
            Level:SetTextColor(Colour.r, Colour.g, Colour.b, DB.Opacity)
            Level:Show()

            for _, AreaID in ipairs(LevelZone[3]) do
                local Name = C_Map.GetAreaInfo(AreaID)
                if Name then AreaLevelZones[Name] = LevelZone end
            end
        end
    end
end

local function BuildLevelRanges()
    local Npc = QuestieDB.Npc
    local Samples, ArtIDs = {}, {}
    for _, Zones in pairs(Private.LevelZones) do
        for _, LevelZone in ipairs(Zones) do
            local MinX, MinY, MaxX, MaxY = math.huge, math.huge, -math.huge, -math.huge
            for Ring = 4, #LevelZone do
                local Border = LevelZone[Ring]
                for Index = 1, #Border, 2 do
                    MinX, MaxX = math.min(MinX, Border[Index]), math.max(MaxX, Border[Index])
                    MinY, MaxY = math.min(MinY, Border[Index + 1]), math.max(MaxY, Border[Index + 1])
                end
            end
            LevelZone.Bounds = { MinX, MinY, MaxX, MaxY }
            Samples[LevelZone] = {}
        end
        coroutine.yield()
    end

    for _, NpcID in ipairs(Npc.GetAllIds()) do
        local MinLevel, MaxLevel, FactionID = Npc.minLevel(NpcID), Npc.maxLevel(NpcID), Npc.factionID(NpcID)
        if (Npc.friendlyToFaction(NpcID) or "") == "" and Npc.npcFlags(NpcID) == 0 and Npc.rank(NpcID) <= 1 and MaxLevel <= MaxCreatureLevel and MaxLevel - MinLevel <= MaxLevelSpan and not CritterFactions[FactionID] and not (MinLevel == 1 and MaxLevel == 1 and FactionID == 0) then
            local Spawns = Npc.spawns(NpcID)
            if Spawns then
                for MapID, Points in pairs(Private:GetQuestieSpawnPoints(Spawns)) do
                    local ArtID = ArtIDs[MapID] or C_Map.GetMapArtID(MapID) or 0
                    ArtIDs[MapID] = ArtID
                    local Zones = Private.LevelZones[ArtID]
                    if Zones then
                        for Point = 1, #Points, 2 do
                            local LevelZone = FindLevelZone(Zones, Points[Point] * 10.02, Points[Point + 1] * 6.68)
                            if LevelZone then
                                local Levels = Samples[LevelZone]
                                Levels[#Levels + 1] = MinLevel
                                Levels[#Levels + 1] = MaxLevel
                            end
                        end
                    end
                end
            end
        end
        coroutine.yield()
    end

    for LevelZone, Levels in pairs(Samples) do
        if #Levels >= MinSamples * 2 then
            local Middles = {}
            for Index = 1, #Levels, 2 do Middles[#Middles + 1] = (Levels[Index] + Levels[Index + 1]) / 2 end
            table.sort(Middles)
            local Half = #Middles / 2
            local Median = (Middles[math.floor(Half + 0.5)] + Middles[math.ceil(Half + 0.5)]) / 2
            local Lows, Highs = {}, {}
            for Index = 1, #Levels, 2 do
                if math.abs((Levels[Index] + Levels[Index + 1]) / 2 - Median) <= SampleSpread then
                    Lows[#Lows + 1], Highs[#Highs + 1] = Levels[Index], Levels[Index + 1]
                end
            end
            if #Lows >= MinSamples then
                table.sort(Lows)
                table.sort(Highs)
                local Low, High = Lows[math.floor((#Lows - 1) * 0.25 + 0.5) + 1], Highs[math.floor((#Highs - 1) * 0.75 + 0.5) + 1]
                LevelZone.MinLevel, LevelZone.MaxLevel = Low, High
                LevelZone.Level = Low == High and tostring(Low) or Low .. "-" .. High
                LevelZone.Text = "(" .. LevelZone.Level .. ")"
            end
        end
        coroutine.yield()
    end

    Private:UpdateLevelZones()
end

function Private:SetupLevelZones()
    if not Private.DB.global.Miscellaneous.Navigation.LevelZones.Enable or not QuestieDB then return end

    Private.LevelZones = Private:UnpackData("LevelZones")
    Private:QueueQuestieJob(BuildLevelRanges)

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
