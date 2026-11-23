local Private = select(2, ...)

local function FeedPet_PreClick(Button)
    if InCombatLockdown() then return end
    if not Private.DB.global.Miscellaneous.Hunter.UseBestFood then
        Button:SetAttribute("type", nil)
        return
    end

    local Bag, Slot, BestLevel, BestCount = nil, nil, -1, 0
    for SearchBag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for SearchSlot = 1, C_Container.GetContainerNumSlots(SearchBag) do
            local SlotInfo = C_Container.GetContainerItemInfo(SearchBag, SearchSlot)
            if SlotInfo and C_PetInfo.CanPetEatItem(SlotInfo.itemID) then
                local ItemLevel = select(4, C_Item.GetItemInfo(SlotInfo.itemID)) or 0
                if ItemLevel > BestLevel or (ItemLevel == BestLevel and SlotInfo.stackCount < BestCount) then
                    Bag, Slot, BestLevel, BestCount = SearchBag, SearchSlot, ItemLevel, SlotInfo.stackCount
                end
            end
        end
    end
    Button:SetAttribute("type", Bag and "spell" or nil)
    Button:SetAttribute("target-bag", Bag)
    Button:SetAttribute("target-slot", Slot)
    if Bag then return end
    print(string.format("|c%sFeed Pet|r: %s", Private.E.AccentColour, UnitExists("pet") and "You have no food for your pet." or "You have no pet."))
end

function Private:SetupFeedPet()
    if Private.E.myclass ~= "HUNTER" then return end

    local FeedPetButton = CreateFrame("Button", "FeedPet", nil, "SecureActionButtonTemplate")
    FeedPetButton:RegisterForClicks("AnyUp")
    FeedPetButton:SetAttribute("useOnKeyDown", false)
    FeedPetButton:SetAttribute("spell", 6991)
    FeedPetButton:SetScript("PreClick", FeedPet_PreClick)
end
