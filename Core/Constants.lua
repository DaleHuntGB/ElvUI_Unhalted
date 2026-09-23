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

-- Hero's Path teleport destinations, keyed by spell ID.
Private.QuickActionSpellNames = {
    -- Wrath of the Lich King / Cataclysm
    [1254555] = "Pit of Saron",
    [410080] = "The Vortex Pinnacle",
    [424142] = "Throne of the Tides",
    [445424] = "Grim Batol",
    -- Mists of Pandaria
    [131204] = "Temple of the Jade Serpent",
    [131205] = "Stormstout Brewery",
    [131206] = "Shado-Pan Monastery",
    [131222] = "Mogu'shan Palace",
    [131225] = "Gate of the Setting Sun",
    [131228] = "Siege of Niuzao Temple",
    [131229] = "Scarlet Monastery",
    [131231] = "Scarlet Halls",
    [131232] = "Scholomance",
    -- Warlords of Draenor
    [159895] = "Bloodmaul Slag Mines",
    [159896] = "Iron Docks",
    [159897] = "Auchindoun",
    [159898] = "Skyreach",
    [159899] = "Shadowmoon Burial Grounds",
    [159900] = "Grimrail Depot",
    [159901] = "The Everbloom",
    [159902] = "Upper Blackrock Spire",
    [1254557] = "Skyreach",
    -- Legion
    [373262] = "Return to Karazhan",
    [393764] = "Halls of Valor",
    [393766] = "Court of Stars",
    [410078] = "Neltharion's Lair",
    [424153] = "Black Rook Hold",
    [424163] = "Darkheart Thicket",
    [1254551] = "Seat of the Triumvirate",
    -- Battle for Azeroth
    [373274] = "Operation: Mechagon",
    [410071] = "Freehold",
    [410074] = "The Underrot",
    [424167] = "Waycrest Manor",
    [424187] = "Atal'Dazar",
    [445418] = "Siege of Boralus",
    [464256] = "Siege of Boralus",
    [467553] = "The MOTHERLODE!!",
    [467555] = "The MOTHERLODE!!",
    [1286828] = "Temple of Sethraliss",
    [1286831] = "Kings' Rest",
    -- Shadowlands
    [354462] = "The Necrotic Wake",
    [354463] = "Plaguefall",
    [354464] = "Mists of Tirna Scithe",
    [354465] = "Halls of Atonement",
    [354466] = "Spires of Ascension",
    [354467] = "Theater of Pain",
    [354468] = "De Other Side",
    [354469] = "Sanguine Depths",
    [367416] = "Tazavesh, the Veiled Market",
    [373190] = "Castle Nathria",
    [373191] = "Sanctum of Domination",
    [373192] = "Sepulcher of the First Ones",
    -- Dragonflight
    [393222] = "Uldaman: Legacy of Tyr",
    [393256] = "Ruby Life Pools",
    [393262] = "The Nokhud Offensive",
    [393267] = "Brackenhide Hollow",
    [393273] = "Algeth'ar Academy",
    [393276] = "Neltharus",
    [393279] = "The Azure Vault",
    [393283] = "Halls of Infusion",
    [424197] = "Dawn of the Infinite",
    [432254] = "Vault of the Incarnates",
    [432257] = "Aberrus, the Shadowed Crucible",
    [432258] = "Amirdrassil, the Dream's Hope",
    -- The War Within
    [445269] = "The Stonevault",
    [445414] = "The Dawnbreaker",
    [445416] = "City of Threads",
    [445417] = "Ara-Kara, City of Echoes",
    [445440] = "Cinderbrew Meadery",
    [445441] = "Darkflame Cleft",
    [445443] = "The Rookery",
    [445444] = "Priory of the Sacred Flame",
    [1216786] = "Operation: Floodgate",
    [1237215] = "Eco-Dome Al'dani",
    [1226482] = "Liberation of Undermine",
    [1239155] = "Manaforge Omega",
    -- Midnight
    [1254400] = "Windrunner Spire",
    [1254559] = "Maisara Caverns",
    [1254563] = "Nexus-Point Xenas",
    [1254572] = "Magisters' Terrace",
    [1286801] = "The Blinding Vale",
    [1286804] = "Voidscar Arena",
    [1286807] = "Den of Nalorakk",
    [1286809] = "Murder Row",
    [1286812] = "Altar of Fangs",
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
    ["%s • %s"] = "999K • 99.9K",
    ["%s - %s"] = "999K - 99.9K",
    ["%s » %s"] = "999K » 99.9K",
    ["%s | %s"] = "999K | 99.9K",
    ["%s [%s]"] = "999K [99.9K]",
    ["%s (%s)"] = "999K (99.9K)",
    ["%s <%s>"] = "999K <99.9K>",
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
    ["Food"] = { spellNames = { "Well Fed", "Hearty Well Fed" }, iconID = 136000, alwaysShow = false },
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

local AbbreviationData = {
    breakpoint = 1e9,
    abbreviation = "B",
    significandDivisor = 1e7,
    fractionDivisor = 100,
    abbreviationIsGlobal = false,
}

function Private:AbbreviateValue(value)
    return AbbreviateNumbers(value, AbbreviationData)
end