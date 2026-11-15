local Private = select(2, ...)

local PlayerPoint = { 0, 0, 0, "", Zone = 0, Penalty = 0 }
local GoalPoint = { 0, 0, 0, "", Zone = 0, Penalty = 0 }
local Points = { PlayerPoint, GoalPoint }
local GoalPoints = { GoalPoint }
local PointByTaxiNode, ZonePoints, ZoneNames = {}, { [0] = {} }, {}
local Cost, Previous, Mode, Via, Visited = {}, {}, {}, {}, {}
local MapVector = CreateVector2D(0, 0)

local RunSpeed = 5.5
local TerrainPenalty = 20
local ContinentMaps = { [0] = 1415, [1] = 1414 }
local CityZones = { [1453] = 1429, [1454] = 1411, [1455] = 1426, [1456] = 1412, [1457] = 1438, [1458] = 1420 }

local function GetLand(Continent, X, Y)
    if Continent ~= 1 or X < 8400 or Y < 0 then return Continent end
    return X > 9000 and "Teldrassil" or "Rut'theran"
end

local function GetZone(Continent, X, Y)
    local ContinentMap = ContinentMaps[Continent]
    if not ContinentMap then return 0 end
    MapVector:SetXY(X, Y)
    local _, Position = C_Map.GetMapPosFromWorldPos(Continent, MapVector, ContinentMap)
    local Info = Position and C_Map.GetMapInfoAtPosition(ContinentMap, Position:GetXY())
    if not Info or Info.mapID == ContinentMap then return 0 end
    return CityZones[Info.mapID] or Info.mapID
end

local function GetZoneName(Zone)
    ZoneNames[Zone] = ZoneNames[Zone] or C_Map.GetMapInfo(Zone).name
    return ZoneNames[Zone]
end

local function AddToZone(Zone, Point)
    local ZoneList = ZonePoints[Zone] or {}
    ZoneList[#ZoneList + 1] = Point
    ZonePoints[Zone] = ZoneList
end

local function AddPoint(Point)
    Point.Land = GetLand(Point[1], Point[2], Point[3])
    Point.Zone = Point.Zone or GetZone(Point[1], Point[2], Point[3])
    Point.Penalty = Point.Penalty or 0
    Points[#Points + 1] = Point
    AddToZone(Point.Zone, Point)
    if Point.OtherZone then AddToZone(Point.OtherZone, Point) end
    return Point
end

local function Relax(From, To, Seconds, TravelMode, Zone)
    local NewCost = Cost[From] + Seconds
    if NewCost >= Cost[To] then return end
    Cost[To], Previous[To], Mode[To], Via[To] = NewCost, From, TravelMode, Zone
end

local function RelaxRuns(Index, Point, Others, Zone, KnownTaxiNodes)
    if not Others then return end
    for Position = 1, #Others do
        local Other = Others[Position]
        if not Visited[Other.Index] and Other.Land == Point.Land and (not Other.TaxiNodeID or KnownTaxiNodes[Other.TaxiNodeID]) then
            local DeltaX, DeltaY = Other[2] - Point[2], Other[3] - Point[3]
            Relax(Index, Other.Index, math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY) / RunSpeed + Other.Penalty, "Run", Zone ~= 0 and Zone or Other.Zone)
        end
    end
end

local function Search(KnownTaxiNodes, isZoned)
    for Index = 1, #Points do Cost[Index], Visited[Index] = math.huge, false end
    Cost[1] = 0

    while true do
        local Index, NearestCost = 0, math.huge
        for Other = 1, #Points do
            if not Visited[Other] and Cost[Other] < NearestCost then Index, NearestCost = Other, Cost[Other] end
        end
        if Index == 0 then return false end
        if Index == 2 then return true end
        Visited[Index] = true
        local Point = Points[Index]
        local Zone, GoalZone = Point.Zone, GoalPoint.Zone

        if not isZoned or (Zone == 0 and Mode[Index] ~= "Run") then
            RelaxRuns(Index, Point, Points, Zone, KnownTaxiNodes)
        elseif Zone ~= 0 then
            RelaxRuns(Index, Point, ZonePoints[Zone], Zone, KnownTaxiNodes)
            RelaxRuns(Index, Point, ZonePoints[Point.OtherZone], Point.OtherZone, KnownTaxiNodes)
            RelaxRuns(Index, Point, ZonePoints[0], Zone, KnownTaxiNodes)
            if GoalZone == 0 or GoalZone == Zone or GoalZone == Point.OtherZone then RelaxRuns(Index, Point, GoalPoints, Zone, KnownTaxiNodes) end
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
end

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

        for _, Gateway in ipairs(Private.NavigationGateways) do
            AddPoint({ Gateway[1], Gateway[2], Gateway[3], Zone = Gateway[4], OtherZone = Gateway[5], Penalty = Gateway[6] and TerrainPenalty or 0, isGateway = true })
        end

        for Index, Point in ipairs(Points) do Point.Index = Index end
    end

    PlayerPoint[1], PlayerPoint[2], PlayerPoint[3], PlayerPoint.Land, PlayerPoint.Zone = Continent, X, Y, GetLand(Continent, X, Y), GetZone(Continent, X, Y)
    GoalPoint[1], GoalPoint[2], GoalPoint[3], GoalPoint[4], GoalPoint.Land, GoalPoint.Zone = GoalContinent, GoalX, GoalY, GoalName, GetLand(GoalContinent, GoalX, GoalY), GetZone(GoalContinent, GoalX, GoalY)

    if not Search(KnownTaxiNodes, true) and not Search(KnownTaxiNodes, false) then return end

    local Legs = {}
    local Index = 2
    while Index ~= 1 do
        local From, TravelMode, Point = Previous[Index], Mode[Index], Points[Index]
        local NextLeg = Legs[1]
        if NextLeg and NextLeg.Mode == TravelMode and TravelMode == "Flight Path" then
            table.insert(NextLeg.Points, 1, Points[From])
        else
            local Boarding = TravelMode == "Run" and NextLeg and (NextLeg.Mode == "Flight Path" and " Flight Master" or " " .. NextLeg.Mode) or ""
            local Name = Point.isGateway and "Through " .. GetZoneName(Via[Index]) or Point[4] .. Boarding
            table.insert(Legs, 1, { Mode = TravelMode, Name = Name, Points = { Points[From], Point } })
        end
        Index = From
    end
    return Legs
end
