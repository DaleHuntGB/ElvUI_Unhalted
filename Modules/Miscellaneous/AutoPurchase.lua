local Private = select(2, ...)

local PURCHASE_DELAY = 0.5
local AMMO_BAG_FAMILY = 0x3

local function GetQuiverCapacity(ItemID)
    local ItemFamily = bit.band(C_Item.GetItemFamily(ItemID) or 0, AMMO_BAG_FAMILY)
    if ItemFamily == 0 then return end

    local MaxStack = C_Item.GetItemMaxStackSizeByID(ItemID)
    local Capacity = 0
    for Bag = 1, NUM_BAG_SLOTS do
        local _, BagFamily = C_Container.GetContainerNumFreeSlots(Bag)
        if BagFamily and bit.band(BagFamily, ItemFamily) ~= 0 then
            for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
                local SlotInfo = C_Container.GetContainerItemInfo(Bag, Slot)
                if not SlotInfo or SlotInfo.itemID == ItemID then Capacity = Capacity + MaxStack end
            end
        end
    end
    return Capacity
end

local function PurchaseItem(Index, ItemID, Target, Info, Money)
    local Owned = C_Item.GetItemCount(ItemID)
    if Owned >= Target then return Money end

    local BundleSize = math.max(Info.stackCount, 1)
    local Bundles = math.floor((Target - Owned) / BundleSize)
    local Capacity = GetQuiverCapacity(ItemID)
    if Capacity then Bundles = math.min(Bundles, math.floor((Capacity - Owned) / BundleSize)) end
    if Info.numAvailable >= 0 then Bundles = math.min(Bundles, Info.numAvailable) end
    if Info.price > 0 then Bundles = math.min(Bundles, math.floor(Money / Info.price)) end
    if Bundles <= 0 then return Money end

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
