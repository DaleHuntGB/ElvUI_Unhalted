local Private = select(2, ...)

Private.AddOn = LibStub("AceAddon-3.0"):NewAddon("ElvUI_Unhalted")
Private.LSM = LibStub("LibSharedMedia-3.0")
Private.ACH = LibStub("LibAceConfigHelper")
Private.AG = LibStub("AceGUI-3.0")
Private.LibDBIcon = LibStub("LibDBIcon-1.0", true)

Private.E = unpack(ElvUI)
Private.E.AccentColour = CreateColor(Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b, Private.E.db.general.valuecolor.a):GenerateHexColor()
Private.E.BackgroundColour = Private.E.db.general.backdropcolor
Private.E.BackgroundFadeColour = Private.E.db.general.backdropfadecolor
Private.E.bordercolour = Private.E.db.general.bordercolor

Private.isForever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT

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

Private.InterruptIDs = {
    DEATHKNIGHT     = {47528},
    DEMONHUNTER     = {183752},
    DRUID           = {106839, 78675},
    EVOKER          = {351338},
    HUNTER          = {147362, 187707},
    MAGE            = {2139},
    MONK            = {116705},
    PALADIN         = {96231, 31935},
    PRIEST          = {15487},
    ROGUE           = {1766},
    SHAMAN          = {57994},
    WARLOCK         = {19647, 132409, 89766, 119910, 1276467},
    WARRIOR         = {6552},
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

Private.Crosshairs = {
    ["CROSSHAIR_01"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_01.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_01.png:18:18|t" },
    ["CROSSHAIR_02"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_02.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_02.png:18:18|t" },
    ["CROSSHAIR_03"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_03.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_03.png:18:18|t" },
    ["CROSSHAIR_04"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_04.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_04.png:18:18|t" },
    ["CROSSHAIR_05"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_05.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_05.png:18:18|t" },
    ["CROSSHAIR_06"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_06.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_06.png:18:18|t" },
    ["CROSSHAIR_07"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_07.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Crosshairs\\Crosshair_07.png:18:18|t" },
}

Private.MouseCursors = {
    ["CURSOR_01"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_01.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_01.png:18:18|t", isAtlas = false },
    ["CURSOR_02"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_02.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_02.png:18:18|t", isAtlas = false },
    ["CURSOR_03"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_03.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_03.png:18:18|t", isAtlas = false },
    ["CURSOR_04"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_04.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_04.png:18:18|t", isAtlas = false },
    ["CURSOR_05"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_05.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_05.png:18:18|t", isAtlas = false },
    ["CURSOR_06"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_06.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_06.png:18:18|t", isAtlas = false },
    ["CURSOR_07"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_07.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_07.png:18:18|t", isAtlas = false },
    ["CURSOR_08"] = { Path = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_08.png", Preview = "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Cursors\\Cursor_08.png:18:18|t", isAtlas = false },
    ["CURSOR_09"] = { Path = "talents-search-notonactionbar", Preview = "|A:talents-search-notonactionbar:32:32|a", isAtlas = true },
    ["CURSOR_10"] = { Path = "talents-search-notonactionbarhidden", Preview = "|A:talents-search-notonactionbarhidden:32:32|a", isAtlas = true }
}

Private.RaidDifficultyIDs = {
    [14] = "Normal",
    [15] = "Heroic",
    [16] = "Mythic",
    [17] = "LFR",
}

Private.GVaultLevels = {
    ["Mythic+"] = {
        [0]  = 302,
        [2]  = 305,
        [3]  = 305,
        [4]  = 308,
        [5]  = 311,
        [6]  = 311,
        [7]  = 315,
        [8]  = 315,
        [9]  = 315,
        [10] = 318,
    },

    ["World"] = {
        [1]  = 279,
        [2]  = 282,
        [3]  = 285,
        [4]  = 289,
        [5]  = 292,
        [6]  = 295,
        [7]  = 298,
        [8]  = 302,
        [9]  = 305,
        [10] = 305,
        [11] = 305,
    },

    ["Raids"] = {
        [14] = 292, -- Raid Finder
        [15] = 305, -- Normal
        [16] = 318, -- Heroic
        [17] = 334, -- Mythic
    }
}

function Private:FetchFont(Font)
    return Private.LSM:Fetch("font", Font)
end

function Private:FetchSound(Sound)
    return Private.LSM:Fetch("sound", Sound)
end

function Private:SetMover(isEnabled, moverName, moverLayout)
    if not isEnabled then return end
    if isEnabled and moverName and moverLayout then
        Private.E.db.movers[moverName] = moverLayout
        Private.E:SetMoverPoints(moverName)
        Private.E:SaveMoverPosition(moverName)
    end
end

function Private:UpdateMover(isEnabled, moverName, moverLayout)
    if isEnabled and moverName and moverLayout then
        Private.E.db.movers[moverName] = moverLayout
        Private.E:SetMoverPoints(moverName)
        Private.E:SaveMoverPosition(moverName)
    end
    Private.E:LoadMovers()
end

function Private:FetchReactionColour()
    local PVPZone = C_PvP.GetZonePVPInfo()
    if PVPZone == "arena" then
        ReactionColour = {r = 0.84, g = 0.03, b = 0.03}
    elseif PVPZone == "friendly" then
        ReactionColour = {r = 0.05, g = 0.85, b = 0.03}
    elseif PVPZone == "contested" then
        ReactionColour = {r = 0.9, g = 0.85, b = 0.05}
    elseif PVPZone == "hostile" then
        ReactionColour = {r = 0.84, g = 0.03, b = 0.03}
    elseif PVPZone == "sanctuary" then
        ReactionColour = {r = 0.035, g = 0.58, b = 0.84}
    elseif PVPZone == "combat" then
        ReactionColour = {r = 0.84, g = 0.03, b = 0.03}
    else
        ReactionColour = {r = 0.9, g = 0.85, b = 0.05}
    end

    return ReactionColour
end

function Private:SetVisibilityConditions(actionBar)
    local E = Private.E
    local DB = E.db.actionbar[actionBar]
    local AB = E:GetModule("ActionBars")

    DB.paging[E.myclass] = "[overridebar] 18; [vehicleui] 16; [possessbar] 16; [bonusbar:5] 11;"
    DB.visibility = "[target=vehicle,exists]show;[overridebar]show;[possessbar]show;[bonusbar:5]show;hide"

    AB:UpdateButtonSettings(actionBar)
end

function Private:StripRealm(Name, ClassFilename)
    if ClassFilename == "" then return Name end
    return Ambiguate(Name, "short")
end

function Private:AbbreviateValue(value)
    local AbbreviationData = C_StringUtil.GetDefaultAbbreviationBreakpoints()
    AbbreviationData[#AbbreviationData + 1] = {breakpoint = 1e-6, abbreviation = "", significandDivisor = 0.1, fractionDivisor = 10, abbreviationIsGlobal = false}
    return AbbreviateNumbers(value, {config = CreateAbbreviateConfig(AbbreviationData)})
end

function Private:IsAddOnLoaded(AddOnName)
    return C_AddOns.IsAddOnLoaded(AddOnName)
end

function Private:IsDeveloper()
    local _, BTag = BNGetInfo()
    local isDeveloper = BTag == "Unhalted#2639"
    return isDeveloper
end