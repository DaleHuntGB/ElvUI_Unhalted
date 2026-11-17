local Private = select(2, ...)

local IconAtlas, RepeatableIconAtlas = "QuestNormal", "QuestDaily"
local RefreshDelay = 0.2
local HubRadius = 1.5
local UndiscoveredStandings = { [87] = -36000, [576] = -36000, [910] = -36000 }
local ExcludedSorts = { [-1000] = true, [-641] = true, [-644] = true, [-404] = true, [-402] = true, [-378] = true, [-376] = true, [-375] = true, [-374] = true, [-370] = true, [-369] = true, [-368] = true, [-366] = true, [-365] = true, [-364] = true, [-41] = true, [-22] = true, [-21] = true }
local RefreshEvents = { "QUEST_LOG_UPDATE", "PLAYER_LEVEL_UP", "SKILL_LINES_CHANGED", "UPDATE_FACTION" }

local QuestieDB = Private:GetQuestieDB()
local Player = { Level = 0, TrivialRange = 0 }
local Quests, Givers, ZoneMaps = {}, {}, {}
local Available, Skills = {}, {}
local isRefreshQueued = false

local function HasBit(Mask, Bit)
    return Mask == 0 or Mask % (Bit * 2) >= Bit
end

local function IsDone(QuestID)
    return C_QuestLog.IsQuestFlaggedCompleted(QuestID)
end

local function IsTaken(QuestID)
    return IsDone(QuestID) or C_QuestLog.IsOnQuest(QuestID)
end

local function AnyDone(QuestIDs)
    for _, QuestID in ipairs(QuestIDs) do
        if IsDone(QuestID) then return true end
    end
    return false
end

local function AnyTaken(QuestIDs)
    for _, QuestID in ipairs(QuestIDs) do
        if IsTaken(QuestID) then return true end
    end
    return false
end

local function AnyOnQuest(QuestIDs)
    for _, QuestID in ipairs(QuestIDs) do
        if C_QuestLog.IsOnQuest(QuestID) then return true end
    end
    return false
end

local function GroupDone(Group)
    for _, Entry in ipairs(Group) do
        if type(Entry) == "table" then
            if not AnyDone(Entry) then return false end
        elseif not IsDone(Entry) then
            return false
        end
    end
    return true
end

local function GetStanding(FactionID)
    local FactionData = C_Reputation.GetFactionDataByID(FactionID)
    if FactionData then return FactionData.currentStanding end
    return UndiscoveredStandings[FactionID] or 0
end

local function HasSkill(Skill)
    return (Skills[Skill[1]] or 0) >= Skill[2]
end

local function HasAnySkill(Ranks)
    for _, Skill in ipairs(Ranks) do
        if HasSkill(Skill) then return true end
    end
    return false
end

local function GetQuestLevel(Quest)
    return Quest[1] > 0 and Quest[1] or Player.Level
end

local function CheckQuest(QuestID)
    local Quest = Quests[QuestID]
    if (Quest[2] > 0 and Quest[2] or GetQuestLevel(Quest)) > Player.Level then return false end
    if Player.Level - GetQuestLevel(Quest) > Player.TrivialRange then return false end
    if IsTaken(QuestID) or C_QuestLog.IsQuestDisabledForSession(QuestID) then return false end

    local Requirements = Quest[3]
    if not Requirements then return true end
    if Requirements.MaxLevel and Player.Level > Requirements.MaxLevel then return false end
    if Requirements.Single and not AnyDone(Requirements.Single) then return false end
    if Requirements.Group and not GroupDone(Requirements.Group) then return false end
    if Requirements.Exclusive and AnyTaken(Requirements.Exclusive) then return false end
    if Requirements.Next and IsTaken(Requirements.Next) then return false end
    if Requirements.BreadcrumbFor and IsTaken(Requirements.BreadcrumbFor) then return false end
    if Requirements.Breadcrumbs and AnyOnQuest(Requirements.Breadcrumbs) then return false end
    if Requirements.Parent and not C_QuestLog.IsOnQuest(Requirements.Parent) then return false end
    if Requirements.DisabledBy and C_QuestLog.IsOnQuest(Requirements.DisabledBy) then return false end
    if Requirements.UntilDone and IsDone(Requirements.UntilDone) then return false end
    if Requirements.StartingWith and not IsTaken(Requirements.StartingWith) then return false end
    if Requirements.Spell and C_SpellBook.IsSpellKnown(math.abs(Requirements.Spell)) ~= (Requirements.Spell > 0) then return false end
    if Requirements.Skill and not HasSkill(Requirements.Skill) then return false end
    if Requirements.Ranks and not HasAnySkill(Requirements.Ranks) then return false end
    if Requirements.MinRep and GetStanding(Requirements.MinRep[1]) < Requirements.MinRep[2] then return false end
    if Requirements.MaxRep and GetStanding(Requirements.MaxRep[1]) >= Requirements.MaxRep[2] then return false end
    return true
