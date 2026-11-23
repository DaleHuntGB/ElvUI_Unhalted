local Private = select(2, ...)

local UiMaps = {}
local Jobs = {}
local Npcs, Objects, Items, Objectives = {}, {}, {}, {}
local Faction = ""

local function RunJobs(Ticker)
    local Deadline = debugprofilestop() + 4
    while Jobs[1] and debugprofilestop() < Deadline do
        local isOk, Message = coroutine.resume(Jobs[1])
        if not isOk then geterrorhandler()(Message) end
        if coroutine.status(Jobs[1]) == "dead" then table.remove(Jobs, 1) end
    end
    if Jobs[1] then return end
    Ticker:Cancel()
    Private:GetQuestieDB().InvalidateCache()
end

local function GetUiMap(AreaID)
    if not next(UiMaps) then
        local ZoneDB = Private:GetQuestieDB().Support.Get("ZoneDB").private
        for ID, MapID in pairs(loadstring(ZoneDB.areaIdToUiMapId)()) do UiMaps[ID] = MapID end
        for ID, MapID in pairs(loadstring(ZoneDB.areaIdToUiMapIdOverride)()) do UiMaps[ID] = MapID end
    end
    return UiMaps[AreaID] or 0
end

function Private:QueueQuestieJob(Job)
    Jobs[#Jobs + 1] = coroutine.create(Job)
    if #Jobs == 1 then C_Timer.NewTicker(0, RunJobs) end
end

function Private:GetQuestieSpawnPoints(Spawns)
    local Points = {}
    for AreaID, Coordinates in pairs(Spawns) do
        local MapID = GetUiMap(AreaID)
        if MapID > 0 then
            for _, Coordinate in ipairs(Coordinates) do
                local X, Y = Coordinate[1], Coordinate[2]
                if X >= 0 and X <= 100 and Y >= 0 and Y <= 100 then
                    local MapPoints = Points[MapID] or {}
                    MapPoints[#MapPoints + 1] = X
                    MapPoints[#MapPoints + 1] = Y
                    Points[MapID] = MapPoints
                end
            end
        end
    end
    return Points
end

function Private:GetQuestieNpc(NpcID)
    local Npc = Npcs[NpcID]
    if Npc then return Npc end

    local QuestieNpc = Private:GetQuestieDB().Npc
    if Faction == "" then Faction = UnitFactionGroup("player") == "Horde" and "H" or "A" end
    local Spawns, Waypoints = QuestieNpc.spawns(NpcID), QuestieNpc.waypoints(NpcID)
    local Paths = {}
    for AreaID, AreaPaths in pairs(Waypoints or {}) do
        local MapID = GetUiMap(AreaID)
        if MapID > 0 then
            for _, Path in ipairs(AreaPaths) do
                local Line = {}
                for _, Coordinate in ipairs(Path) do
                    if Coordinate[1] >= 0 and Coordinate[2] >= 0 then
                        Line[#Line + 1] = Coordinate[1]
                        Line[#Line + 1] = Coordinate[2]
                    end
                end
                if #Line >= 4 then
                    local MapPaths = Paths[MapID] or {}
                    MapPaths[#MapPaths + 1] = Line
                    Paths[MapID] = MapPaths
                end
            end
        end
    end
    local isTalk = QuestieNpc.npcFlags(NpcID) % 4 > 0 and (QuestieNpc.friendlyToFaction(NpcID) or ""):find(Faction, 1, true) ~= nil
    Npc = { QuestieNpc.name(NpcID) or "", Spawns and Private:GetQuestieSpawnPoints(Spawns) or {}, isTalk, Paths }
    Npcs[NpcID] = Npc
    return Npc
end

function Private:GetQuestieObject(ObjectID)
    local Object = Objects[ObjectID]
    if Object then return Object end

    local QuestieObject = Private:GetQuestieDB().Object
    local Spawns = QuestieObject.spawns(ObjectID)
    Object = { QuestieObject.name(ObjectID) or "", Spawns and Private:GetQuestieSpawnPoints(Spawns) or {} }
    Objects[ObjectID] = Object
    return Object
end

function Private:GetQuestieItem(ItemID)
    local Item = Items[ItemID]
    if Item then return Item end

    local QuestieDB = Private:GetQuestieDB()
    local Rates = {}
    local Drops = QuestieDB.Support.Get("QuestieClassicItemDrops").wowheadData
    local Start = Drops:find("\n    [" .. ItemID .. "] = {", 1, true)
    if Start then
        for NpcID, Rate in Drops:sub(Start, Drops:find("\n    }", Start, true)):gmatch("%[(%d+)%] = ([%d%.]+)") do Rates[tonumber(NpcID)] = tonumber(Rate) end
    end

    local Sources, Kept = QuestieDB.Item.npcDrops(ItemID) or {}, {}
    for _, NpcID in ipairs(Sources) do
        local Rate = Rates[NpcID]
        if #Sources > 15 and (Rate or 0) >= 5 or #Sources <= 15 and (not Rate or Rate >= 1) then Kept[#Kept + 1] = NpcID end
    end
    if #Sources > 15 then
        table.sort(Kept, function(A, B) return Rates[A] > Rates[B] end)
        for Index = #Kept, 16, -1 do Kept[Index] = nil end
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

function Private:GetQuestieObjectives(QuestID)
    local Entries = Objectives[QuestID]
    if Entries then return Entries end

    local QuestieDB = Private:GetQuestieDB()
    if not QuestieDB.Quest.Exists(QuestID) then return end

    local First = QuestieDB.ObjectiveFirst
    local Data = QuestieDB.Quest.objectives(QuestID) or {}
    Entries = {}
    for _, Creature in ipairs(Data[1] or {}) do Entries[#Entries + 1] = { 1, Creature[1] } end
    for _, Object in ipairs(Data[2] or {}) do table.insert(Entries, First.objectObjectiveFirst[QuestID] and 1 or #Entries + 1, { 2, Object[1] }) end
    for _, Item in ipairs(Data[3] or {}) do table.insert(Entries, First.itemObjectiveFirst[QuestID] and 1 or #Entries + 1, { 3, Item[1] }) end
    if Data[4] then Entries[#Entries + 1] = false end
    for _, Credit in ipairs(Data[5] or {}) do
        local Entry = { 1, unpack(Credit[1]) }
        if not tContains(Credit[1], Credit[2]) then Entry[#Entry + 1] = Credit[2] end
        table.insert(Entries, First.killCreditObjectiveFirst[QuestID] and 1 or #Entries + 1, Entry)
    end
    for _ in ipairs(Data[6] or {}) do table.insert(Entries, First.spellObjectiveFirst[QuestID] and 1 or #Entries + 1, false) end
    local Trigger = QuestieDB.Quest.triggerEnd(QuestID)
    if Trigger then table.insert(Entries, First.eventObjectiveFirst[QuestID] and 1 or #Entries + 1, { 4, Private:GetQuestieSpawnPoints(Trigger[2] or {}) }) end
    Objectives[QuestID] = Entries
    return Entries
end
