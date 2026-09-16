local Private = select(2, ...)

Private.AddOn = LibStub("AceAddon-3.0"):NewAddon("ElvUI_Unhalted")
Private.ACH = LibStub("LibAceConfigHelper")
Private.ACR = LibStub("AceConfigRegistry-3.0")
Private.LSM = LibStub("LibSharedMedia-3.0")
Private.AddOnName = C_AddOns.GetAddOnMetadata("ElvUI_Unhalted", "Title")
Private.AddOnVersion = C_AddOns.GetAddOnMetadata("ElvUI_Unhalted", "Version")
Private.E = unpack(ElvUI)
Private.Distributor = Private.E:GetModule("Distributor")

Private.GUI = {}

Private.InstanceIDs = {
    [1] = true, -- Normal Dungeon
    [2] = true, -- Heroic Dungeon
    [8] = true, -- Mythic+ Dungeon
    [23] = true, -- Mythic Dungeon
    [14] = true, -- Normal Raid
    [15] = true, -- Heroic Raid
    [16] = true, -- Mythic Raid
}

Private.MapIDsToInstanceNames = {
    [2825] = "Den of Nalorakk",
    [2521] = "Ruby Life Pools",
    [2993] = "Altar of Fangs",
    [1762] = "Kings' Rest",
    [2923] = "Voidscar Arena",
    [2859] = "The Blinding Vale",
    [1877] = "Temple of Sethraliss",
    [2813] = "Murder Row",
}

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

Private.MeterAmountFormats = {
    ["%s • %s"] = "%s • %s",
    ["%s - %s"] = "%s - %s",
    ["%s [%s]"] = "%s [%s]",
    ["%s (%s)"] = "%s (%s)",
    ["%s » %s"] = "%s » %s"
}

Private.ItemQualities = {
    [Enum.ItemQuality.Poor] = ITEM_QUALITY0_DESC,
    [Enum.ItemQuality.Common] = ITEM_QUALITY1_DESC,
    [Enum.ItemQuality.Uncommon] = ITEM_QUALITY2_DESC,
    [Enum.ItemQuality.Rare] = ITEM_QUALITY3_DESC,
    [Enum.ItemQuality.Epic] = ITEM_QUALITY4_DESC,
}

Private.ClassIDFilter = {
    [Enum.ItemClass.Consumable] = true,
    [Enum.ItemClass.Tradegoods] = true,
    [Enum.ItemClass.Recipe] = true,
    [Enum.ItemClass.Gem] = true,
    [Enum.ItemClass.Battlepet] = true,
    [Enum.ItemClass.Miscellaneous] = true,
    [Enum.ItemClass.Housing] = true,
}

Private.ItemFilter = {
    [65360] = true, -- Cloak of Coordination
    [63206] = true, -- Wrap of Unity
    [63352] = true, -- Shroud of Cooperation
    [132514] = true -- Auto Hammer
}

Private.RaidBuffs = {
    [6673] =  { spellIDs = { 6673 },  requiredClass = "WARRIOR" }, -- Battle Shout
    [1459] =  { spellIDs = { 1459 },  requiredClass = "MAGE" },    -- Arcane Intellect
    [21562] = { spellIDs = { 21562 }, requiredClass = "PRIEST" },  -- Power Word: Fortitude
    [1126] =  { spellIDs = { 1126 },  requiredClass = "DRUID" },   -- Mark of the Wild
    [381732] = { -- Blessing of the Bronze
        spellIDs = { 381732, 381741, 381746, 381748, 381749, 381750, 381751, 381752, 381753, 381754, 381756, 381757, 381758 },
        requiredClass = "EVOKER",
    },
}

Private.PersonalBuffs = {
    ["Food"] = { spellNames = { "Well Fed" }, iconID = 136000, alwaysShow = false },
    ["Flask"] = { spellNames = { "Flask of the Shattered Sun", "Flask of the Blood Knights", "Flask of the Magisters", "Flask of Thalassian Resistance" }, iconID = 7548903, alwaysShow = false },
    ["Oils"] = { iconID = 135641, dualWieldSpecIDs = { [259] = true, [260] = true, [261] = true, [263] = true, [72] = true }, alwaysShow = false },
    ["Source of Magic"] = { spellNames = { "Source of Magic" }, iconID = 4630412, alwaysShow = false },
    ["Auras"] = { spellNames = { "Crusader Aura", "Devotion Aura", "Concentration Aura" }, iconID = 135893, alwaysShow = true },
}

Private.MouseCursors = {
    Path = {
        ["CURSOR_01"] = "talents-search-notonactionbar",
        ["CURSOR_02"] = "talents-search-notonactionbarhidden",
        ["CURSOR_03"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_01.png",
        ["CURSOR_04"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_02.png",
        ["CURSOR_05"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_03.png",
        ["CURSOR_06"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_04.png",
        ["CURSOR_07"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_05.png",
        ["CURSOR_08"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_06.png",
        ["CURSOR_09"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_07.png",
        ["CURSOR_10"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_08.png",
    },
    Preview = {
        ["CURSOR_01"] = "|A:talents-search-notonactionbar:18:18|a",
        ["CURSOR_02"] = "|A:talents-search-notonactionbarhidden:18:18|a",
        ["CURSOR_03"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_01.png:18:18|t",
        ["CURSOR_04"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_02.png:18:18|t",
        ["CURSOR_05"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_03.png:18:18|t",
        ["CURSOR_06"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_04.png:18:18|t",
        ["CURSOR_07"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_05.png:18:18|t",
        ["CURSOR_08"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_06.png:18:18|t",
        ["CURSOR_09"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_07.png:18:18|t",
        ["CURSOR_10"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_08.png:18:18|t",
    },
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
    if not Private.DB.global.QualityOfLife.Toggles.AutoSellGreys then return end
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
    if not Private.DB.global.VendorHelper.AutoVendor then return end
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

function Private:IsDeveloper()
    local _, BTag = BNGetInfo()
    local isDeveloper = BTag == "Unhalted#2639"
    return isDeveloper
end

-- Thanks Lucky - https://github.com/Luckyone961/LuckyoneUI/blob/development/LuckyoneUI/Modules/DamageMeter/Core.lua#L35-L40
function Private:StripRealm(name, classFilename)
	if not name then return name end
	if not classFilename or classFilename == "" then return name end

	return Ambiguate(name, "short")
end