end

local function IsAvailable(QuestID)
    local isAvailable = Available[QuestID]
    if isAvailable == nil then
        isAvailable = CheckQuest(QuestID)
        Available[QuestID] = isAvailable
    end
    return isAvailable
end

local function AddSkills(...)
    for Slot = 1, select("#", ...) do
        local Index = select(Slot, ...)
        if Index then
            local _, _, Rank, _, _, _, SkillLine = GetProfessionInfo(Index)
            Skills[SkillLine] = Rank
        end
    end
end

local function GetHubIcon(Hub)
    local isRepeatableOnly = false
    for Index = 3, #Hub do
        local QuestID = Hub[Index]
        if type(QuestID) == "number" and IsAvailable(QuestID) then
            local Requirements = Quests[QuestID][3]
            if not (Requirements and Requirements.Repeatable) then return IconAtlas end
            isRepeatableOnly = true
        end
    end
    return isRepeatableOnly and RepeatableIconAtlas
end

local function FindHub(Hubs, X, Y)
    for _, Hub in ipairs(Hubs) do
        local DeltaX, DeltaY = Hub[1] * 100 - X, Hub[2] * 100 - Y
        if DeltaX * DeltaX + DeltaY * DeltaY <= HubRadius * HubRadius then return Hub end
    end
end

local function QuestIcon_OnEnter(Icon)
    GameTooltip:SetOwner(Icon, "ANCHOR_RIGHT")
    local Hub = Icon.Hub
    local GiverName, hasLines = "", false
    for Index = 3, #Hub do
        local Value = Hub[Index]
        if type(Value) == "string" then
            GiverName = Value
        elseif IsAvailable(Value) then
            if GiverName ~= "" then
                if hasLines then GameTooltip_AddBlankLineToTooltip(GameTooltip) end
                GameTooltip:AddLine(GiverName, NORMAL_FONT_COLOR:GetRGB())
                GiverName, hasLines = "", true
            end
            local Level = GetQuestLevel(Quests[Value])
            local Colour = GetQuestDifficultyColor(Level)
            if Colour == QuestDifficultyColors.trivial then Colour = QuestDifficultyColors.standard end
            GameTooltip:AddLine("[" .. Level .. "] " .. QuestieDB.Quest.name(Value), Colour.r, Colour.g, Colour.b)
            local Objectives = QuestieDB.Quest.objectivesText(Value)
            if Objectives then GameTooltip:AddLine(table.concat(Objectives, " "), 1, 1, 1, true) end
        end
    end
    GameTooltip:Show()
end

local function GetIconSize()
    return Private.DB.global.Miscellaneous.Navigation.AvailableQuests.IconSize / WorldMapFrame:GetCanvas():GetScale()
end

