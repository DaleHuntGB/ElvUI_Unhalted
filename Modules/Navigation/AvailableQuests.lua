local Private = select(2, ...)

local IconAtlas, RepeatableIconAtlas = "QuestNormal", "QuestDaily"
local RefreshDelay = 0.2
local RaceBits = { [95] = 2 ^ 32, [96] = 2 ^ 33 }
local UndiscoveredStandings = { [87] = -36000, [576] = -36000, [910] = -36000 }
local RefreshEvents = { "QUEST_LOG_UPDATE", "PLAYER_LEVEL_UP", "SKILL_LINES_CHANGED", "UPDATE_FACTION" }

local Player = { Level = 0, TrivialRange = 0, RaceBit = 1, ClassBit = 1 }
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
    return Quest[2] > 0 and Quest[2] or Player.Level
end

local function CheckQuest(QuestID)
    local Quest = Private.AvailableQuests[QuestID]
    if not Quest or (Quest[3] > 0 and Quest[3] or GetQuestLevel(Quest)) > Player.Level then return false end
    if Player.Level - GetQuestLevel(Quest) > Player.TrivialRange then return false end
    if not HasBit(Quest[4], Player.RaceBit) or not HasBit(Quest[5], Player.ClassBit) then return false end
    if IsTaken(QuestID) then return false end

    local Requirements = Quest[7]
    if not Requirements then return true end
    if Requirements.MaxLevel and Player.Level > Requirements.MaxLevel then return false end
    if Requirements.Single and not AnyDone(Requirements.Single) then return false end
    if Requirements.Group and not GroupDone(Requirements.Group) then return false end
    if Requirements.Exclusive and AnyTaken(Requirements.Exclusive) then return false end
    if Requirements.Next and AnyTaken(Requirements.Next) then return false end
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
            local Requirements = Private.AvailableQuests[QuestID][7]
            if not (Requirements and Requirements.Repeatable) then return IconAtlas end
            isRepeatableOnly = true
        end
    end
    return isRepeatableOnly and RepeatableIconAtlas
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
            local Quest = Private.AvailableQuests[Value]
            local Level = GetQuestLevel(Quest)
            local Colour = GetQuestDifficultyColor(Level)
            if Colour == QuestDifficultyColors.trivial then Colour = QuestDifficultyColors.standard end
            GameTooltip:AddLine("[" .. Level .. "] " .. Quest[1], Colour.r, Colour.g, Colour.b)
            if Quest[6] then GameTooltip:AddLine(Quest[6], 1, 1, 1, true) end
        end
    end
    GameTooltip:Show()
end

local function GetIconSize()
    return Private.DB.global.Miscellaneous.Navigation.AvailableQuests.IconSize / WorldMapFrame:GetCanvas():GetScale()
end

function Private:DrawAvailableQuests()
    local Pool = Private.AvailableQuestIcons
    Pool:ReleaseAll()
    if not Private.DB.global.Miscellaneous.Navigation.Enable or not WorldMapFrame:IsShown() then return end

    local MapID = WorldMapFrame:GetMapID()
    local Hubs = MapID and Private.AvailableQuestGivers[MapID]
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

local function ResizeAvailableQuests()
    local IconSize = GetIconSize()
    for Icon in Private.AvailableQuestIcons:EnumerateActive() do Icon:SetSize(IconSize, IconSize) end
end

local function RefreshAvailableQuests()
    isRefreshQueued = false
    Private:DrawAvailableQuests()
end

local function OnEvent()
    if isRefreshQueued then return end
    isRefreshQueued = true
    C_Timer.After(RefreshDelay, RefreshAvailableQuests)
end

local function WorldMap_OnShow()
    if not Private.DB.global.Miscellaneous.Navigation.Enable then return end
    for _, Event in ipairs(RefreshEvents) do Private.AvailableQuestOverlay:RegisterEvent(Event) end
    Private:DrawAvailableQuests()
end

local function WorldMap_OnHide()
    Private.AvailableQuestOverlay:UnregisterAllEvents()
end

function Private:CreateAvailableQuests()
    local Faction = UnitFactionGroup("player")
    if not Private.DB.global.Miscellaneous.Navigation.AvailableQuests.Enable or not Private.AvailableQuestGivers[Faction] then
        Private.AvailableQuests, Private.AvailableQuestsByFaction, Private.AvailableQuestGivers = nil, nil, nil
        return
    end

    for QuestID, Quest in pairs(Private.AvailableQuestsByFaction[Faction]) do Private.AvailableQuests[QuestID] = Quest end
    Private.AvailableQuestsByFaction = nil
    Private.AvailableQuestGivers = Private.AvailableQuestGivers[Faction]

    local _, _, RaceID = UnitRace("player")
    local _, _, ClassID = UnitClass("player")
    Player.RaceBit = RaceBits[RaceID] or (2 ^ (RaceID - 1))
    Player.ClassBit = 2 ^ (ClassID - 1)

    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_QUEST_OFFER"))
    Overlay:SetScript("OnEvent", OnEvent)
    Private.AvailableQuestOverlay = Overlay
    Private.AvailableQuestIcons = CreateUnsecuredFramePool("Frame", Overlay)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", Private.DrawAvailableQuests)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeAvailableQuests)
    WorldMapFrame:HookScript("OnShow", WorldMap_OnShow)
    WorldMapFrame:HookScript("OnHide", WorldMap_OnHide)
end

function Private:UpdateAvailableQuests()
    if Private.AvailableQuestIcons then Private:DrawAvailableQuests() end
end
