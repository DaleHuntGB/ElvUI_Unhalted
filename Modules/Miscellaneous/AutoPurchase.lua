local Private = select(2, ...)

-- [ItemID] = Target, for items where buying whole bundles overshoots the target.
local Pending = {}
-- [ItemID] = true once selling the excess has started.
local Trimming = {}

local function FindSmallestStack(ItemID)
    local BestBag, BestSlot, BestCount
    for Bag = Enum.BagIndex.Backpack, NUM_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local Info = C_Container.GetContainerItemInfo(Bag, Slot)
            if Info and Info.itemID == ItemID and not Info.isLocked and (not BestCount or Info.stackCount < BestCount) then
                BestBag, BestSlot, BestCount = Bag, Slot, Info.stackCount
            end
        end
    end
    return BestBag, BestSlot, BestCount
end

local function SellExcess(APF)
    if CursorHasItem() then return end
    for ItemID, Target in pairs(Pending) do
        local Excess = C_Item.GetItemCount(ItemID) - Target
        if Excess > 0 then
            local Bag, Slot, StackCount = FindSmallestStack(ItemID)
            if not Bag then return end
            Trimming[ItemID] = true
            if StackCount <= Excess then
                C_Container.PickupContainerItem(Bag, Slot)
            else
                C_Container.SplitContainerItem(Bag, Slot, Excess)
            end
            SellCursorItem()
            return
        elseif Trimming[ItemID] then
            Pending[ItemID] = nil
            Trimming[ItemID] = nil
        end
    end
    if not next(Pending) then APF:UnregisterEvent("BAG_UPDATE_DELAYED") end
end

local function PurchaseItem(Index, ItemID, Target, Info, Money)
    local Owned = C_Item.GetItemCount(ItemID)
    if Owned >= Target then return Money end

    local BundleSize = math.max(Info.stackCount, 1)
    local SellPrice = select(11, C_Item.GetItemInfo(ItemID))
    -- Excess can only be removed by selling it back, so never overshoot items the vendor won't buy.
    local Bundles = (SellPrice and SellPrice > 0) and math.ceil((Target - Owned) / BundleSize) or math.floor((Target - Owned) / BundleSize)
    if Info.numAvailable >= 0 then Bundles = math.min(Bundles, Info.numAvailable) end
    if Info.price > 0 then Bundles = math.min(Bundles, math.floor(Money / Info.price)) end
    if Bundles <= 0 then return Money end

    local Remaining = Bundles * BundleSize
    local MaxPerPurchase = GetMerchantItemMaxStack(Index)
    MaxPerPurchase = math.max(MaxPerPurchase - MaxPerPurchase % BundleSize, BundleSize)
    if Owned + Remaining > Target then Pending[ItemID] = Target end

    while Remaining > 0 do
        local Quantity = math.min(Remaining, MaxPerPurchase)
        BuyMerchantItem(Index, Quantity)
        Remaining = Remaining - Quantity
    end

    return Money - Bundles * Info.price
end

local function PurchaseItems(APF)
    local Items = Private.DB.global.Miscellaneous.AutoPurchase.Items
    if not next(Items) then return end

    local Money = GetMoney()
    for Index = 1, GetMerchantNumItems() do
        local ItemID = GetMerchantItemID(Index)
        local Info = C_MerchantFrame.GetItemInfo(Index)
        local Target = ItemID and (Items[ItemID] or (Info.name and Items[strlower(Info.name)]))
        if Target and Info.isPurchasable and not Info.hasExtendedCost then
            Money = PurchaseItem(Index, ItemID, Target, Info, Money)
        end
    end

    if next(Pending) then APF:RegisterEvent("BAG_UPDATE_DELAYED") end
end

-- Gives other vendor automation (auto repair, selling junk) time to settle, and item data time to load.
local PURCHASE_DELAY = 0.5
local PurchaseTimer

local function PurchaseTimer_OnFinished()
    PurchaseTimer = nil
    PurchaseItems(Private.AutoPurchaseFrame)
end

local function ResetAutoPurchase(APF)
    if PurchaseTimer then
        PurchaseTimer:Cancel()
        PurchaseTimer = nil
    end
    APF:UnregisterEvent("BAG_UPDATE_DELAYED")
    wipe(Pending)
    wipe(Trimming)
end

local function AutoPurchase_OnEvent(APF, Event)
    if Event == "MERCHANT_SHOW" then
        -- Sell prices decide whether a bundle may overshoot, so make sure they are loaded before buying.
        for Item in pairs(Private.DB.global.Miscellaneous.AutoPurchase.Items) do
            if type(Item) == "number" then C_Item.RequestLoadItemDataByID(Item) end
        end
        ResetAutoPurchase(APF)
        PurchaseTimer = C_Timer.NewTimer(PURCHASE_DELAY, PurchaseTimer_OnFinished)
    elseif Event == "BAG_UPDATE_DELAYED" then
        SellExcess(APF)
    elseif Event == "MERCHANT_CLOSED" then
        ResetAutoPurchase(APF)
    end
end

function Private:SetupAutoPurchase()
    if not Private.isForever then return end

    local AutoPurchaseFrame = CreateFrame("Frame")
    AutoPurchaseFrame:SetScript("OnEvent", AutoPurchase_OnEvent)
    Private.AutoPurchaseFrame = AutoPurchaseFrame

    Private:UpdateAutoPurchase()
end

function Private:UpdateAutoPurchase()
    local AutoPurchaseFrame = Private.AutoPurchaseFrame
    if not AutoPurchaseFrame then return end

    if Private.DB.global.Miscellaneous.AutoPurchase.Enable then
        AutoPurchaseFrame:RegisterEvent("MERCHANT_SHOW")
        AutoPurchaseFrame:RegisterEvent("MERCHANT_CLOSED")
    else
        ResetAutoPurchase(AutoPurchaseFrame)
        AutoPurchaseFrame:UnregisterEvent("MERCHANT_SHOW")
        AutoPurchaseFrame:UnregisterEvent("MERCHANT_CLOSED")
    end
end
