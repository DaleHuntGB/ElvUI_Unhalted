local Private = select(2, ...)

-- Points are { Continent, X, Y, Name }, matching the rows in Data.lua.
local PlayerPoint = { 0, 0, 0, "" }
local GoalPoint = { 0, 0, 0, "" }
local Points = { PlayerPoint, GoalPoint }
local PointByTaxiNode = {}
local Cost, Previous, Mode, Visited = {}, {}, {}, {}

-- Runs are straight lines, so they are costed slower than the 7 yards a second a player runs at.
local RunSpeed = 5.5
-- A run this short at the start of a route is left out, so standing beside a flight master reads as "fly".
local SkipRunDistance = 15

-- Teldrassil and Rut'theran Village are cut off from each other and from the rest of Kalimdor.
local function GetLand(Continent, X, Y)
    if Continent ~= 1 or X < 8400 or Y < 0 then return Continent end
    return X > 9000 and "Teldrassil" or "Rut'theran"
end

local function AddPoint(Point)
    Point.Land = GetLand(Point[1], Point[2], Point[3])
    Points[#Points + 1] = Point
    return Point
end

local function Relax(From, To, Seconds, TravelMode)
    local NewCost = Cost[From] + Seconds
    if NewCost >= Cost[To] then return end
    Cost[To], Previous[To], Mode[To] = NewCost, From, TravelMode
end

-- Returns the legs from the player to the goal, each { Mode, Name, Points }, or nil when there is no way there.
function Private:PlanNavigationRoute(Continent, X, Y, GoalContinent, GoalX, GoalY, GoalName, KnownTaxiNodes)
    if #Points == 2 then
        local Faction = UnitFactionGroup("player") == "Horde" and 2 or 1

        for TaxiNodeID, TaxiNode in pairs(Private.NavigationTaxiNodes) do
            if bit.band(TaxiNode[5], Faction) ~= 0 then
                TaxiNode.TaxiNodeID = TaxiNodeID
                TaxiNode.Flights = Private.NavigationTaxiPaths[TaxiNodeID]
                PointByTaxiNode[TaxiNodeID] = AddPoint(TaxiNode)
            end
        end

        for _, Link in ipairs(Private.NavigationLinks) do
            if bit.band(Link[2], Faction) ~= 0 then
                local From = AddPoint(Link[3])
                From.Links = { { Mode = Link[1], To = AddPoint(Link[4]), Seconds = Link[5] } }
            end
        end

        for Index, Point in ipairs(Points) do Point.Index = Index end
    end

    PlayerPoint[1], PlayerPoint[2], PlayerPoint[3], PlayerPoint.Land = Continent, X, Y, GetLand(Continent, X, Y)
    GoalPoint[1], GoalPoint[2], GoalPoint[3], GoalPoint[4], GoalPoint.Land = GoalContinent, GoalX, GoalY, GoalName, GetLand(GoalContinent, GoalX, GoalY)

    -- Shortest path from the player (1) to the goal (2).
    for Index = 1, #Points do Cost[Index], Visited[Index] = math.huge, false end
    Cost[1] = 0

    while true do
        local Index, NearestCost = 0, math.huge
        for Other = 1, #Points do
            if not Visited[Other] and Cost[Other] < NearestCost then Index, NearestCost = Other, Cost[Other] end
        end
        if Index == 0 then return end
        if Index == 2 then break end
        Visited[Index] = true
        local Point = Points[Index]

        for Other = 2, #Points do
            local OtherPoint = Points[Other]
            if not Visited[Other] and OtherPoint.Land == Point.Land and (not OtherPoint.TaxiNodeID or KnownTaxiNodes[OtherPoint.TaxiNodeID]) then
                local DeltaX, DeltaY = OtherPoint[2] - Point[2], OtherPoint[3] - Point[3]
                Relax(Index, Other, math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY) / RunSpeed, "Run")
            end
        end

        if Point.Flights and KnownTaxiNodes[Point.TaxiNodeID] then
            for TaxiNodeID, Seconds in pairs(Point.Flights) do
                local OtherPoint = PointByTaxiNode[TaxiNodeID]
                if OtherPoint and KnownTaxiNodes[TaxiNodeID] then Relax(Index, OtherPoint.Index, Seconds, "Flight Path") end
            end
        end

        if Point.Links then
            for _, Link in ipairs(Point.Links) do Relax(Index, Link.To.Index, Link.Seconds, Link.Mode) end
        end
    end

    -- Walk back from the goal, giving the legs in travel order. Connected flights become one leg.
    local Legs = {}
    local Index = 2
    while Index ~= 1 do
        local From, TravelMode = Previous[Index], Mode[Index]
        local NextLeg = Legs[1]
        if NextLeg and NextLeg.Mode == TravelMode and TravelMode == "Flight Path" then
            table.insert(NextLeg.Points, 1, Points[From])
        else
            -- A run that ends where the next leg starts is named after what is boarded there.
            local Boarding = TravelMode == "Run" and NextLeg and (NextLeg.Mode == "Flight Path" and " Flight Master" or " " .. NextLeg.Mode) or ""
            table.insert(Legs, 1, { Mode = TravelMode, Name = Points[Index][4] .. Boarding, Points = { Points[From], Points[Index] } })
        end
        Index = From
    end

    local FirstLeg = Legs[1]
    local DeltaX, DeltaY = FirstLeg.Points[2][2] - X, FirstLeg.Points[2][3] - Y
    if #Legs > 1 and FirstLeg.Mode == "Run" and DeltaX * DeltaX + DeltaY * DeltaY < SkipRunDistance * SkipRunDistance then table.remove(Legs, 1) end
    return Legs
end
