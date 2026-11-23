local Private = select(2, ...)

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
    if Private:IsSecret(DistanceSq) or Private:IsSecret(isOnContinent) or not isOnContinent then return false end
    return DistanceSq
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
    local DB = Private.DB.global.Blizzard.ObjectiveTracker.Sorting
    local isCompletedLast = DB.Enable and DB.CompletedLast
    wipe(Blocks)
    wipe(QuestBlocks)

    local Block = Module.firstBlock
    while Block do
        Blocks[#Blocks + 1] = Block
        if type(Block.id) == "number" then
            QuestBlocks[#QuestBlocks + 1] = Block
            BlockIndex[Block] = #Blocks
            if isCompletedLast and Block.cached then
                BlockComplete[Block] = BlockComplete[Block] or false
            else
                BlockComplete[Block] = isCompletedLast and C_QuestLog.IsComplete(Block.id) or false
            end
        end
        Block = Block.nextBlock
    end
    PlaceQuestBlocks(Module, true)
end

local function SortQuestObjectiveTracker(Module)
    if not Private.DB.global.Blizzard.ObjectiveTracker.Sorting.Enable then return end
    AnchorQuestBlocks(Module)
end

local function RefreshProximity()
    if not QuestObjectiveTracker:IsVisible() then return end
    local X, Y = UnitPosition("player")
    if Private:IsSecret(X) or not X then return end
    local DeltaX, DeltaY = X - State.SortX, Y - State.SortY
    if DeltaX * DeltaX + DeltaY * DeltaY < 100 then return end
    State.SortX, State.SortY = X, Y
    PlaceQuestBlocks(QuestObjectiveTracker, false)
end

function Private:SetupObjectiveTracker()
    if not Private.DB.global.Blizzard.ObjectiveTracker.Sorting.Enable then return end
    Private:UpdateObjectiveTracker()
end

function Private:UpdateObjectiveTracker()
    local DB = Private.DB.global.Blizzard.ObjectiveTracker.Sorting
    if DB.Enable and not State.isHooked then
        hooksecurefunc(QuestObjectiveTracker, "Update", SortQuestObjectiveTracker)
        State.isHooked = true
    end

    local isProximity = DB.Enable and DB.SortBy == "PROXIMITY"
    if isProximity and not State.Ticker then
        State.Ticker = C_Timer.NewTicker(1, RefreshProximity)
    elseif not isProximity and State.Ticker then
        State.Ticker:Cancel()
        State.Ticker = false
    end
    AnchorQuestBlocks(QuestObjectiveTracker)
end