local function DrawAvailableQuests()
    local Pool = Private.AvailableQuestIcons
    Pool:ReleaseAll()
    if not Private.DB.global.Miscellaneous.Navigation.Enable or not WorldMapFrame:IsShown() then return end

    local MapID = WorldMapFrame:GetMapID()
    local Hubs = MapID and Givers[MapID]
    if not Hubs then return end

    Player.Level = UnitLevel("player")
    Player.TrivialRange = C_QuestLog.GetTrivialRange()
    wipe(Available)
    wipe(Skills)
    AddSkills(GetProfessions())
    local Overlay = Private.AvailableQuestOverlay
    local Width, Height = Overlay:GetWidth(), Overlay:GetHeight()
    local IconSize = GetIconSize()
    for _, Hub in ipairs(Hubs) do
        local Atlas = GetHubIcon(Hub)
        if Atlas then
            local Icon = Pool:Acquire()
            if not Icon.Texture then
                Icon.Texture = Icon:CreateTexture(nil, "OVERLAY")
                Icon.Texture:SetAllPoints(Icon)
                Icon:EnableMouseMotion(true)
                Icon:SetScript("OnEnter", QuestIcon_OnEnter)
                Icon:SetScript("OnLeave", GameTooltip_Hide)
            end
            Icon.Hub = Hub
            Icon.Texture:SetAtlas(Atlas)
            Icon:SetSize(IconSize, IconSize)
            Icon:SetPoint("CENTER", Overlay, "TOPLEFT", Hub[1] * Width, -Hub[2] * Height)
            Icon:Show()
        end
    end
end

