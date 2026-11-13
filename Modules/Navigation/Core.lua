local Private = select(2, ...)

local ReplanDistance, CheckInterval = 25, 0.5
local MaxSteps = 5

local GoalVector = CreateVector2D(0, 0)
local State = {
    GoalContinent = 0, GoalX = 0, GoalY = 0, GoalName = "", GoalQuestID = 0,
    PlanContinent = -1, PlanX = 0, PlanY = 0,
    Elapsed = 0, Distance = -1,
    isDirty = false, isGoalStale = false, isOnTaxi = false, isInHotSpot = false, hasDirection = false, hasHinted = false, hasGoalObjectives = false,
}

local function HasObjectives(QuestID)
    return #C_QuestLog.GetQuestObjectives(QuestID) > 0
end

local function GetGoalMapPosition()
    local QuestID = C_SuperTrack.GetSuperTrackedQuestID()
    if QuestID and QuestID > 0 then
        if C_QuestLog.IsComplete(QuestID) and HasObjectives(QuestID) then return end
        local Name = C_QuestLog.GetTitleForQuestID(QuestID) or "Quest"
        local MapID = GetQuestUiMapID(QuestID, true)
        local Quests = MapID and MapID > 0 and C_QuestLog.GetQuestsOnMap(MapID)
        if Quests then
            for _, Quest in ipairs(Quests) do
                if Quest.questID == QuestID then return MapID, Quest.x, Quest.y, Name, QuestID end
            end
        end
        local WaypointMapID, X, Y = C_QuestLog.GetNextWaypoint(QuestID)
        return WaypointMapID, X, Y, Name, QuestID
    end

    local Waypoint = C_SuperTrack.IsSuperTrackingUserWaypoint() and C_Map.GetUserWaypoint()
    if Waypoint then return Waypoint.uiMapID, Waypoint.position.x, Waypoint.position.y, "Map Pin" end
end

local function GetGoalWorldPosition()
    local MapID, X, Y, Name, QuestID = GetGoalMapPosition()
    if not MapID or not X then return end
    GoalVector:SetXY(X, Y)
    local Continent, Position = C_Map.GetWorldPosFromMapPos(MapID, GoalVector)
    if not Position then return end
    local WorldX, WorldY = Position:GetXY()
    return Continent, WorldX, WorldY, Name, QuestID
end

local function IsInHotSpot()
    if State.GoalQuestID == 0 then return false end
    local isInside = C_Minimap.IsInsideQuestBlob(State.GoalQuestID)
    return not issecretvalue(isInside) and isInside
end

local function SetDirectionShown(isShown)
    if State.hasDirection == isShown then return end
    State.hasDirection = isShown
    Private.NavigationArrow.Arrow:SetShown(isShown)
    Private.NavigationArrow.Distance:SetShown(isShown)
end

local function ClearRoute()
    Private.NavigationRoute = nil
    Private.NavigationArrow:Hide()
end

local function StopNavigation()
    Private.NavigationFrame:SetScript("OnUpdate", nil)
    ClearRoute()
end

