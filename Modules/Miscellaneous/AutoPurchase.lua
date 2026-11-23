local Private = select(2, ...)

local PendingItems = {}
local EmptySlots = 0

local function PurchaseItem(Index, ItemID, Target, Info, Money)
    local Owned = C_Item.GetItemCount(ItemID)
    if Owned >= Target then return Money end

    local BundleSize = math.max(Info.stackCount, 1)
    local MaxStack = C_Item.GetItemMaxStackSizeByID(ItemID) or 1
    local ItemFamily = bit.band(C_Item.GetItemFamily(ItemID) or 0, 0x3)
    local Capacity = ItemFamily ~= 0 and 0
    local StackRoom = 0
    if Capacity then
        for Bag = 1, NUM_BAG_SLOTS do
            local _, BagFamily = C_Container.GetContainerNumFreeSlots(Bag)
            if BagFamily and bit.band(BagFamily, ItemFamily) ~= 0 then
                for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
                    local SlotInfo = C_Container.GetContainerItemInfo(Bag, Slot)
                    if not SlotInfo or SlotInfo.itemID == ItemID then Capacity = Capacity + MaxStack end
                end
            end
        end
    else
        for Bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
                local SlotInfo = C_Container.GetContainerItemInfo(Bag, Slot)
                if SlotInfo and SlotInfo.itemID == ItemID then StackRoom = StackRoom + MaxStack - SlotInfo.stackCount end
            end
        end
    end
    local Room = Capacity and Capacity - Owned or StackRoom + EmptySlots * MaxStack
    local Bundles = math.floor(math.min(Target - Owned, Room) / BundleSize)
    if Info.numAvailable >= 0 then Bundles = math.min(Bundles, Info.numAvailable) end
    if Info.price > 0 then Bundles = math.min(Bundles, math.floor(Money / Info.price)) end
    if Bundles <= 0 then return Money end

    local Bought = Bundles * BundleSize
    if not Capacity then EmptySlots = EmptySlots - math.ceil(math.max(Bought - StackRoom, 0) / MaxStack) end
    local Remaining = Bought
    local MaxPerPurchase = GetMerchantItemMaxStack(Index)
    MaxPerPurchase = math.max(MaxPerPurchase - MaxPerPurchase % BundleSize, BundleSize)
    while Remaining > 0 do
        local Quantity = math.min(Remaining, MaxPerPurchase)
        BuyMerchantItem(Index, Quantity)
        Remaining = Remaining - Quantity
    end

    PendingItems[ItemID] = { Owned = Owned, Expected = Owned + Bought, BundleSize = BundleSize, Price = Info.price }
    return Money - Bundles * Info.price
end

local function FinishPurchases()
    local APF = Private.AutoPurchaseFrame
    APF:UnregisterEvent("BAG_UPDATE_DELAYED")
    if APF.TimeoutTimer then APF.TimeoutTimer:Cancel() end

    local Cost = 0
    for ItemID, Pending in pairs(PendingItems) do
        local Arrived = math.max(math.min(C_Item.GetItemCount(ItemID), Pending.Expected) - Pending.Owned, 0)
        Cost = Cost + math.floor(Arrived / Pending.BundleSize) * Pending.Price
    end
    wipe(PendingItems)
    if Cost <= 0 then return end

    local BagsDB = Private.E.db.bags
    print(string.format("|c%sAutoPurchase|r Cost: %s", Private.E.AccentColour, Private.E:FormatMoney(Cost, BagsDB.moneyFormat, not BagsDB.moneyCoins)))
end

local function PurchaseItems()
    local Items = Private.DB.global.Miscellaneous.AutoPurchase.Items
    if not next(Items) then return end

    EmptySlots = 0
    for Bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local Free, BagFamily = C_Container.GetContainerNumFreeSlots(Bag)
        if BagFamily == 0 then EmptySlots = EmptySlots + Free end
    end
    local Money = GetMoney()
    for Index = 1, GetMerchantNumItems() do
        local ItemID = GetMerchantItemID(Index)
        local Info = C_MerchantFrame.GetItemInfo(Index)
        local Target = ItemID and (Items[ItemID] or (Info.name and Items[strlower(Info.name)]))
        if Target and Info.isPurchasable and not Info.hasExtendedCost then
            Money = PurchaseItem(Index, ItemID, Target, Info, Money)
        end
    end

    if not next(PendingItems) then return end
    local APF = Private.AutoPurchaseFrame
    APF:RegisterEvent("BAG_UPDATE_DELAYED")
    APF.TimeoutTimer = C_Timer.NewTimer(5, FinishPurchases)
end

local function AutoPurchase_OnEvent(APF, Event)
    if Event == "BAG_UPDATE_DELAYED" then
        for ItemID, Pending in pairs(PendingItems) do
            if C_Item.GetItemCount(ItemID) < Pending.Expected then return end
        end
        FinishPurchases()
        return
    end

    if APF.PurchaseTimer then APF.PurchaseTimer:Cancel() end
    if Event == "MERCHANT_SHOW" then
        if next(PendingItems) then FinishPurchases() end
        APF.PurchaseTimer = C_Timer.NewTimer(0.5, PurchaseItems)
    end
end

function Private:SetupAutoPurchase()
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