local function BuildAvailableQuests()
    local Quest = QuestieDB.Quest
    local _, _, RaceID = UnitRace("player")
    local _, _, ClassID = UnitClass("player")
    local RaceBit, ClassBit = QuestieDB.Enum.raceMaskById[RaceID], 2 ^ (ClassID - 1)
    local GiverQuests, GiverOrder = {}, {}

    for _, QuestID in ipairs(Quest.GetAllIds()) do
        if not Private.HiddenQuests[QuestID] and HasBit(Quest.requiredRaces(QuestID), RaceBit) and HasBit(Quest.requiredClasses(QuestID), ClassBit) and not ExcludedSorts[Quest.zoneOrSort(QuestID)] and Quest.requiredSpecialization(QuestID) == 0 then
            local StartedBy = Quest.startedBy(QuestID)
            if StartedBy[1] or StartedBy[2] then
                local Single = Quest.preQuestSingle(QuestID)
                local Group = not Single and Quest.preQuestGroup(QuestID) or nil
                if Group then
                    for Index, PreQuestID in ipairs(Group) do
                        local Exclusive = PreQuestID > 0 and Quest.exclusiveTo(PreQuestID)
                        if Exclusive then table.insert(Exclusive, 1, PreQuestID) end
                        Group[Index] = Exclusive or math.abs(PreQuestID)
                    end
                end

                local MaxLevel, Next, BreadcrumbFor = Quest.requiredMaxLevel(QuestID), Quest.nextQuestInChain(QuestID), Quest.breadcrumbForQuestId(QuestID)
                local Parent, DisabledBy, UntilDone = Quest.parentQuest(QuestID), Quest.disabledByQuest(QuestID), Quest.availableUntilCompleted(QuestID)
                local StartingWith, Spell = Quest.availableStartingWith(QuestID), Quest.requiredSpell(QuestID)
                local Requirements = {
                    MaxLevel = MaxLevel > 0 and MaxLevel or nil,
                    Single = Single,
                    Group = Group,
                    Exclusive = Quest.exclusiveTo(QuestID),
                    Next = Next > 0 and Next or nil,
                    BreadcrumbFor = BreadcrumbFor > 0 and BreadcrumbFor or nil,
                    Breadcrumbs = Quest.breadcrumbs(QuestID),
                    Parent = Parent > 0 and Parent or nil,
                    DisabledBy = DisabledBy > 0 and DisabledBy or nil,
                    UntilDone = UntilDone > 0 and UntilDone or nil,
                    StartingWith = StartingWith > 0 and StartingWith or nil,
                    Spell = Spell ~= 0 and Spell or nil,
                    Skill = Quest.requiredSkill(QuestID),
                    Ranks = Quest.requiredRanks(QuestID),
                    MinRep = Quest.requiredMinRep(QuestID),
                    MaxRep = Quest.requiredMaxRep(QuestID),
                    Repeatable = Quest.specialFlags(QuestID) % 2 == 1 or nil,
                }
                Quests[QuestID] = { Quest.questLevel(QuestID), Quest.requiredLevel(QuestID), next(Requirements) and Requirements or false }

                for Kind = 1, 2 do
                    for _, GiverID in ipairs(StartedBy[Kind] or {}) do
                        local Key = Kind == 1 and GiverID or -GiverID
                        local Giver = GiverQuests[Key]
                        if not Giver then
                            Giver = {}
                            GiverQuests[Key] = Giver
                            GiverOrder[#GiverOrder + 1] = Key
                        end
                        Giver[#Giver + 1] = QuestID
                    end
                end
            end
        end
        coroutine.yield()
    end

    for _, Key in ipairs(GiverOrder) do
        local Entity = Key > 0 and QuestieDB.Npc or QuestieDB.Object
        local GiverID = math.abs(Key)
        local Spawns = Entity.spawns(GiverID)
        if Spawns then
            local Name = Entity.name(GiverID) or ""
            for MapID, Points in pairs(Private:GetQuestieSpawnPoints(Spawns)) do
                local isZone = ZoneMaps[MapID]
                if isZone == nil then
                    local MapInfo = C_Map.GetMapInfo(MapID)
                    isZone = MapInfo ~= nil and MapInfo.mapType >= Enum.UIMapType.Zone
                    ZoneMaps[MapID] = isZone
                end
                if isZone then
                    local Hubs = Givers[MapID] or {}
                    Givers[MapID] = Hubs
                    for Point = 1, #Points, 2 do
                        local Hub = FindHub(Hubs, Points[Point], Points[Point + 1])
                        if not Hub then
                            Hub = { Points[Point] / 100, Points[Point + 1] / 100 }
                            Hubs[#Hubs + 1] = Hub
                        end
                        if Hub.Giver ~= Key then
                            Hub.Giver = Key
                            Hub[#Hub + 1] = Name
                            for _, QuestID in ipairs(GiverQuests[Key]) do Hub[#Hub + 1] = QuestID end
                        end
                    end
                end
            end
        end
        coroutine.yield()
    end

    DrawAvailableQuests()
end

local function ResizeAvailableQuests()
    local IconSize = GetIconSize()
    for Icon in Private.AvailableQuestIcons:EnumerateActive() do Icon:SetSize(IconSize, IconSize) end
end

local function RefreshAvailableQuests()
    isRefreshQueued = false
    DrawAvailableQuests()
end

local function OnEvent()
    if isRefreshQueued then return end
    isRefreshQueued = true
    C_Timer.After(RefreshDelay, RefreshAvailableQuests)
end

local function WorldMap_OnShow()
    if not Private.DB.global.Miscellaneous.Navigation.Enable then return end
    for _, Event in ipairs(RefreshEvents) do Private.AvailableQuestOverlay:RegisterEvent(Event) end
    DrawAvailableQuests()
end

local function WorldMap_OnHide()
    Private.AvailableQuestOverlay:UnregisterAllEvents()
end

function Private:SetupAvailableQuests()
    if not Private.DB.global.Miscellaneous.Navigation.AvailableQuests.Enable or not QuestieDB then return end

    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_QUEST_OFFER"))
    Overlay:SetScript("OnEvent", OnEvent)
    Private.AvailableQuestOverlay = Overlay
    Private.AvailableQuestIcons = CreateUnsecuredFramePool("Frame", Overlay)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", DrawAvailableQuests)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeAvailableQuests)
    WorldMapFrame:HookScript("OnShow", WorldMap_OnShow)
    WorldMapFrame:HookScript("OnHide", WorldMap_OnHide)
    Private:QueueQuestieJob(BuildAvailableQuests)
end

function Private:UpdateAvailableQuests()
    if Private.AvailableQuestIcons then DrawAvailableQuests() end
end
