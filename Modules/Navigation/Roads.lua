local Private = select(2, ...)

-- A yard walked off the road costs this many yards of road. Roads are the only terrain known, so heading for a nearby
-- road and following it beats cutting across country unless the road makes the walk far longer.
local OffRoad = 3
-- A walk this short goes straight.
local MinRoadWalk = 60

-- [Continent] = { Ways = { Way, ... }, Edges = { [Node] = { Edge, ... } }, NodeCount }, or false with no roads.
local Networks = {}
-- Search scratch, reused between searches.
local Cost, Previous, Via = {}, {}, {}
local HeapCost, HeapNode = {}, {}

-- A way's Line runs from its first node, through its turns, to its second node; Along is the yards to each point.
local function CreateWay(Roads, Row)
    local Nodes = Roads.Nodes
    local From, To = Row[1], Row[2]
    local Line = { Nodes[From * 2 - 1], Nodes[From * 2] }
    for Index = 3, #Row do Line[#Line + 1] = Row[Index] end
    Line[#Line + 1], Line[#Line + 2] = Nodes[To * 2 - 1], Nodes[To * 2]

    local Along = { 0 }
    local MinX, MinY, MaxX, MaxY = Line[1], Line[2], Line[1], Line[2]
    for Index = 3, #Line - 1, 2 do
        local X, Y = Line[Index], Line[Index + 1]
        Along[#Along + 1] = Along[#Along] + math.sqrt((X - Line[Index - 2]) ^ 2 + (Y - Line[Index - 1]) ^ 2)
        MinX, MinY, MaxX, MaxY = math.min(MinX, X), math.min(MinY, Y), math.max(MaxX, X), math.max(MaxY, Y)
    end
    return {
        From = From, To = To, Line = Line, Along = Along, Length = Along[#Along],
        MinX = MinX, MinY = MinY, MaxX = MaxX, MaxY = MaxY,
        EntryDistance = 0, EntryAlong = 0, EntryX = 0, EntryY = 0, EntryTurn = 1,
        ExitDistance = 0, ExitAlong = 0, ExitX = 0, ExitY = 0, ExitTurn = 1,
        isEntry = false, isExit = false,
    }
end

local function GetNetwork(Continent)
    local Network = Networks[Continent]
    if Network ~= nil then return Network end
    local Roads = Private.NavigationRoads[Continent]
    if not Roads then
        Networks[Continent] = false
        return false
    end

    local NodeCount = #Roads.Nodes / 2
    local Ways, Edges = {}, {}
    for Node = 1, NodeCount do Edges[Node] = {} end
    for Index, Row in ipairs(Roads.Ways) do
        local Way = CreateWay(Roads, Row)
        Ways[Index] = Way
        table.insert(Edges[Way.From], { To = Way.To, Cost = Way.Length, Way = Way, isForward = true })
        table.insert(Edges[Way.To], { To = Way.From, Cost = Way.Length, Way = Way, isForward = false })
    end
    -- Links are walked off the road, straight between the two dead ends.
    local Nodes, Links = Roads.Nodes, Roads.Links
    for Index = 1, #Links - 1, 2 do
        local From, To = Links[Index], Links[Index + 1]
        local LinkCost = math.sqrt((Nodes[To * 2 - 1] - Nodes[From * 2 - 1]) ^ 2 + (Nodes[To * 2] - Nodes[From * 2]) ^ 2) * OffRoad
        table.insert(Edges[From], { To = To, Cost = LinkCost })
        table.insert(Edges[To], { To = From, Cost = LinkCost })
    end

    Network = { Ways = Ways, Edges = Edges, Nodes = Nodes, NodeCount = NodeCount }
    Networks[Continent] = Network
    return Network
end

-- The nearest point of a way to (X, Y): its distance, position, yards along the way, and the turn it follows.
local function Project(Way, X, Y)
    local Line, Along = Way.Line, Way.Along
    local BestDistance, BestX, BestY, BestAlong, BestTurn = math.huge, 0, 0, 0, 1
    for Index = 1, #Line - 3, 2 do
        local FromX, FromY = Line[Index], Line[Index + 1]
        local DeltaX, DeltaY = Line[Index + 2] - FromX, Line[Index + 3] - FromY
        local Span = DeltaX * DeltaX + DeltaY * DeltaY
        local Share = Span > 0 and math.max(0, math.min(1, ((X - FromX) * DeltaX + (Y - FromY) * DeltaY) / Span)) or 0
        local PointX, PointY = FromX + DeltaX * Share, FromY + DeltaY * Share
        local Distance = (PointX - X) ^ 2 + (PointY - Y) ^ 2
        if Distance < BestDistance then
            local Turn = (Index + 1) / 2
            BestDistance, BestX, BestY, BestTurn = Distance, PointX, PointY, Turn
            BestAlong = Along[Turn] + Share * (Along[Turn + 1] - Along[Turn])
        end
    end
    return math.sqrt(BestDistance), BestX, BestY, BestAlong, BestTurn
end

-- Whether a way's bounds come within Reach of (X, Y).
local function IsWithin(Way, X, Y, Reach)
    local DeltaX = math.max(Way.MinX - X, 0, X - Way.MaxX)
    local DeltaY = math.max(Way.MinY - Y, 0, Y - Way.MaxY)
    return DeltaX * DeltaX + DeltaY * DeltaY < Reach * Reach
end

local function Push(Size, Node, NodeCost)
    Size = Size + 1
    local Index = Size
    while Index > 1 do
        local Parent = math.floor(Index / 2)
        if HeapCost[Parent] <= NodeCost then break end
        HeapCost[Index], HeapNode[Index] = HeapCost[Parent], HeapNode[Parent]
        Index = Parent
    end
    HeapCost[Index], HeapNode[Index] = NodeCost, Node
    return Size
end

local function Pop(Size)
    local Node, NodeCost = HeapNode[1], HeapCost[1]
    local LastCost, LastNode = HeapCost[Size], HeapNode[Size]
    Size = Size - 1
    local Index = 1
    while true do
        local Child = Index * 2
        if Child > Size then break end
        if Child < Size and HeapCost[Child + 1] < HeapCost[Child] then Child = Child + 1 end
        if HeapCost[Child] >= LastCost then break end
        HeapCost[Index], HeapNode[Index] = HeapCost[Child], HeapNode[Child]
        Index = Child
    end
    HeapCost[Index], HeapNode[Index] = LastCost, LastNode
    return Size, Node, NodeCost
end

-- Adds a way's turns from First to Last, stepping by Step (1 or -1); none when Last is already passed.
local function AddTurns(Path, Way, First, Last, Step)
    local Line = Way.Line
    for Turn = First, Last, Step do
        Path[#Path + 1], Path[#Path + 2] = Line[Turn * 2 - 1], Line[Turn * 2]
    end
end

-- From where the walk joins a way, along it to the node it reaches.
local function AddEntry(Path, Way, Node)
    Path[#Path + 1], Path[#Path + 2] = Way.EntryX, Way.EntryY
    if Node == Way.From then
        AddTurns(Path, Way, Way.EntryTurn, 1, -1)
    else
        AddTurns(Path, Way, Way.EntryTurn + 1, #Way.Along, 1)
    end
end

-- From a node, along a way to where the walk leaves it.
local function AddExit(Path, Way, Node)
    if Node == Way.From then
        AddTurns(Path, Way, 2, Way.ExitTurn, 1)
    else
        AddTurns(Path, Way, #Way.Along - 1, Way.ExitTurn + 1, -1)
    end
    Path[#Path + 1], Path[#Path + 2] = Way.ExitX, Way.ExitY
end

-- The points a walk passes through after (FromX, FromY), as X, Y pairs ending at (ToX, ToY): along the roads when
-- that is quicker than walking straight. Also returns the yards left from each point, at the same index as its X.
function Private:FindNavigationRoadPath(Continent, FromX, FromY, ToX, ToY)
    local Direct = math.sqrt((ToX - FromX) ^ 2 + (ToY - FromY) ^ 2)
    local Network = Direct >= MinRoadWalk and GetNetwork(Continent)
    if not Network then return { ToX, ToY }, { 0 } end

    -- A road further than the walk itself from either end cannot beat walking straight.
    local BestCost, BestNode, BestWay = Direct * OffRoad, nil, nil
    local Size = 0
    for Node = 1, Network.NodeCount do Cost[Node] = math.huge end

    for _, Way in ipairs(Network.Ways) do
        Way.isEntry, Way.isExit = false, false
        if IsWithin(Way, FromX, FromY, Direct) then
            local Distance, X, Y, Along, Turn = Project(Way, FromX, FromY)
            if Distance < Direct then
                Way.isEntry, Way.EntryDistance, Way.EntryX, Way.EntryY, Way.EntryAlong, Way.EntryTurn = true, Distance, X, Y, Along, Turn
                for Side = 1, 2 do
                    local Node = Side == 1 and Way.From or Way.To
                    local NodeCost = Distance * OffRoad + (Side == 1 and Along or Way.Length - Along)
                    if NodeCost < Cost[Node] then
                        Cost[Node], Previous[Node], Via[Node] = NodeCost, 0, Way
                        Size = Push(Size, Node, NodeCost)
                    end
                end
            end
        end
        if IsWithin(Way, ToX, ToY, Direct) then
            local Distance, X, Y, Along, Turn = Project(Way, ToX, ToY)
            if Distance < Direct then
                Way.isExit, Way.ExitDistance, Way.ExitX, Way.ExitY, Way.ExitAlong, Way.ExitTurn = true, Distance, X, Y, Along, Turn
                -- Joining and leaving the same way.
                if Way.isEntry then
                    local WayCost = (Way.EntryDistance + Distance) * OffRoad + math.abs(Way.EntryAlong - Along)
                    if WayCost < BestCost then BestCost, BestNode, BestWay = WayCost, 0, Way end
                end
            end
        end
    end

    local Edges = Network.Edges
    while Size > 0 do
        local Node, NodeCost
        Size, Node, NodeCost = Pop(Size)
        if NodeCost >= BestCost then break end
        if NodeCost <= Cost[Node] then
            for _, Edge in ipairs(Edges[Node]) do
                local Way = Edge.Way
                -- Leaving the roads along this way, toward the end of the walk.
                if Way and Way.isExit then
                    local ExitCost = NodeCost + Way.ExitDistance * OffRoad + (Node == Way.From and Way.ExitAlong or Way.Length - Way.ExitAlong)
                    if ExitCost < BestCost then BestCost, BestNode, BestWay = ExitCost, Node, Way end
                end
                local To, ToCost = Edge.To, NodeCost + Edge.Cost
                if ToCost < Cost[To] then
                    Cost[To], Previous[To], Via[To] = ToCost, Node, Edge
                    Size = Push(Size, To, ToCost)
                end
            end
        end
    end

    local Path = {}
    if BestWay and BestNode == 0 then
        -- Along one way: join it, follow it, leave it.
        Path[1], Path[2] = BestWay.EntryX, BestWay.EntryY
        if BestWay.EntryAlong <= BestWay.ExitAlong then
            AddTurns(Path, BestWay, BestWay.EntryTurn + 1, BestWay.ExitTurn, 1)
        else
            AddTurns(Path, BestWay, BestWay.EntryTurn, BestWay.ExitTurn + 1, -1)
        end
        Path[#Path + 1], Path[#Path + 2] = BestWay.ExitX, BestWay.ExitY
    elseif BestWay and BestNode then
        -- The nodes walked through, from the last back to the first.
        local Chain, Node = {}, BestNode
        while Node ~= 0 do
            Chain[#Chain + 1] = Node
            Node = Previous[Node]
        end
        local First = Chain[#Chain]
        AddEntry(Path, Via[First], First)
        local Nodes = Network.Nodes
        for Index = #Chain - 1, 1, -1 do
            local Edge = Via[Chain[Index]]
            if Edge.Way then
                if Edge.isForward then AddTurns(Path, Edge.Way, 2, #Edge.Way.Along, 1) else AddTurns(Path, Edge.Way, #Edge.Way.Along - 1, 1, -1) end
            else
                Path[#Path + 1], Path[#Path + 2] = Nodes[Edge.To * 2 - 1], Nodes[Edge.To * 2]
            end
        end
        AddExit(Path, BestWay, BestNode)
    end
    Path[#Path + 1], Path[#Path + 2] = ToX, ToY

    local Left, Yards = { [#Path - 1] = 0 }, 0
    for Index = #Path - 3, 1, -2 do
        Yards = Yards + math.sqrt((Path[Index + 2] - Path[Index]) ^ 2 + (Path[Index + 3] - Path[Index + 1]) ^ 2)
        Left[Index] = Yards
    end
    return Path, Left
end
