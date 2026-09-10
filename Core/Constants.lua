local Private = select(2, ...)

Private.AddOn = LibStub("AceAddon-3.0"):NewAddon("ElvUI_Unhalted")
Private.ACH = LibStub("LibAceConfigHelper")
Private.ACR = LibStub("AceConfigRegistry-3.0")
Private.LSM = LibStub("LibSharedMedia-3.0")
Private.AddOnName = C_AddOns.GetAddOnMetadata("ElvUI_Unhalted", "Title")
Private.E = unpack(ElvUI)
Private.Distributor = Private.E:GetModule("Distributor")
Private.GUI = {}

Private.LSM:Register("statusbar", "|cFF6080FFUnhalted|rUI: Half Bar", "Interface\\AddOns\\ElvUI_Unhalted\\Media\\StatusBars\\Half_Bar.tga")

Private.AP = {
    ["TOPLEFT"] = "TOPLEFT",
    ["TOP"] = "TOP",
    ["TOPRIGHT"] = "TOPRIGHT",
    ["BOTTOMLEFT"] = "BOTTOMLEFT",
    ["BOTTOM"] = "BOTTOM",
    ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
    ["LEFT"] = "LEFT",
    ["RIGHT"] = "RIGHT",
    ["CENTER"] = "CENTER"
}

Private.ACH.FontValues["OUTLINE, SLUG"] = "Outline (Slug Rendering)"

Private.FilteredMessages = {
    ["There is nothing to attack."] = true,
    ["A more powerful spell is already active"] = true,
    ["Item is not ready yet."] = true,
    ["You can't do that right now."] = true,
    ["Invalid target"] = true,
    ["Your level is now restricted to 60."] = true,
    ["Can't do that while moving"] = true,
}

Private.MeterTypes = {
	[Enum.DamageMeterType.DamageDone] = DAMAGE_METER_TYPE_DAMAGE_DONE,
	[Enum.DamageMeterType.Dps] = DAMAGE_METER_TYPE_DPS,
	[Enum.DamageMeterType.HealingDone] = DAMAGE_METER_TYPE_HEALING_DONE,
	[Enum.DamageMeterType.Hps] = DAMAGE_METER_TYPE_HPS,
	[Enum.DamageMeterType.Absorbs] = DAMAGE_METER_TYPE_ABSORBS,
	[Enum.DamageMeterType.Interrupts] = DAMAGE_METER_TYPE_INTERRUPTS,
	[Enum.DamageMeterType.Dispels] = DAMAGE_METER_TYPE_DISPELS,
	[Enum.DamageMeterType.DamageTaken] = DAMAGE_METER_TYPE_DAMAGE_TAKEN,
	[Enum.DamageMeterType.AvoidableDamageTaken] = DAMAGE_METER_TYPE_AVOIDABLE_DAMAGE_TAKEN,
	[Enum.DamageMeterType.Deaths] = DAMAGE_METER_TYPE_DEATHS,
	[Enum.DamageMeterType.EnemyDamageTaken] = DAMAGE_METER_TYPE_ENEMY_DAMAGE_TAKEN,
}

function Private:PromptReload()
    StaticPopupDialogs["RELOAD_UI"] = {
        text = "This change requires a reload to take effect, would you like to reload now?",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function() ReloadUI() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    StaticPopup_Show("RELOAD_UI")
end

function Private:StopVendoring()
    if Private.SellGreysTimer then
        Private.SellGreysTimer:Cancel()
        Private.SellGreysTimer = nil
    end

    if Private.SellItemsTimer then
        Private.SellItemsTimer:Cancel()
        Private.SellItemsTimer = nil
    end
end

function Private:SellGreys()
    for Bag = 0, NUM_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local ItemLink = C_Container.GetContainerItemLink(Bag, Slot)
            if ItemLink then
                local _, _, itemQuality, _, _, _, _, _, _, _, itemPrice = C_Item.GetItemInfo(ItemLink)
                if itemQuality == 0 and itemPrice > 0 then
                    C_Container.UseContainerItem(Bag, Slot)
                    Private.SellGreysTimer = C_Timer.NewTimer(0.1, function() Private.SellGreysTimer = nil Private:SellGreys() end)
                    return
                end
            end
        end
    end
end

function Private:SellItems(minimumQuality, minimumItemLevel)
    for Bag = 0, NUM_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local containerInfo = C_Container.GetContainerItemInfo(Bag, Slot)
            if containerInfo and not containerInfo.hasNoValue and not Private.ItemFilter[containerInfo.itemID] then
                local itemLocation = ItemLocation:CreateFromBagAndSlot(Bag, Slot)
                local itemQuality = C_Item.GetItemQuality(itemLocation)
                local itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
                local _, _, _, _, _, _, _, _, _, _, itemPrice, itemClassID = C_Item.GetItemInfo(containerInfo.hyperlink)
                if itemQuality and itemLevel and itemPrice and itemClassID and not Private.ClassIDFilter[itemClassID]
                    and itemQuality <= minimumQuality
                    and itemLevel <= minimumItemLevel
                    and itemPrice > 0
                then
                    C_Container.UseContainerItem(Bag, Slot)
                    Private.SellItemsTimer = C_Timer.NewTimer(0.1, function() Private.SellItemsTimer = nil Private:SellItems(minimumQuality, minimumItemLevel) end)
                    return
                end
            end
        end
    end
end

function Private:PrettyPrint(MSG)
    print(Private.AddOnName .. ": " .. MSG)
end
