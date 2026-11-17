local Private = select(2, ...)

local JobBudget = 4

local UiMaps = {}
local Jobs = {}

local function RunJobs(Ticker)
    local Deadline = debugprofilestop() + JobBudget
    while Jobs[1] and debugprofilestop() < Deadline do
        local isOk, Message = coroutine.resume(Jobs[1])
        if not isOk then geterrorhandler()(Message) end
        if coroutine.status(Jobs[1]) == "dead" then table.remove(Jobs, 1) end
    end
    if Jobs[1] then return end
    Ticker:Cancel()
    Private:GetQuestieDB().InvalidateCache()
end

function Private:QueueQuestieJob(Job)
    Jobs[#Jobs + 1] = coroutine.create(Job)
    if #Jobs == 1 then C_Timer.NewTicker(0, RunJobs) end
end

function Private:GetQuestieSpawnPoints(Spawns)
    if not next(UiMaps) then
        local ZoneDB = Private:GetQuestieDB().Support.Get("ZoneDB").private
        for AreaID, MapID in pairs(loadstring(ZoneDB.areaIdToUiMapId)()) do UiMaps[AreaID] = MapID end
        for AreaID, MapID in pairs(loadstring(ZoneDB.areaIdToUiMapIdOverride)()) do UiMaps[AreaID] = MapID end
    end

    local Points = {}
    for AreaID, Coordinates in pairs(Spawns) do
        local MapID = UiMaps[AreaID] or 0
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
