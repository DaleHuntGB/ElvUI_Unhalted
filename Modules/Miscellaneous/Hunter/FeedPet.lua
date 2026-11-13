local Private = select(2, ...)

local FEED_PET_SPELL_ID = 6991

local function FindBestFood()
    local BestBag, BestSlot, BestLevel, BestCount = nil, nil, -1, 0
    for Bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local SlotInfo = C_Container.GetContainerItemInfo(Bag, Slot)
            if SlotInfo and C_PetInfo.CanPetEatItem(SlotInfo.itemID) then
                local ItemLevel = select(4, C_Item.GetItemInfo(SlotInfo.itemID)) or 0
                if ItemLevel > BestLevel or (ItemLevel == BestLevel and SlotInfo.stackCount < BestCount) then
                    BestBag, BestSlot, BestLevel, BestCount = Bag, Slot, ItemLevel, SlotInfo.stackCount
                end
            end
        end
    end
    return BestBag, BestSlot
end

local function FeedPet_PreClick(Button)
    if InCombatLockdown() then return end
    if not Private.DB.global.Miscellaneous.Hunter.UseBestFood then
        Button:SetAttribute("type", nil)
        return
    end

    local Bag, Slot = FindBestFood()
    Button:SetAttribute("type", Bag and "spell" or nil)
    Button:SetAttribute("target-bag", Bag)
    Button:SetAttribute("target-slot", Slot)
    if Bag then return end
    print(string.format("|c%sFeed Pet|r %s", Private.E.AccentColour, UnitExists("pet") and "There is no food in your bags that your pet will eat." or "You have no pet out."))
end

function Private:SetupFeedPet()
    if Private.E.myclass ~= "HUNTER" then return end

    local FeedPetButton = CreateFrame("Button", "FeedPet", nil, "SecureActionButtonTemplate")
    FeedPetButton:RegisterForClicks("AnyUp")
    FeedPetButton:SetAttribute("useOnKeyDown", false)
    FeedPetButton:SetAttribute("spell", FEED_PET_SPELL_ID)
    FeedPetButton:SetScript("PreClick", FeedPet_PreClick)
end
