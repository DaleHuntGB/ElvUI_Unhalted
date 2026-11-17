local Private = select(2, ...)

local RefreshDelay = 0.2
local MergeDistance = 25
local BadgeInset = 0.8
local MaxDropSources, CommonDropRate, MinDropRate = 15, 5, 1
local RefreshEvents = { "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED" }
local CircleMask = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local MissingIcon = 134400
local NpcKind, ObjectKind, ItemKind, AreaKind = 1, 2, 3, 4
local KillAtlas, TalkAtlas, ObjectAtlas, AreaAtlas = "dungeonskull", "crosshair_speak_64", "mechagon-projects", "xmarksthespot"

local QuestieDB = Private:GetQuestieDB()
local Objectives, Npcs, Objects, Items = {}, {}, {}, {}
local Placed = {}
local Faction, IconSize = "", 0
local isRefreshQueued = false

local function GetIconSize()
    return Private.DB.global.Miscellaneous.Navigation.QuestObjectives.IconSize / WorldMapFrame:GetCanvas():GetScale()
end

local function SizeIcon(Icon, Size)
    local Inner = Size * BadgeInset
    Icon:SetSize(Size, Size)
    Icon.Mask:SetSize(Inner, Inner)
    Icon.Badge:SetSize(Inner, Inner)
end

local function GetNpc(NpcID)
    local Npc = Npcs[NpcID]
    if Npc then return Npc end
    local Spawns = QuestieDB.Npc.spawns(NpcID)
    local isTalk = QuestieDB.Npc.npcFlags(NpcID) % 4 > 0 and (QuestieDB.Npc.friendlyToFaction(NpcID) or ""):find(Faction, 1, true) ~= nil
    Npc = { QuestieDB.Npc.name(NpcID) or "", Spawns and Private:GetQuestieSpawnPoints(Spawns) or {}, isTalk }
    Npcs[NpcID] = Npc
    return Npc
end

local function GetObject(ObjectID)
    local Object = Objects[ObjectID]
    if Object then return Object end
    local Spawns = QuestieDB.Object.spawns(ObjectID)
    Object = { QuestieDB.Object.name(ObjectID) or "", Spawns and Private:GetQuestieSpawnPoints(Spawns) or {} }
    Objects[ObjectID] = Object
    return Object
end

