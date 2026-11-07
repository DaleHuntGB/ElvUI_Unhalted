local Private = select(2, ...)

local PURCHASE_DELAY = 0.5

local function DeleteItems(ItemID, Amount)
    local Stacks = {}
    for Bag = Enum.BagIndex.Backpack, NUM_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local Info = C_Container.GetContainerItemInfo(Bag, Slot)
            if Info and Info.itemID == ItemID and not Info.isLocked then
                Stacks[#Stacks + 1] = { Bag = Bag, Slot = Slot, Count = Info.stackCount }
            end
        end
    end
    table.sort(Stacks, function(A, B) return A.Count < B.Count end)

    for _, Stack in ipairs(Stacks) do
        if Amount <= 0 then return end
        if Stack.Count <= Amount then
            C_Container.PickupContainerItem(Stack.Bag, Stack.Slot)
            Amount = Amount - Stack.Count
        else
            C_Container.SplitContainerItem(Stack.Bag, Stack.Slot, Amount)
            Amount = 0
        end
        DeleteCursorItem()
    end
end

local function PurchaseItem(Index, ItemID, Target, Info, Money)
    local Owned = C_Item.GetItemCount(ItemID)
    if Owned >= Target then return Money end

    local BundleSize = math.max(Info.stackCount, 1)
    local Excess = (Owned - Target) % BundleSize
    if Excess > Owned or CursorHasItem() then Excess = 0 end

    local Bundles = math.floor((Target - Owned + Excess) / BundleSize)
    local Affordable = Bundles
    if Info.numAvailable >= 0 then Affordable = math.min(Affordable, Info.numAvailable) end
    if Info.price > 0 then Affordable = math.min(Affordable, math.floor(Money / Info.price)) end
    if Affordable < Bundles then
        Bundles = Affordable
        Excess = 0
    end
    if Bundles <= 0 then return Money end

    if Excess > 0 then DeleteItems(ItemID, Excess) end

    local Remaining = Bundles * BundleSize
    local MaxPerPurchase = GetMerchantItemMaxStack(Index)
    MaxPerPurchase = math.max(MaxPerPurchase - MaxPerPurchase % BundleSize, BundleSize)
    while Remaining > 0 do
        local Quantity = math.min(Remaining, MaxPerPurchase)
        BuyMerchantItem(Index, Quantity)
        Remaining = Remaining - Quantity
    end

    return Money - Bundles * Info.price
end

local function PurchaseItems()
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
end

local function AutoPurchase_OnEvent(APF, Event)
    if APF.PurchaseTimer then APF.PurchaseTimer:Cancel() end
    if Event == "MERCHANT_SHOW" then
        APF.PurchaseTimer = C_Timer.NewTimer(PURCHASE_DELAY, PurchaseItems)
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
        if AutoPurchaseFrame.PurchaseTimer then AutoPurchaseFrame.PurchaseTimer:Cancel() end
        AutoPurchaseFrame:UnregisterAllEvents()
    end
end
