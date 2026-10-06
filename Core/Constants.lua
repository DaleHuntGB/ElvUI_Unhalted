local Private = select(2, ...)

Private.AddOn = LibStub("AceAddon-3.0"):NewAddon("ElvUI_Unhalted")
Private.ElvUI = unpack(ElvUI)
Private.Distributor = Private.ElvUI:GetModule("Distributor")
Private.AG = LibStub("AceGUI-3.0")
Private.AC = LibStub("AceConsole-3.0")
Private.LSM = LibStub("LibSharedMedia-3.0")

Private.AddOnName = C_AddOns.GetAddOnMetadata("ElvUI_Unhalted", "Title")
Private.AddOnVersion = C_AddOns.GetAddOnMetadata("ElvUI_Unhalted", "Version")

Private.InterruptIDs = {
    DEATHKNIGHT = {47528},
    DEMONHUNTER = {183752},
    DRUID = {106839, 78675},
    EVOKER = {351338},
    HUNTER = {147362, 187707},
    MAGE = {2139},
    MONK = {116705},
    PALADIN = {96231, 31935},
    PRIEST = {15487},
    ROGUE = {1766},
    SHAMAN = {57994},
    WARLOCK = {19647, 132409, 89766, 119910, 1276467},
    WARRIOR = {6552},
}

Private.AnchorPoints = {
    ["TOPLEFT"] = "TOPLEFT",
    ["TOP"] = "TOP",
    ["TOPRIGHT"] = "TOPRIGHT",
    ["LEFT"] = "LEFT",
    ["CENTER"] = "CENTER",
    ["RIGHT"] = "RIGHT",
    ["BOTTOMLEFT"] = "BOTTOMLEFT",
    ["BOTTOM"] = "BOTTOM",
    ["BOTTOMRIGHT"] = "BOTTOMRIGHT"
}

Private.FontFlags = {
    [""] = "None",
    ["OUTLINE"] = "Outline",
    ["THICKOUTLINE"] = "Thick Outline",
    ["MONOCHROME"] = "Monochrome",
    ["MONOCHROME, OUTLINE"] = "Monochrome - Outline",
    ["OUTLINE, SLUG"] = "Outline - Slug Render",
}

Private.GrowthDirections = {
    ["LEFT"] = "Left",
    ["RIGHT"] = "Right",
    ["UP"] = "Up",
    ["DOWN"] = "Down",
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

Private.JustificationH = {
    ["TOPLEFT"] = "LEFT",
    ["TOP"] = "CENTER",
    ["TOPRIGHT"] = "RIGHT",
    ["LEFT"] = "LEFT",
    ["CENTER"] = "CENTER",
    ["RIGHT"] = "RIGHT",
    ["BOTTOMLEFT"] = "LEFT",
    ["BOTTOM"] = "CENTER",
    ["BOTTOMRIGHT"] = "RIGHT",
}

Private.MouseCursorTextures = {
    ["CURSOR_01"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_01.png",
    ["CURSOR_02"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_02.png",
    ["CURSOR_03"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_03.png",
    ["CURSOR_04"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_04.png",
    ["CURSOR_05"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_05.png",
    ["CURSOR_06"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_06.png",
    ["CURSOR_07"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_07.png",
    ["CURSOR_08"] = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_08.png",
}

Private.MouseCursorTexturePreviews = {
    ["CURSOR_01"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_01.png:21:21|t",
    ["CURSOR_02"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_02.png:21:21|t",
    ["CURSOR_03"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_03.png:21:21|t",
    ["CURSOR_04"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_04.png:21:21|t",
    ["CURSOR_05"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_05.png:21:21|t",
    ["CURSOR_06"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_06.png:21:21|t",
    ["CURSOR_07"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_07.png:21:21|t",
    ["CURSOR_08"] = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Cursors\\Cursor_08.png:21:21|t",
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
    ["%s • %s"] = "999K • 99.9K",
    ["%s - %s"] = "999K - 99.9K",
    ["%s » %s"] = "999K » 99.9K",
    ["%s | %s"] = "999K | 99.9K",
    ["%s [%s]"] = "999K [99.9K]",
    ["%s (%s)"] = "999K (99.9K)",
    ["%s <%s>"] = "999K <99.9K>",
}

Private.Separators = {
    ["•"] = "•",
    ["-"] = "-",
    ["»"] = "»",
    ["|"] = "|",
}

Private.ItemQualities = {
    [Enum.ItemQuality.Poor] = ITEM_QUALITY0_DESC,
    [Enum.ItemQuality.Common] = ITEM_QUALITY1_DESC,
    [Enum.ItemQuality.Uncommon] = ITEM_QUALITY2_DESC,
    [Enum.ItemQuality.Rare] = ITEM_QUALITY3_DESC,
    [Enum.ItemQuality.Epic] = ITEM_QUALITY4_DESC,
}

Private.ItemFilter = {
    [Enum.ItemClass.Consumable] = true,
    [Enum.ItemClass.Tradegoods] = true,
    [Enum.ItemClass.Recipe] = true,
    [Enum.ItemClass.Gem] = true,
    [Enum.ItemClass.Battlepet] = true,
    [Enum.ItemClass.Miscellaneous] = true,
    [Enum.ItemClass.Housing] = true,
}

function Private:PrettyPrint(MSG)
    print(Private.AddOnName .. ": " .. MSG)
end

function Private:FetchFont(Font)
    return Private.LSM:Fetch("font", Font)
end

function Private:FetchSound(Sound)
    return Private.LSM:Fetch("sound", Sound)
end

function Private:FetchSpellTexture(SpellID)
    local spellData = C_Spell.GetSpellInfo(SpellID)
    if spellData then return spellData.iconID end
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
    if not Private.DB.global.VendorSupport.Enable then return end
    for Bag = 0, NUM_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local containerInfo = C_Container.GetContainerItemInfo(Bag, Slot)
            if containerInfo and not containerInfo.hasNoValue and not Private.ItemFilter[containerInfo.itemID] then
                local itemLocation = ItemLocation:CreateFromBagAndSlot(Bag, Slot)
                local itemQuality = C_Item.GetItemQuality(itemLocation)
                local itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
                local _, _, _, _, _, _, _, _, _, _, itemPrice, itemClassID = C_Item.GetItemInfo(containerInfo.hyperlink)
                if itemQuality and itemLevel and itemPrice and itemClassID and not Private.ItemFilter[itemClassID]
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

function Private:IsDeveloper()
    local _, BTag = BNGetInfo()
    local isDeveloper = BTag == "Unhalted#2639"
    return isDeveloper
end

function Private:ResetProfile()
    StaticPopupDialogs["ELVUI_UNHALTED_RESET_PROFILE"] = {
        text = "Reset settings back to default?",
        button1 = "Yes",
        button2 = "No",
        OnButton1 = function()
            Private.DB:ResetDB(true)
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopup_Show("ELVUI_UNHALTED_RESET_PROFILE")
end

function Private:StripRealm(name, classFilename)
	if not name then return name end
	if not classFilename or classFilename == "" then return name end

	return Ambiguate(name, "short")
end

function Private:AbbreviateValue(value)
    local AbbreviationData = C_StringUtil.GetDefaultAbbreviationBreakpoints()
    AbbreviationData[#AbbreviationData + 1] = {breakpoint = 1e-6, abbreviation = "", significandDivisor = 0.1, fractionDivisor = 10, abbreviationIsGlobal = false}
    return AbbreviateNumbers(value, {config = CreateAbbreviateConfig(AbbreviationData)})
end
