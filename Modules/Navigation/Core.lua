local Private = select(2, ...)

-- Yards the player moves before the route is planned again, and seconds between those checks.
local ReplanDistance, CheckInterval = 25, 0.5
local MaxSteps = 5
-- A walk's next turn is reached within TurnDistance yards, or passed once the player is beyond it within PassDistance.
local TurnDistance, PassDistance = 15, 30

local GoalVector = CreateVector2D(0, 0)
local State = {
    GoalContinent = 0, GoalX = 0, GoalY = 0, GoalName = "",
    PlanContinent = -1, PlanX = 0, PlanY = 0,
    Elapsed = 0, Distance = -1, PathIndex = 1,
    isDirty = false, isOnTaxi = false, isMinimapRotating = false, showMinimapLine = false,
    hasDirection = false, hasMinimapLine = false, hasHinted = false,
}

-- The super tracked quest, or the map pin when that is tracked instead. A quest's own marker comes before its waypoint.
local function GetGoalMapPosition()
    local QuestID = C_SuperTrack.GetSuperTrackedQuestID()
    if QuestID and QuestID > 0 then
        local Name = C_QuestLog.GetTitleForQuestID(QuestID) or "Quest"
        local MapID = GetQuestUiMapID(QuestID, true)
        local Quests = MapID and MapID > 0 and C_QuestLog.GetQuestsOnMap(MapID)
        if Quests then
            for _, Quest in ipairs(Quests) do
                if Quest.questID == QuestID then return MapID, Quest.x, Quest.y, Name end
            end
        end
        local WaypointMapID, X, Y = C_QuestLog.GetNextWaypoint(QuestID)
        return WaypointMapID, X, Y, Name
    end

    local Waypoint = C_SuperTrack.IsSuperTrackingUserWaypoint() and C_Map.GetUserWaypoint()
    if Waypoint then return Waypoint.uiMapID, Waypoint.position.x, Waypoint.position.y, "Map Pin" end
end

local function GetGoalWorldPosition()
    local MapID, X, Y, Name = GetGoalMapPosition()
    if not MapID or not X then return end
    GoalVector:SetXY(X, Y)
    local Continent, Position = C_Map.GetWorldPosFromMapPos(MapID, GoalVector)
    if not Position then return end
    local WorldX, WorldY = Position:GetXY()
    return Continent, WorldX, WorldY, Name
end

local function SetDirectionShown(isShown)
    if State.hasDirection == isShown then return end
    State.hasDirection = isShown
    Private.NavigationArrow.Arrow:SetShown(isShown)
    Private.NavigationArrow.Distance:SetShown(isShown)
    if not isShown then Private:HideNavigationMinimapLine() end
end

local function ClearRoute()
    Private.NavigationRoute = nil
    Private.NavigationArrow:Hide()
    Private:HideNavigationMinimapLine()
    Private:DrawNavigationMap()
end

-- Plans the route again once the goal has changed or the player has moved far enough.
local function CheckRoute(Continent, X, Y)
    State.isMinimapRotating = GetCVarBool("rotateMinimap")
    State.isOnTaxi = UnitOnTaxi("player")
    if State.isOnTaxi then return end

    local DeltaX, DeltaY = X - State.PlanX, Y - State.PlanY
    if not State.isDirty and Continent == State.PlanContinent and DeltaX * DeltaX + DeltaY * DeltaY <= ReplanDistance * ReplanDistance then return end

    local KnownTaxiNodes = Private.DB.char.Navigation.KnownTaxiNodes
    State.isDirty, State.PlanContinent, State.PlanX, State.PlanY = false, Continent, X, Y

    local Route = Private:PlanNavigationRoute(Continent, X, Y, State.GoalContinent, State.GoalX, State.GoalY, State.GoalName, KnownTaxiNodes)
    if not Route then ClearRoute() return end

    -- The current step in white, the ones after it in grey.
    local Steps = {}
    for Index = 1, math.min(#Route, MaxSteps) do
        Steps[Index] = (Index == 1 and "|cFFFFFFFF" or "|cFF808080") .. Route[Index].Mode .. ": " .. Route[Index].Name .. "|r"
    end

    Private.NavigationRoute = Route
    State.PathIndex = 1
    Private.NavigationArrow.Steps:SetText(table.concat(Steps, "\n"))
    Private.NavigationArrow:Show()
    Private:DrawNavigationMap()

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
        CheckRoute(Continent, X, Y)
    end

    local Route = Private.NavigationRoute
    if not Route then return end

    local Leg = Route[1]
    local Target = Leg.Points[#Leg.Points]
    local Facing = GetPlayerFacing()
    if State.isOnTaxi or Target[1] ~= Continent or not Facing or issecretvalue(Facing) then SetDirectionShown(false) return end
    SetDirectionShown(true)

    -- A walk heads for the next turn of its path.
    local Path, Index = Leg.Path, State.PathIndex
    local TargetX, TargetY, Left = Target[2], Target[3], 0
    if Path then
        while Index < #Path - 1 do
            local TurnX, TurnY = Path[Index] - X, Path[Index + 1] - Y
            local TurnDistanceSquared = TurnX * TurnX + TurnY * TurnY
            local isPast = (Path[Index + 2] - Path[Index]) * TurnX + (Path[Index + 3] - Path[Index + 1]) * TurnY < 0
            if TurnDistanceSquared >= TurnDistance * TurnDistance and not (isPast and TurnDistanceSquared < PassDistance * PassDistance) then break end
            Index = Index + 2
        end
        State.PathIndex = Index
        TargetX, TargetY, Left = Path[Index], Path[Index + 1], Leg.PathLeft[Index]
    end

    local DeltaX, DeltaY = TargetX - X, TargetY - Y
    local Distance = math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY) + Left
    local Yards = math.floor(Distance + 0.5)
    if Yards ~= State.Distance then
        State.Distance = Yards
        Private.NavigationArrow.Distance:SetFormattedText("%d yd", Yards)
    end
    Private.NavigationArrow.Arrow:SetRotation(math.atan2(DeltaY, DeltaX) - Facing)

    local hasMinimapLine = State.showMinimapLine and Path ~= nil
    if hasMinimapLine then
        Private:UpdateNavigationMinimapLine(X, Y, Path, Index, Distance, State.isMinimapRotating and Facing or 0)
    elseif State.hasMinimapLine then
        Private:HideNavigationMinimapLine()
    end
    State.hasMinimapLine = hasMinimapLine
end

local function UpdateGoal()
    local Continent, X, Y, Name = GetGoalWorldPosition()
    if not Continent then
        Private.NavigationFrame:SetScript("OnUpdate", nil)
        ClearRoute()
        return
    end

    State.GoalContinent, State.GoalX, State.GoalY, State.GoalName = Continent, X, Y, Name
    State.isDirty, State.Elapsed = true, CheckInterval
    Private.NavigationFrame:SetScript("OnUpdate", Navigation_OnUpdate)
end

local function Navigation_OnEvent(_, Event)
    if Event ~= "TAXIMAP_OPENED" then UpdateGoal() return end

    -- A flight master lists the nodes on its continent; the ones the character has are CURRENT or REACHABLE.
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
    State.showMinimapLine = DB.MinimapLine

    if DB.Enable then
        NavigationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        NavigationFrame:RegisterEvent("SUPER_TRACKING_CHANGED")
        NavigationFrame:RegisterEvent("USER_WAYPOINT_UPDATED")
        NavigationFrame:RegisterEvent("QUEST_POI_UPDATE")
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
    Private:CreateNavigationLines()
    Private:CreateNavigationFlightTimer()
    Private:UpdateNavigation()
end