local function GetItem(ItemID)
    local Item = Items[ItemID]
    if Item then return Item end

    local Rates = {}
    local Drops = QuestieDB.Support.Get("QuestieClassicItemDrops").wowheadData
    local Start = Drops:find("\n    [" .. ItemID .. "] = {", 1, true)
    if Start then
        for NpcID, Rate in Drops:sub(Start, Drops:find("\n    }", Start, true)):gmatch("%[(%d+)%] = ([%d%.]+)") do Rates[tonumber(NpcID)] = tonumber(Rate) end
    end

    local Sources, Kept = QuestieDB.Item.npcDrops(ItemID) or {}, {}
    for _, NpcID in ipairs(Sources) do
        local Rate = Rates[NpcID]
        if #Sources > MaxDropSources and (Rate or 0) >= CommonDropRate or #Sources <= MaxDropSources and (not Rate or Rate >= MinDropRate) then Kept[#Kept + 1] = NpcID end
    end
    if #Sources > MaxDropSources then
        table.sort(Kept, function(A, B) return Rates[A] > Rates[B] end)
        for Index = #Kept, MaxDropSources + 1, -1 do Kept[Index] = nil end
    end

    local DropSources = {}
    for _, NpcID in ipairs(Kept) do
        DropSources[#DropSources + 1] = NpcID
        DropSources[#DropSources + 1] = math.floor((Rates[NpcID] or 0) + 0.5)
    end
    Item = { DropSources, QuestieDB.Item.objectDrops(ItemID) or {} }
    Items[ItemID] = Item
    return Item
end

local function AddSource(Icon, Name, Rate)
    if not Name then return end
    for Index = 1, #Icon.Sources do
        if Icon.Sources[Index] == Name then
            Icon.Rates[Index] = math.max(Icon.Rates[Index], Rate)
            return
        end
    end
    Icon.Sources[#Icon.Sources + 1] = Name
    Icon.Rates[#Icon.Rates + 1] = Rate
end

local function ObjectiveIcon_OnEnter(Icon)
    GameTooltip:SetOwner(Icon, "ANCHOR_RIGHT")
    local Colour = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(Icon.QuestID))
    GameTooltip:SetText(C_QuestLog.GetTitleForQuestID(Icon.QuestID) or "", Colour.r, Colour.g, Colour.b)
    local Objective = C_QuestLog.GetQuestObjectives(Icon.QuestID)[Icon.Index]
    if Objective then GameTooltip:AddLine(Objective.text, 1, 1, 1, true) end
    for Index = 1, #Icon.Sources do
        local Rate = Icon.Rates[Index]
        if Rate > 0 then
            GameTooltip:AddDoubleLine(Icon.Sources[Index], Rate .. "%", 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine(Icon.Sources[Index], 0.7, 0.7, 0.7)
        end
    end
    GameTooltip:Show()
end

local function PlaceIcons(Points, Texture, QuestID, Index, Name, Rate)
    if not Points then return end
    local Overlay = Private.QuestObjectiveOverlay
    local Width, Height = Overlay:GetWidth(), Overlay:GetHeight()
    local isSymbol = type(Texture) == "string"
    for Point = 1, #Points, 2 do
        local X, Y = Points[Point], Points[Point + 1]
        local Merged = false
        for Other = 1, #Placed do
            local Icon = Placed[Other]
            local DeltaX, DeltaY = (Icon.X - X) * 10.02, (Icon.Y - Y) * 6.68
            if DeltaX * DeltaX + DeltaY * DeltaY <= MergeDistance * MergeDistance then
                AddSource(Icon, Name, Rate)
                Merged = true
                break
            end
        end
        if not Merged then
            local Icon = Private.QuestObjectiveIcons:Acquire()
            if not Icon.Badge then
                Icon.Mask = Icon:CreateMaskTexture()
                Icon.Mask:SetTexture(CircleMask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                Icon.Mask:SetPoint("CENTER")
                Icon.Badge = Icon:CreateTexture(nil, "ARTWORK")
                Icon.Badge:SetPoint("CENTER")
                Icon.Badge:AddMaskTexture(Icon.Mask)
                Icon.Ring = Icon:CreateTexture(nil, "OVERLAY")
                Icon.Ring:SetAtlas("Garr_FollowerPortrait_Ring")
                Icon.Ring:SetAllPoints(Icon)
                Icon.Symbol = Icon:CreateTexture(nil, "ARTWORK")
                Icon.Symbol:SetAllPoints(Icon)
                Icon.Sources, Icon.Rates = {}, {}
                Icon:EnableMouseMotion(true)
                Icon:SetScript("OnEnter", ObjectiveIcon_OnEnter)
                Icon:SetScript("OnLeave", GameTooltip_Hide)
            end
            wipe(Icon.Sources)
            wipe(Icon.Rates)
            Icon.X, Icon.Y, Icon.QuestID, Icon.Index = X, Y, QuestID, Index
            AddSource(Icon, Name, Rate)
            Icon.Symbol:SetShown(isSymbol)
            Icon.Badge:SetShown(not isSymbol)
            Icon.Ring:SetShown(not isSymbol)
            if isSymbol then
                Icon.Symbol:SetAtlas(Texture)
            else
                Icon.Badge:SetTexture(Texture)
                Icon.Badge:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
            SizeIcon(Icon, IconSize)
            Icon:SetPoint("CENTER", Overlay, "TOPLEFT", X / 100 * Width, -Y / 100 * Height)
            Icon:Show()
            Placed[#Placed + 1] = Icon
        end
    end
end

function Private:DrawQuestObjectives()
    Private.QuestObjectiveIcons:ReleaseAll()
    if not Private.DB.global.Miscellaneous.Navigation.Enable or not WorldMapFrame:IsShown() then return end

    local MapID = WorldMapFrame:GetMapID()
    if not MapID then return end

    IconSize = GetIconSize()
    for WatchIndex = 1, C_QuestLog.GetNumQuestWatches() do
        local QuestID = C_QuestLog.GetQuestIDForQuestWatchIndex(WatchIndex)
        local Entries = QuestID and Objectives[QuestID]
        if QuestID and not Entries and QuestieDB.Quest.Exists(QuestID) then
            local First = QuestieDB.ObjectiveFirst
            local Data = QuestieDB.Quest.objectives(QuestID) or {}
            Entries = {}
            for _, Creature in ipairs(Data[1] or {}) do Entries[#Entries + 1] = { NpcKind, Creature[1] } end
            for _, Object in ipairs(Data[2] or {}) do table.insert(Entries, First.objectObjectiveFirst[QuestID] and 1 or #Entries + 1, { ObjectKind, Object[1] }) end
            for _, Item in ipairs(Data[3] or {}) do table.insert(Entries, First.itemObjectiveFirst[QuestID] and 1 or #Entries + 1, { ItemKind, Item[1] }) end
            if Data[4] then Entries[#Entries + 1] = false end
            for _, Credit in ipairs(Data[5] or {}) do
                local Entry = { NpcKind, unpack(Credit[1]) }
                if not tContains(Credit[1], Credit[2]) then Entry[#Entry + 1] = Credit[2] end
                table.insert(Entries, First.killCreditObjectiveFirst[QuestID] and 1 or #Entries + 1, Entry)
            end
            for _ in ipairs(Data[6] or {}) do table.insert(Entries, First.spellObjectiveFirst[QuestID] and 1 or #Entries + 1, false) end
            local Trigger = QuestieDB.Quest.triggerEnd(QuestID)
            if Trigger then table.insert(Entries, First.eventObjectiveFirst[QuestID] and 1 or #Entries + 1, { AreaKind, Private:GetQuestieSpawnPoints(Trigger[2] or {}) }) end
            Objectives[QuestID] = Entries
        end
        if Entries then
            for Index, Objective in ipairs(C_QuestLog.GetQuestObjectives(QuestID)) do
                local Entry = Entries[Index]
                if Entry and not Objective.finished then
                    wipe(Placed)
                    local Kind = Entry[1]
                    if Kind == ItemKind then
                        local Item = GetItem(Entry[2])
                        local Texture = C_Item.GetItemIconByID(Entry[2]) or MissingIcon
                        local DropSources = Item[1]
                        for Source = 1, #DropSources, 2 do
                            local Npc = GetNpc(DropSources[Source])
                            PlaceIcons(Npc[2][MapID], Texture, QuestID, Index, Npc[1], DropSources[Source + 1])
                        end
                        for _, ObjectID in ipairs(Item[2]) do
                            local Object = GetObject(ObjectID)
                            PlaceIcons(Object[2][MapID], Texture, QuestID, Index, Object[1], 0)
                        end
                    elseif Kind == AreaKind then
                        PlaceIcons(Entry[2][MapID], AreaAtlas, QuestID, Index, nil, 0)
                    else
                        for Source = 2, #Entry do
                            local Record = Kind == NpcKind and GetNpc(Entry[Source]) or GetObject(Entry[Source])
                            local Atlas = Kind == ObjectKind and ObjectAtlas or Record[3] and TalkAtlas or KillAtlas
                            PlaceIcons(Record[2][MapID], Atlas, QuestID, Index, Record[1], 0)
                        end
                    end
                end
            end
        end
    end
end

local function ResizeQuestObjectives()
    local Size = GetIconSize()
    for Icon in Private.QuestObjectiveIcons:EnumerateActive() do SizeIcon(Icon, Size) end
end

local function RefreshQuestObjectives()
    isRefreshQueued = false
    Private:DrawQuestObjectives()
end

local function OnEvent()
    if isRefreshQueued then return end
    isRefreshQueued = true
    C_Timer.After(RefreshDelay, RefreshQuestObjectives)
end

local function WorldMap_OnShow()
    if not Private.DB.global.Miscellaneous.Navigation.Enable then return end
    for _, Event in ipairs(RefreshEvents) do Private.QuestObjectiveOverlay:RegisterEvent(Event) end
    Private:DrawQuestObjectives()
end

local function WorldMap_OnHide()
    Private.QuestObjectiveOverlay:UnregisterAllEvents()
end

function Private:CreateQuestObjectives()
    if not Private.DB.global.Miscellaneous.Navigation.QuestObjectives.Enable or not QuestieDB then return end

    Faction = UnitFactionGroup("player") == "Horde" and "H" or "A"

    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_DIG_SITE"))
    Overlay:SetScript("OnEvent", OnEvent)
    Private.QuestObjectiveOverlay = Overlay
    Private.QuestObjectiveIcons = CreateUnsecuredFramePool("Frame", Overlay)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", Private.DrawQuestObjectives)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeQuestObjectives)
    WorldMapFrame:HookScript("OnShow", WorldMap_OnShow)
    WorldMapFrame:HookScript("OnHide", WorldMap_OnHide)
end

function Private:UpdateQuestObjectives()
    if Private.QuestObjectiveIcons then Private:DrawQuestObjectives() end
end