local function CheckRoute(Continent, X, Y)
    State.isOnTaxi = UnitOnTaxi("player")
    if State.isOnTaxi then return end

    local DeltaX, DeltaY = X - State.PlanX, Y - State.PlanY
    if not State.isDirty and Continent == State.PlanContinent and DeltaX * DeltaX + DeltaY * DeltaY <= ReplanDistance * ReplanDistance then return end

    local KnownTaxiNodes = Private.DB.char.Navigation.KnownTaxiNodes
    State.isDirty, State.PlanContinent, State.PlanX, State.PlanY = false, Continent, X, Y

    local Route = Private:PlanNavigationRoute(Continent, X, Y, State.GoalContinent, State.GoalX, State.GoalY, State.GoalName, KnownTaxiNodes)
    if not Route then ClearRoute() return end

    local Steps = {}
    for Index = 1, math.min(#Route, MaxSteps) do
        Steps[Index] = (Index == 1 and "|cFFFFFFFF" or "|cFF808080") .. Route[Index].Mode .. ": " .. Route[Index].Name .. "|r"
    end

    Private.NavigationRoute = Route
    Private.NavigationArrow.Steps:SetText(table.concat(Steps, "\n"))
    Private.NavigationArrow:SetShown(not State.isInHotSpot)

    if not State.hasHinted and not next(KnownTaxiNodes) then
        State.hasHinted = true
        print(string.format("|c%sNavigation|r Open a flight master's map to add your flight paths to routes.", Private.E.AccentColour))
    end
end

local function Navigation_OnUpdate(_, TimeElapsed)
    local X, Y, _, Continent = UnitPosition("player")
    if not X or issecretvalue(X) then
        if Private.NavigationRoute then ClearRoute() State.isDirty = true end
        return
    end

    State.Elapsed = State.Elapsed + TimeElapsed
    if State.Elapsed >= CheckInterval then
        State.Elapsed = 0
        if State.hasGoalObjectives and C_QuestLog.IsComplete(State.GoalQuestID) then StopNavigation() return end
        local isInHotSpot = IsInHotSpot()
        if isInHotSpot ~= State.isInHotSpot then
            State.isInHotSpot = isInHotSpot
            if Private.NavigationRoute then Private.NavigationArrow:SetShown(not isInHotSpot) end
        end
        CheckRoute(Continent, X, Y)
    end

    local Route = Private.NavigationRoute
    if not Route or State.isInHotSpot then return end

    local Points = Route[1].Points
    local Target = Points[#Points]
    local Facing = GetPlayerFacing()
    if State.isOnTaxi or Target[1] ~= Continent or not Facing or issecretvalue(Facing) then SetDirectionShown(false) return end
    SetDirectionShown(true)

    local DeltaX, DeltaY = Target[2] - X, Target[3] - Y
    local Yards = math.floor(math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY) + 0.5)
    if Yards ~= State.Distance then
        State.Distance = Yards
        Private.NavigationArrow.Distance:SetFormattedText("%d yd", Yards)
    end
    Private.NavigationArrow.Arrow:SetRotation(math.atan2(DeltaY, DeltaX) - Facing)
end

local function UpdateGoal()
    local Continent, X, Y, Name, QuestID = GetGoalWorldPosition()
    if not Continent then StopNavigation() return end

    QuestID = QuestID or 0
    local isNavigating = Private.NavigationFrame:GetScript("OnUpdate") ~= nil
    if isNavigating and Continent == State.GoalContinent and X == State.GoalX and Y == State.GoalY and QuestID == State.GoalQuestID then return end

    State.GoalContinent, State.GoalX, State.GoalY, State.GoalName, State.GoalQuestID = Continent, X, Y, Name, QuestID
    State.hasGoalObjectives = QuestID > 0 and HasObjectives(QuestID)
    State.isDirty, State.Elapsed = true, CheckInterval
    Private.NavigationFrame:SetScript("OnUpdate", Navigation_OnUpdate)
end

local function Navigation_OnEvent(_, Event)
    if Event == "UNIT_QUEST_LOG_CHANGED" then
        State.isGoalStale = true
        return
    elseif Event == "QUEST_LOG_UPDATE" then
        if not State.isGoalStale then return end
        State.isGoalStale = false
    end
    if Event ~= "TAXIMAP_OPENED" then UpdateGoal() return end

    local KnownTaxiNodes = Private.DB.char.Navigation.KnownTaxiNodes
    for _, TaxiNode in ipairs(C_TaxiMap.GetAllTaxiNodes(GetTaxiMapID())) do
        if TaxiNode.slotIndex and Private.NavigationTaxiNodes[TaxiNode.nodeID] then
            local NodeType = TaxiNodeGetType(TaxiNode.slotIndex)
            KnownTaxiNodes[TaxiNode.nodeID] = (NodeType == "CURRENT" or NodeType == "REACHABLE") or nil
        end
    end
    State.isDirty = true
    Private:DrawNavigationMap()
end

function Private:UpdateNavigation()
    local NavigationFrame = Private.NavigationFrame
    if not NavigationFrame then return end
    local DB = Private.DB.global.Miscellaneous.Navigation

    Private:UpdateNavigationArrow()
    Private:UpdateNavigationFlightTimer()
    Private:DrawNavigationMap()

    if DB.Enable then
        NavigationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        NavigationFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
        NavigationFrame:RegisterEvent("USER_WAYPOINT_UPDATED")
        NavigationFrame:RegisterEvent("QUEST_POI_UPDATE")
        NavigationFrame:RegisterEvent("QUEST_LOG_UPDATE")
        NavigationFrame:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
        NavigationFrame:RegisterEvent("TAXIMAP_OPENED")
        NavigationFrame:SetScript("OnEvent", Navigation_OnEvent)
        UpdateGoal()
    else
        NavigationFrame:UnregisterAllEvents()
        NavigationFrame:SetScript("OnEvent", nil)
        NavigationFrame:SetScript("OnUpdate", nil)
        ClearRoute()
    end
end

function Private:SetupNavigation()
    Private.NavigationFrame = CreateFrame("Frame")
    Private:CreateNavigationArrow()
    Private:CreateNavigationMap()
    Private:CreateNavigationFlightTimer()
    Private:UpdateNavigation()
end
