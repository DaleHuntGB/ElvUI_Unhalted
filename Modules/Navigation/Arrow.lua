local Private = select(2, ...)

local GoalEvents = { "PLAYER_ENTERING_WORLD", "SUPER_TRACKING_CHANGED", "USER_WAYPOINT_UPDATED", "QUEST_POI_UPDATE", "QUEST_LOG_UPDATE" }
local GoalVector = CreateVector2D(0, 0)
local State = {
    GoalContinent = 0, GoalX = 0, GoalY = 0, GoalQuestID = 0,
    Elapsed = 0, Distance = -1,
    isGoalStale = false, isOnTaxi = false, isInHotSpot = false, hasDirection = true,
}

local function GetGoalMapPosition()
    local QuestID = C_SuperTrack.GetSuperTrackedQuestID()
    if QuestID and QuestID > 0 then
        local QuestieDB = Private:GetQuestieDB()
        local Entries = QuestieDB and Private:GetQuestieObjectives(QuestID)
        if Entries then
            local Targets = {}
            if C_QuestLog.IsComplete(QuestID) then
                local FinishedBy = QuestieDB.Quest.finishedBy(QuestID)
                for _, NpcID in ipairs(FinishedBy[1] or {}) do Targets[#Targets + 1] = Private:GetQuestieNpc(NpcID)[2] end
                for _, ObjectID in ipairs(FinishedBy[2] or {}) do Targets[#Targets + 1] = Private:GetQuestieObject(ObjectID)[2] end
            else
                for Index, Objective in ipairs(C_QuestLog.GetQuestObjectives(QuestID)) do
                    local Entry = Entries[Index]
                    if Entry and not Objective.finished then
                        local Kind = Entry[1]
                        if Kind == 3 then
                            local Item = Private:GetQuestieItem(Entry[2])
                            for Source = 1, #Item[1], 2 do Targets[#Targets + 1] = Private:GetQuestieNpc(Item[1][Source])[2] end
                            for _, ObjectID in ipairs(Item[2]) do Targets[#Targets + 1] = Private:GetQuestieObject(ObjectID)[2] end
                        elseif Kind == 4 then
                            Targets[#Targets + 1] = Entry[2]
                        else
                            for Source = 2, #Entry do Targets[#Targets + 1] = (Kind == 1 and Private:GetQuestieNpc(Entry[Source]) or Private:GetQuestieObject(Entry[Source]))[2] end
                        end
                    end
                end
            end

            local PlayerX, PlayerY, _, PlayerContinent = UnitPosition("player")
            if Private:IsSecret(PlayerX) or not PlayerX then PlayerX, PlayerY, PlayerContinent = 0, 0, -1 end
            local BestMapID, BestX, BestY, BestDistance = 0, 0, 0, math.huge
            for _, Points in ipairs(Targets) do
                for MapID, MapPoints in pairs(Points) do
                    for Point = 1, #MapPoints, 2 do
                        GoalVector:SetXY(MapPoints[Point] / 100, MapPoints[Point + 1] / 100)
                        local Continent, Position = C_Map.GetWorldPosFromMapPos(MapID, GoalVector)
                        if Position then
                            local X, Y = Position:GetXY()
                            local Distance = (X - PlayerX) ^ 2 + (Y - PlayerY) ^ 2 + (Continent == PlayerContinent and 0 or 1e12)
                            if Distance < BestDistance then BestMapID, BestX, BestY, BestDistance = MapID, MapPoints[Point] / 100, MapPoints[Point + 1] / 100, Distance end
                        end
                    end
                end
            end
            if BestMapID > 0 then return BestMapID, BestX, BestY, QuestID end
        end

        local MapID = GetQuestUiMapID(QuestID, true)
        local Quests = MapID and MapID > 0 and C_QuestLog.GetQuestsOnMap(MapID)
        if Quests then
            for _, Quest in ipairs(Quests) do
                if Quest.questID == QuestID then return MapID, Quest.x, Quest.y, QuestID end
            end
        end
        local WaypointMapID, X, Y = C_QuestLog.GetNextWaypoint(QuestID)
        return WaypointMapID, X, Y, QuestID
    end

    local Waypoint = C_SuperTrack.IsSuperTrackingUserWaypoint() and C_Map.GetUserWaypoint()
    if Waypoint then return Waypoint.uiMapID, Waypoint.position.x, Waypoint.position.y, 0 end
end

local function SetDirectionShown(isShown)
    if State.hasDirection == isShown then return end
    State.hasDirection = isShown
    Private.NavigationArrow.Arrow:SetShown(isShown)
    Private.NavigationArrow.Distance:SetShown(isShown)
end

local function StopNavigation()
    Private.NavigationArrow.Driver:SetScript("OnUpdate", nil)
    Private.NavigationArrow:Hide()
end

local function Driver_OnUpdate(_, TimeElapsed)
    local X, Y, _, Continent = UnitPosition("player")
    if Private:IsSecret(X) or not X then SetDirectionShown(false) return end

    State.Elapsed = State.Elapsed + TimeElapsed
    if State.Elapsed >= 0.5 then
        State.Elapsed = 0
        State.isOnTaxi = UnitOnTaxi("player")
        local isInside = State.GoalQuestID ~= 0 and C_Minimap.IsInsideQuestBlob(State.GoalQuestID)
        State.isInHotSpot = not Private:IsSecret(isInside) and isInside or false
        Private.NavigationArrow:SetShown(not State.isInHotSpot)
    end
    if State.isInHotSpot then return end

    local Facing = GetPlayerFacing()
    if State.isOnTaxi or State.GoalContinent ~= Continent or Private:IsSecret(Facing) or not Facing then SetDirectionShown(false) return end
    SetDirectionShown(true)

    local DeltaX, DeltaY = State.GoalX - X, State.GoalY - Y
    local Yards = math.floor(math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY) + 0.5)
    if Yards ~= State.Distance then
        State.Distance = Yards
        Private.NavigationArrow.Distance:SetFormattedText("%d yd", Yards)
    end
    Private.NavigationArrow.Arrow:SetRotation(math.atan2(DeltaY, DeltaX) - Facing)
end

local function UpdateGoal()
    local MapID, MapX, MapY, QuestID = GetGoalMapPosition()
    if not MapID or not MapX then StopNavigation() return end
    GoalVector:SetXY(MapX, MapY)
    local Continent, Position = C_Map.GetWorldPosFromMapPos(MapID, GoalVector)
    if not Continent or not Position then StopNavigation() return end

    State.GoalX, State.GoalY = Position:GetXY()
    State.GoalContinent, State.GoalQuestID = Continent, QuestID or 0
    State.Elapsed, State.Distance = 0.5, -1
    Private.NavigationArrow.Driver:SetScript("OnUpdate", Driver_OnUpdate)
end

local function Driver_OnEvent(_, Event)
    if Event == "UNIT_QUEST_LOG_CHANGED" then
        State.isGoalStale = true
        return
    elseif Event == "QUEST_LOG_UPDATE" then
        if not State.isGoalStale then return end
        State.isGoalStale = false
    end
    UpdateGoal()
end

function Private:UpdateNavigationArrow()
    local NavigationArrow = Private.NavigationArrow
    if not NavigationArrow then return end
    local DB = Private.DB.global.Miscellaneous.Navigation

    NavigationArrow.Arrow:SetTexture(Private.NavigationArrows[DB.Arrow.Texture].Path)
    NavigationArrow:SetSize(DB.Arrow.Size, DB.Arrow.Size)
    NavigationArrow:ClearAllPoints()
    NavigationArrow:SetPoint(DB.Arrow.Layout[1], UIParent, DB.Arrow.Layout[2], DB.Arrow.Layout[3], DB.Arrow.Layout[4])
    Private.E:SetFont(NavigationArrow.Distance, Private:FetchFont(Private.E.db.general.font), DB.Arrow.FontSize, Private.E.db.general.fontStyle)

    local Driver = NavigationArrow.Driver
    if DB.Enable and DB.Arrow.Enable then
        for _, Event in ipairs(GoalEvents) do Driver:RegisterEvent(Event) end
        Driver:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
        Driver:SetScript("OnEvent", Driver_OnEvent)
        UpdateGoal()
    else
        Driver:UnregisterAllEvents()
        Driver:SetScript("OnEvent", nil)
        StopNavigation()
    end
end

function Private:SetupNavigationArrow()
    local NavigationArrow = CreateFrame("Frame", "UnhaltedNavigationArrow", UIParent)
    NavigationArrow:Hide()

    NavigationArrow.Arrow = NavigationArrow:CreateTexture(nil, "ARTWORK")
    NavigationArrow.Arrow:SetAllPoints(NavigationArrow)
    NavigationArrow.Arrow:SetVertexColor(Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b)

    NavigationArrow.Distance = NavigationArrow:CreateFontString(nil, "OVERLAY")
    NavigationArrow.Distance:SetPoint("TOP", NavigationArrow, "BOTTOM", 0, -3)

    NavigationArrow.Driver = CreateFrame("Frame")
    Private.NavigationArrow = NavigationArrow
end
