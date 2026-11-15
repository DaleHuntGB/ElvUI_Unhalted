local Private = select(2, ...)

local ProximityInterval, ResortDistance = 1, 10

local Blocks, QuestBlocks, Placement, Applied = {}, {}, {}, {}
local BlockIndex, BlockValue, BlockComplete, QuestLevels = {}, {}, {}, {}
local isDescending = false
local State = { isHooked = false, Ticker = false, SortX = 0, SortY = 0 }

local function GetQuestLevel(QuestID)
    local Level = C_QuestLog.GetQuestDifficultyLevel(QuestID)
    if Level > 0 then QuestLevels[QuestID] = Level end
    return QuestLevels[QuestID] or false
end

local function GetQuestDistance(QuestID)
    local DistanceSq, isOnContinent = C_QuestLog.GetDistanceSqToQuest(QuestID)
    if issecretvalue(DistanceSq) or issecretvalue(isOnContinent) or not isOnContinent then return false end
    return DistanceSq
end

local function IsQuestBlockComplete(Block)
    if Block.cached then return BlockComplete[Block] or false end
    return C_QuestLog.IsComplete(Block.id)
end

local function CompareQuestBlocks(BlockA, BlockB)
    local CompleteA, CompleteB = BlockComplete[BlockA], BlockComplete[BlockB]
    if CompleteA ~= CompleteB then return CompleteB end
    local ValueA, ValueB = BlockValue[BlockA], BlockValue[BlockB]
    if ValueA == ValueB then return BlockIndex[BlockA] < BlockIndex[BlockB] end
    if not ValueA then return false end
    if not ValueB then return true end
    if isDescending then return ValueA > ValueB end
    return ValueA < ValueB
end

local function IsPlacementApplied()
    if #Placement ~= #Applied then return false end
    for Index = 1, #Placement do
        if Placement[Index] ~= Applied[Index] then return false end
    end
    return true
end

local function CollectQuestBlocks(Module)
    local DB = Private.DB.global.Blizzard.ObjectiveTracker.Sorting
    local isCompletedLast = DB.Enable and DB.CompletedLast
    wipe(Blocks)
    wipe(QuestBlocks)

    local Block = Module.firstBlock
    while Block do
        Blocks[#Blocks + 1] = Block
        if type(Block.id) == "number" then
            QuestBlocks[#QuestBlocks + 1] = Block
            BlockIndex[Block], BlockComplete[Block] = #Blocks, isCompletedLast and IsQuestBlockComplete(Block) or false
        end
        Block = Block.nextBlock
    end
end

local function PlaceQuestBlocks(Module, isForced)
    local QuestCount = #QuestBlocks
    if QuestCount < 2 then return end

    local DB = Private.DB.global.Blizzard.ObjectiveTracker.Sorting
    local GetValue = DB.SortBy == "PROXIMITY" and GetQuestDistance or GetQuestLevel
    for Index = 1, QuestCount do
        local Block = QuestBlocks[Index]
        BlockValue[Block] = DB.Enable and GetValue(Block.id)
    end
    isDescending = DB.Order == "DESCENDING"
    table.sort(QuestBlocks, CompareQuestBlocks)

    wipe(Placement)
    local QuestIndex = 0
    for Index = 1, #Blocks do
        local Slot = Blocks[Index]
        if type(Slot.id) == "number" then
            QuestIndex = QuestIndex + 1
            Slot = QuestBlocks[QuestIndex]
        end
        Placement[Index] = Slot
    end
    if not isForced and IsPlacementApplied() then return end

    local Anchor, RelativePoint, OffsetY = Module.ContentsFrame, "TOP", Module.fromHeaderOffsetY
    for Index = 1, #Placement do
        local Placed = Placement[Index]
        Placed:SetPoint("TOP", Anchor, RelativePoint, 0, OffsetY)
        Anchor, RelativePoint, OffsetY = Placed, "BOTTOM", Module.fromBlockOffsetY
    end
    Placement, Applied = Applied, Placement
end

local function AnchorQuestBlocks(Module)
    CollectQuestBlocks(Module)
    PlaceQuestBlocks(Module, true)
end

local function SortQuestObjectiveTracker(Module)
    if not Private.DB.global.Blizzard.ObjectiveTracker.Sorting.Enable then return end
    AnchorQuestBlocks(Module)
end

local function RefreshProximity()
    if not QuestObjectiveTracker:IsVisible() then return end
    local X, Y = UnitPosition("player")
    if issecretvalue(X) or not X then return end
    local DeltaX, DeltaY = X - State.SortX, Y - State.SortY
    if DeltaX * DeltaX + DeltaY * DeltaY < ResortDistance * ResortDistance then return end
    State.SortX, State.SortY = X, Y
    PlaceQuestBlocks(QuestObjectiveTracker, false)
end

local function UpdateProximityTicker()
    local DB = Private.DB.global.Blizzard.ObjectiveTracker.Sorting
    local isProximity = DB.Enable and DB.SortBy == "PROXIMITY"
    if isProximity and not State.Ticker then
        State.Ticker = C_Timer.NewTicker(ProximityInterval, RefreshProximity)
    elseif not isProximity and State.Ticker then
        State.Ticker:Cancel()
        State.Ticker = false
    end
end

function Private:SetupObjectiveTracker()
    if not Private.DB.global.Blizzard.ObjectiveTracker.Sorting.Enable then return end
    Private:UpdateObjectiveTracker()
end

function Private:UpdateObjectiveTracker()
    if Private.DB.global.Blizzard.ObjectiveTracker.Sorting.Enable and not State.isHooked then
        hooksecurefunc(QuestObjectiveTracker, "Update", SortQuestObjectiveTracker)
        State.isHooked = true
    end
    UpdateProximityTicker()
    AnchorQuestBlocks(QuestObjectiveTracker)
end
