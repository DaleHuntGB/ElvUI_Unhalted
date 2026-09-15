local Private = select(2, ...)
local ACH = Private.ACH
local ACR = Private.ACR

--[[
    ACH:Color(name, desc, order, alpha, width, get, set, disabled, hidden)
    ACH:Description(name, order, fontSize, image, imageCoords, imageWidth, imageHeight, width, hidden)
    ACH:Execute(name, desc, order, func, image, confirm, width, get, set, disabled, hidden)
    ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden, func)
    ACH:Header(name, order, get, set, hidden)
    ACH:Input(name, desc, order, multiline, width, get, set, disabled, hidden, validate)
    ACH:Select(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
    ACH:MultiSelect(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
    ACH:Toggle(name, desc, order, tristate, confirm, width, get, set, disabled, hidden)
    ACH:Range(name, desc, order, values, width, get, set, disabled, hidden)
    ACH:Spacer(order, width, hidden)
    ACH:SharedMediaFont(name, desc, order, width, get, set, disabled, hidden)
    ACH:FontFlags(name, desc, order, width, get, set, disabled, hidden)
]]

function Private:CreateGUI()
    local GUI = Private.GUI
    local DB = Private.DB.global

    GUI = ACH:Group(format("|T%s:18:18|t%s", "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Logo_64.png", Private.AddOnName), nil, 20, "tree")

    --#region - AddOn Skins

    GUI.args.AddOnSKins = ACH:Group("AddOn Skins", nil, 1)
    GUI.args.AddOnSKins.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\AddOnSkins.tga"
    GUI.args.AddOnSKins.args.LSToasts = ACH:Toggle("|TInterface\\AddOns\\ls_Toasts\\assets\\logo-32.TGA:16:16|t LS: |cFF1CD3A2Toasts|r", "Add a custom skin for LS: |cFF1CD3A2Toasts|r.", 1, nil, nil, "full", function() return DB.AddOnSkins.LSToasts end, function(_, value) DB.AddOnSkins.LSToasts = value Private:PromptReload() end, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
    GUI.args.AddOnSKins.args.LSToasts.descStyle = "inline"
    GUI.args.AddOnSKins.args.BugSack = ACH:Toggle("|TInterface\\AddOns\\BugSack\\Media\\icon:16:16|t BugSack", "Skins the Bugsack Minimap icon to be more inline with the UI.", 2, nil, nil, "full", function() return DB.AddOnSkins.BugSack end, function(_, value) DB.AddOnSkins.BugSack = value Private:PromptReload() end, not C_AddOns.IsAddOnLoaded("BugSack"))
    GUI.args.AddOnSKins.args.BugSack.descStyle = "inline"

    GUI.args.AddOnSKins.args.BigWigs = ACH:Toggle("|TInterface\\AddOns\\BigWigs\\Media\\Icons\\minimap_raid.tga:16:16|t BigWigs", "Skins Queue Timer & Keys Panel.", 3, nil, nil, "full", function() return DB.AddOnSkins.BigWigs end, function(_, value) DB.AddOnSkins.BigWigs = value Private:PromptReload() end, not C_AddOns.IsAddOnLoaded("BigWigs"))
    GUI.args.AddOnSKins.args.BigWigs.descStyle = "inline"

    --#endregion

    --#region - Combat Alert

    GUI.args.CombatAlert = ACH:Group("Combat Alert", nil, 2)
    GUI.args.CombatAlert.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\CombatAlert.tga"
    GUI.args.CombatAlert.args.Enabled = ACH:Toggle("Enabled", nil, 1, nil, nil, "full", function() return DB.CombatAlert.Enabled end, function(_, value) DB.CombatAlert.Enabled = value Private:UpdateCombatAlert() end)

    GUI.args.CombatAlert.args.Layout = ACH:Group("Layout", nil, 2)
    GUI.args.CombatAlert.args.Layout.inline = true
    GUI.args.CombatAlert.args.Layout.disabled = function() return not DB.CombatAlert.Enabled end
    GUI.args.CombatAlert.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DB.CombatAlert.Layout[1] end, function(_, value) DB.CombatAlert.Layout[1] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Layout.args.AnchorFrom.relWidth = 0.5
    GUI.args.CombatAlert.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DB.CombatAlert.Layout[2] end, function(_, value) DB.CombatAlert.Layout[2] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Layout.args.AnchorTo.relWidth = 0.5
    GUI.args.CombatAlert.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.CombatAlert.Layout[3] end, function(_, value) DB.CombatAlert.Layout[3] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Layout.args.XOffset.relWidth = 0.5
    GUI.args.CombatAlert.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.CombatAlert.Layout[4] end, function(_, value) DB.CombatAlert.Layout[4] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Layout.args.YOffset.relWidth = 0.5

    GUI.args.CombatAlert.args.Font = ACH:Group("Font", nil, 3)
    GUI.args.CombatAlert.args.Font.inline = true
    GUI.args.CombatAlert.args.Font.disabled = function() return not DB.CombatAlert.Enabled end

    GUI.args.CombatAlert.args.Font.args.Font = ACH:SharedMediaFont("Font", nil, 1, "relative", function() return DB.CombatAlert.Font[1] end, function(_, value) DB.CombatAlert.Font[1] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.Font.relWidth = 0.33
    GUI.args.CombatAlert.args.Font.args.Size = ACH:Range("Size", nil, 2, { min = 8, max = 32, step = 1 }, "relative", function() return DB.CombatAlert.Font[2] end, function(_, value) DB.CombatAlert.Font[2] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.Size.relWidth = 0.33
    GUI.args.CombatAlert.args.Font.args.FontFlag = ACH:FontFlags("Font Flags", nil, 3, "relative", function() return DB.CombatAlert.Font[3] end, function(_, value) DB.CombatAlert.Font[3] = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.FontFlag.relWidth = 0.33
    GUI.args.CombatAlert.args.Font.args.HoldTime = ACH:Range("Hold Time", nil, 4, { min = 0, max = 10, step = 0.1 }, "full", function() return DB.CombatAlert.HoldTime end, function(_, value) DB.CombatAlert.HoldTime = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.EnterCombatHeader = ACH:Header("Entering Combat", 5)
    GUI.args.CombatAlert.args.Font.args.EnterCombatColour = ACH:Color("Colour", nil, 6, true, "relative", function() return unpack(DB.CombatAlert.EnteringCombatColour) end, function(_, r, g, b, a) DB.CombatAlert.EnteringCombatColour = { r, g, b, a } Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.EnterCombatColour.relWidth = 0.5
    GUI.args.CombatAlert.args.Font.args.EnteringCombatText = ACH:Input("Text", nil, 7, nil, "relative", function() return DB.CombatAlert.EnteringCombat end, function(_, value) DB.CombatAlert.EnteringCombat = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.EnteringCombatText.relWidth = 0.5
    GUI.args.CombatAlert.args.Font.args.ExitingCombatHeader = ACH:Header("Exiting Combat", 8)
    GUI.args.CombatAlert.args.Font.args.ExitingCombatColour = ACH:Color("Colour", nil, 9, true, "relative", function() return unpack(DB.CombatAlert.ExitingCombatColour) end, function(_, r, g, b, a) DB.CombatAlert.ExitingCombatColour = { r, g, b, a } Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.ExitingCombatColour.relWidth = 0.5
    GUI.args.CombatAlert.args.Font.args.ExitingCombatText = ACH:Input("Text", nil, 10, nil, "relative", function() return DB.CombatAlert.ExitingCombat end, function(_, value) DB.CombatAlert.ExitingCombat = value Private:UpdateCombatAlert() end)
    GUI.args.CombatAlert.args.Font.args.ExitingCombatText.relWidth = 0.5

    --#endregion

    --#region - Combat Timer

    GUI.args.CombatTimer = ACH:Group("Combat Timer", nil, 2)
    GUI.args.CombatTimer.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\CombatTimer.tga"
    GUI.args.CombatTimer.args.Enabled = ACH:Toggle("Enabled", nil, 1, nil, nil, "full", function() return DB.CombatTimer.Enabled end, function(_, value) DB.CombatTimer.Enabled = value Private:UpdateCombatTimer() end)

    GUI.args.CombatTimer.args.Layout = ACH:Group("Layout", nil, 2)
    GUI.args.CombatTimer.args.Layout.inline = true
    GUI.args.CombatTimer.args.Layout.disabled = function() return not DB.CombatTimer.Enabled end
    GUI.args.CombatTimer.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DB.CombatTimer.Layout[1] end, function(_, value) DB.CombatTimer.Layout[1] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Layout.args.AnchorFrom.relWidth = 0.5
    GUI.args.CombatTimer.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DB.CombatTimer.Layout[2] end, function(_, value) DB.CombatTimer.Layout[2] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Layout.args.AnchorTo.relWidth = 0.5
    GUI.args.CombatTimer.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.CombatTimer.Layout[3] end, function(_, value) DB.CombatTimer.Layout[3] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Layout.args.XOffset.relWidth = 0.5
    GUI.args.CombatTimer.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.CombatTimer.Layout[4] end, function(_, value) DB.CombatTimer.Layout[4] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Layout.args.YOffset.relWidth = 0.5

    GUI.args.CombatTimer.args.Font = ACH:Group("Font", nil, 3)
    GUI.args.CombatTimer.args.Font.inline = true
    GUI.args.CombatTimer.args.Font.disabled = function() return not DB.CombatTimer.Enabled end

    GUI.args.CombatTimer.args.Font.args.Font = ACH:SharedMediaFont("Font", nil, 1, "relative", function() return DB.CombatTimer.Font[1] end, function(_, value) DB.CombatTimer.Font[1] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Font.args.Font.relWidth = 0.33
    GUI.args.CombatTimer.args.Font.args.Size = ACH:Range("Size", nil, 2, { min = 8, max = 32, step = 1 }, "relative", function() return DB.CombatTimer.Font[2] end, function(_, value) DB.CombatTimer.Font[2] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Font.args.Size.relWidth = 0.33
    GUI.args.CombatTimer.args.Font.args.FontFlag = ACH:FontFlags("Font Flags", nil, 3, "relative", function() return DB.CombatTimer.Font[3] end, function(_, value) DB.CombatTimer.Font[3] = value Private:UpdateCombatTimer() end)
    GUI.args.CombatTimer.args.Font.args.FontFlag.relWidth = 0.33
    GUI.args.CombatTimer.args.Font.args.OOCAlpha = ACH:Range("Out Of Combat Alpha", nil, 4, { min = 0, max = 1, step = 0.1 }, "full", function() return DB.CombatTimer.OutOfCombatAlpha end, function(_, value) DB.CombatTimer.OutOfCombatAlpha = value Private:UpdateCombatTimer() end)

    --#endregion

    --#region - CVars

    GUI.args.CVars = ACH:Group("CVars", nil, 3)
    GUI.args.CVars.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\CVars.tga"
    GUI.args.CVars.args.SyncCVars = ACH:Toggle("Sync CVars", "Sync CVars across all characters on the account.", 1, nil, nil, "full", function() return DB.CVars.SyncCVars end, function(_, value) DB.CVars.SyncCVars = value Private:SyncCVars() Private:PromptReload() end)
    GUI.args.CVars.args.SyncCVars.descStyle = "inline"

    GUI.args.CVars.args.Toggles = ACH:Group("Toggles", nil, 1)
    GUI.args.CVars.args.Toggles.inline = true

    GUI.args.CVars.args.Toggles.args.autoLootDefault = ACH:Toggle("Auto Loot", nil, 1, nil, nil, "relative", function() return C_CVar.GetCVarBool("autoLootDefault") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.autoLootDefault = value end C_CVar.SetCVar("autoLootDefault", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.autoLootDefault.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.floatingCombatTextCombatDamage_v2 = ACH:Toggle("Floating Combat Text: Damage", nil, 2, nil, nil, "relative", function() return C_CVar.GetCVarBool("floatingCombatTextCombatDamage_v2") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.floatingCombatTextCombatDamage_v2 = value end C_CVar.SetCVar("floatingCombatTextCombatDamage_v2", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.floatingCombatTextCombatDamage_v2.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.floatingCombatTextCombatHealing_v2 = ACH:Toggle("Floating Combat Text: Healing", nil, 3, nil, nil, "relative", function() return C_CVar.GetCVarBool("floatingCombatTextCombatHealing_v2") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.floatingCombatTextCombatHealing_v2 = value end C_CVar.SetCVar("floatingCombatTextCombatHealing_v2", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.floatingCombatTextCombatHealing_v2.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.ffxDeath = ACH:Toggle("Death Effect", nil, 4, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxDeath") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.ffxDeath = value end C_CVar.SetCVar("ffxDeath", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.ffxDeath.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.ffxGlow = ACH:Toggle("Screen Glow", nil, 5, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxGlow") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.ffxGlow = value end C_CVar.SetCVar("ffxGlow", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.ffxGlow.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.ResampleAlwaysSharpen = ACH:Toggle("Always Sharpen", nil, 6, nil, nil, "relative", function() return C_CVar.GetCVarBool("ResampleAlwaysSharpen") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.ResampleAlwaysSharpen = value end C_CVar.SetCVar("ResampleAlwaysSharpen", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.ResampleAlwaysSharpen.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.AutoPushSpellToActionBar = ACH:Toggle("Auto Push Spells To Action Bar", nil, 7, nil, nil, "relative", function() return C_CVar.GetCVarBool("AutoPushSpellToActionBar") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.AutoPushSpellToActionBar = value end C_CVar.SetCVar("AutoPushSpellToActionBar", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.AutoPushSpellToActionBar.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.showTutorials = ACH:Toggle("Show Tutorials", nil, 8, nil, nil, "relative", function() return C_CVar.GetCVarBool("showTutorials") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.showTutorials = value end C_CVar.SetCVar("showTutorials", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.showTutorials.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.worldMapShowCursorCoords = ACH:Toggle("World Map: Show Cursor Coordinates", nil, 9, nil, nil, "relative", function() return C_CVar.GetCVarBool("worldMapShowCursorCoords") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.worldMapShowCursorCoords = value end C_CVar.SetCVar("worldMapShowCursorCoords", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.worldMapShowCursorCoords.relWidth = 0.33
    GUI.args.CVars.args.Toggles.args.worldMapShowPlayerCoords = ACH:Toggle("World Map: Show Player Coordinates", nil, 10, nil, nil, "relative", function() return C_CVar.GetCVarBool("worldMapShowPlayerCoords") end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.worldMapShowPlayerCoords = value end C_CVar.SetCVar("worldMapShowPlayerCoords", value and "1" or "0") end)
    GUI.args.CVars.args.Toggles.args.worldMapShowPlayerCoords.relWidth = 0.33

    GUI.args.CVars.args.Sliders = ACH:Group("Sliders", nil, 2)
    GUI.args.CVars.args.Sliders.inline = true


    GUI.args.CVars.args.Sliders.args.SpellQueueWindow = ACH:Range("Spell Queue Window", nil, 1, { min = 0, max = 400, step = 1 }, "relative", function() return tonumber(C_CVar.GetCVar("SpellQueueWindow")) end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.SpellQueueWindow = value end C_CVar.SetCVar("SpellQueueWindow", value) end)
    GUI.args.CVars.args.Sliders.args.SpellQueueWindow.relWidth = 0.5
    GUI.args.CVars.args.Sliders.args.RAIDWaterDetail = ACH:Range("Raid: Water Detail", nil, 2, { min = 0, max = 3, step = 1 }, "relative", function() return tonumber(C_CVar.GetCVar("RAIDWaterDetail")) end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.RAIDWaterDetail = value end C_CVar.SetCVar("RAIDWaterDetail", value) end)
    GUI.args.CVars.args.Sliders.args.RAIDWaterDetail.relWidth = 0.5
    GUI.args.CVars.args.Sliders.args.RAIDweatherDensity = ACH:Range("Raid: Weather Density", nil, 3, { min = 0, max = 3, step = 1 }, "relative", function() return tonumber(C_CVar.GetCVar("RAIDweatherDensity")) end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.RAIDweatherDensity = value end C_CVar.SetCVar("RAIDweatherDensity", value) end)
    GUI.args.CVars.args.Sliders.args.RAIDweatherDensity.relWidth = 0.5
    GUI.args.CVars.args.Sliders.args.autoLootRate = ACH:Range("Auto Loot: Rate", nil, 4, { min = 0, max = 250, step = 1 }, "relative", function() return tonumber(C_CVar.GetCVar("autoLootRate")) end, function(_, value) if DB.CVars.SyncCVars then DB.CVars.autoLootRate = value end C_CVar.SetCVar("autoLootRate", value) end)
    GUI.args.CVars.args.Sliders.args.autoLootRate.relWidth = 0.5

    --#endregion

    --#region - Damage Meter

    GUI.args.DamageMeter = ACH:Group("Damage Meter", nil, 3.5, "tab")
    GUI.args.DamageMeter.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\DamageMeter.tga"

    GUI.args.DamageMeter.args.AutoResetOnMythicPlus = ACH:Toggle("Auto Reset: Start of Mythic+", nil, 1, nil, nil, "relative", function() return DB.DamageMeter.AutoResetOnMythicPlus end, function(_, value) DB.DamageMeter.AutoResetOnMythicPlus = value Private:UpdateDamageMeter() end)
    GUI.args.DamageMeter.args.AutoResetOnMythicPlus.descStyle = "inline"
    GUI.args.DamageMeter.args.AutoResetOnMythicPlus.relWidth = 0.5
    GUI.args.DamageMeter.args.TestMode = ACH:Toggle("Test Mode", nil, 2, nil, nil, "relative", function() return Private.DamageMeterTestMode end, function(_, value) Private:SetDamageMeterTestMode(value) end)
    GUI.args.DamageMeter.args.TestMode.relWidth = 0.5

    for IDX, DMDB in ipairs(DB.DamageMeter) do
        local Window = ACH:Group("Window " .. IDX, nil, IDX, "tab")
        GUI.args.DamageMeter.args["Window" .. IDX] = Window

        Window.args.General = ACH:Group("General", nil, 1)
        Window.args.General.args.Enabled = ACH:Toggle("Enabled", nil, 1, nil, nil, "relative", function() return DMDB.Enabled end, function(_, value) DMDB.Enabled = value Private:UpdateDamageMeter() end)
        Window.args.General.args.Enabled.relWidth = 0.5
        -- Window.args.General.args.ShowBackdrop = ACH:Toggle("Show Backdrop", nil, 2, nil, nil, "relative", function() return DMDB.ShowBackdrop end, function(_, value) DMDB.ShowBackdrop = value Private:UpdateDamageMeter() end, function() return not DMDB.Enabled end)
        -- Window.args.General.args.ShowBackdrop.relWidth = 0.5

        Window.args.General.args.MeterData = ACH:Group("Meter Data", nil, 4)
        Window.args.General.args.MeterData.inline = true
        Window.args.General.args.MeterData.disabled = function() return not DMDB.Enabled end
        Window.args.General.args.MeterData.args.MeterType = ACH:Select("Type", nil, 1, Private.MeterTypes, nil, "relative", function() return DMDB.MeterType end, function(_, value) Private:SetDamageMeterType(Private.DamageMeterFrames[IDX], value, DMDB.SessionType) end)
        Window.args.General.args.MeterData.args.MeterType.relWidth = 0.5
        Window.args.General.args.MeterData.args.SessionType = ACH:Select("Session", nil, 2, { [Enum.DamageMeterSessionType.Current] = "Current", [Enum.DamageMeterSessionType.Overall] = "Overall" }, nil, "relative", function() return DMDB.SessionType end, function(_, value) Private:SetDamageMeterType(Private.DamageMeterFrames[IDX], DMDB.MeterType, value) end)
        Window.args.General.args.MeterData.args.SessionType.relWidth = 0.5

        Window.args.Layout = ACH:Group("Layout", nil, 2)
        Window.args.Layout.disabled = function() return not DMDB.Enabled end
        Window.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DMDB.Layout[1] end, function(_, value) DMDB.Layout[1] = value Private:UpdateDamageMeter() end)
        Window.args.Layout.args.AnchorFrom.relWidth = 0.5
        Window.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DMDB.Layout[2] end, function(_, value) DMDB.Layout[2] = value Private:UpdateDamageMeter() end)
        Window.args.Layout.args.AnchorTo.relWidth = 0.5
        Window.args.Layout.args.Width = ACH:Range("Width", nil, 3, { min = function() return math.max(100, math.ceil((DMDB.Size[2] - 2 - (DMDB.Rows.Num - 1) * DMDB.Rows.Spacing) / DMDB.Rows.Num) + 10) end, max = 1000, step = 1 }, "relative", function() return DMDB.Size[1] end, function(_, value) DMDB.Size[1] = value Private:UpdateDamageMeter() end)
        Window.args.Layout.args.Width.relWidth = 0.5
        Window.args.Layout.args.Height = ACH:Range("Height", nil, 4, { min = function() return 2 + DMDB.Rows.Num * 8 + (DMDB.Rows.Num - 1) * DMDB.Rows.Spacing end, max = function() return math.min(1000, 2 + DMDB.Rows.Num * (DMDB.Size[1] - 10) + (DMDB.Rows.Num - 1) * DMDB.Rows.Spacing) end, step = 1 }, "relative", function() return DMDB.Size[2] end, function(_, value) DMDB.Size[2] = value Private:UpdateDamageMeter() end)
        Window.args.Layout.args.Height.relWidth = 0.5
        Window.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 5, { min = -1000, max = 1000, step = 1 }, "relative", function() return DMDB.Layout[3] end, function(_, value) DMDB.Layout[3] = value Private:UpdateDamageMeter() end)
        Window.args.Layout.args.XOffset.relWidth = 0.5
        Window.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 6, { min = -1000, max = 1000, step = 1 }, "relative", function() return DMDB.Layout[4] end, function(_, value) DMDB.Layout[4] = value Private:UpdateDamageMeter() end)
        Window.args.Layout.args.YOffset.relWidth = 0.5

        Window.args.TitleBar = ACH:Group("Title Bar", nil, 3)
        Window.args.TitleBar.disabled = function() return not DMDB.Enabled end
        -- Window.args.TitleBar.args.Enabled = ACH:Toggle("Enabled", nil, 1, nil, nil, "relative", function() return DMDB.TitleBar.Enabled end, function(_, value) DMDB.TitleBar.Enabled = value Private:UpdateDamageMeter() end)
        -- Window.args.TitleBar.args.Enabled.relWidth = 1

        Window.args.TitleBar.args.Icons = ACH:Group("Icons", nil, 1)
        Window.args.TitleBar.args.Icons.inline = true
        Window.args.TitleBar.args.Icons.disabled = function() return not DMDB.Enabled or not DMDB.TitleBar.Enabled end
        Window.args.TitleBar.args.Icons.args.MouseoverIcons = ACH:Toggle("Mouseover Icons", nil, 0, nil, nil, "relative", function() return DMDB.TitleBar.MouseoverIcons end, function(_, value) DMDB.TitleBar.MouseoverIcons = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Icons.args.MouseoverIcons.relWidth = 0.33
        Window.args.TitleBar.args.Icons.args.ResetButton = ACH:Toggle("Reset Button", nil, 1, nil, nil, "relative", function() return DMDB.TitleBar.Icons.ResetButton end, function(_, value) DMDB.TitleBar.Icons.ResetButton = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Icons.args.ResetButton.relWidth = 0.33
        Window.args.TitleBar.args.Icons.args.EncountersButton = ACH:Toggle("Encounters Button", nil, 2, nil, nil, "relative", function() return DMDB.TitleBar.Icons.EncountersButton end, function(_, value) DMDB.TitleBar.Icons.EncountersButton = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Icons.args.EncountersButton.relWidth = 0.33

        Window.args.TitleBar.args.Layout = ACH:Group("Layout", nil, 2)
        Window.args.TitleBar.args.Layout.inline = true
        Window.args.TitleBar.args.Layout.disabled = function() return not DMDB.Enabled or not DMDB.TitleBar.Enabled end
        Window.args.TitleBar.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DMDB.TitleBar.Layout[1] end, function(_, value) DMDB.TitleBar.Layout[1] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Layout.args.AnchorFrom.relWidth = 0.5
        Window.args.TitleBar.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DMDB.TitleBar.Layout[2] end, function(_, value) DMDB.TitleBar.Layout[2] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Layout.args.AnchorTo.relWidth = 0.5
        Window.args.TitleBar.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -1000, max = 1000, step = 1 }, "relative", function() return DMDB.TitleBar.Layout[3] end, function(_, value) DMDB.TitleBar.Layout[3] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Layout.args.XOffset.relWidth = 0.33
        Window.args.TitleBar.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -1000, max = 1000, step = 1 }, "relative", function() return DMDB.TitleBar.Layout[4] end, function(_, value) DMDB.TitleBar.Layout[4] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Layout.args.YOffset.relWidth = 0.33
        Window.args.TitleBar.args.Layout.args.Height = ACH:Range("Height", nil, 5, { min = 8, max = 100, step = 1 }, "relative", function() return DMDB.TitleBar.Height end, function(_, value) DMDB.TitleBar.Height = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Layout.args.Height.relWidth = 0.33

        Window.args.TitleBar.args.Font = ACH:Group("Font", nil, 3)
        Window.args.TitleBar.args.Font.inline = true
        Window.args.TitleBar.args.Font.disabled = function() return not DMDB.Enabled or not DMDB.TitleBar.Enabled end
        Window.args.TitleBar.args.Font.args.Font = ACH:SharedMediaFont("Font", nil, 1, "relative", function() return DMDB.TitleBar.Font[1] end, function(_, value) DMDB.TitleBar.Font[1] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Font.args.Font.relWidth = 0.5
        Window.args.TitleBar.args.Font.args.FontFlag = ACH:FontFlags("Font Flags", nil, 2, "relative", function() return DMDB.TitleBar.Font[3] end, function(_, value) DMDB.TitleBar.Font[3] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Font.args.FontFlag.relWidth = 0.5
        Window.args.TitleBar.args.Font.args.Size = ACH:Range("Font Size", nil, 3, { min = 8, max = 32, step = 1 }, "relative", function() return DMDB.TitleBar.Font[2] end, function(_, value) DMDB.TitleBar.Font[2] = value Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Font.args.Size.relWidth = 0.5
        Window.args.TitleBar.args.Font.args.Colour = ACH:Color("Colour", nil, 4, true, "relative", function() return unpack(DMDB.TitleBar.Colour) end, function(_, r, g, b, a) DMDB.TitleBar.Colour = { r, g, b, a } Private:UpdateDamageMeter() end)
        Window.args.TitleBar.args.Font.args.Colour.relWidth = 0.5

        Window.args.Rows = ACH:Group("Rows", nil, 4)
        Window.args.Rows.disabled = function() return not DMDB.Enabled end
        Window.args.Rows.args.Num = ACH:Range("Number of Rows", nil, 1, { min = function() return math.max(1, math.ceil((DMDB.Size[2] - 2 + DMDB.Rows.Spacing) / (DMDB.Size[1] - 10 + DMDB.Rows.Spacing))) end, max = function() return math.min(40, math.floor((DMDB.Size[2] - 2 + DMDB.Rows.Spacing) / (8 + DMDB.Rows.Spacing))) end, step = 1 }, "relative", function() return DMDB.Rows.Num end, function(_, value) DMDB.Rows.Num = value Private:UpdateDamageMeter() end)
        Window.args.Rows.args.Num.relWidth = 0.5
        Window.args.Rows.args.Spacing = ACH:Range("Spacing", nil, 2, { min = function() return DMDB.Rows.Num > 1 and math.max(0, math.ceil((DMDB.Size[2] - 2 - DMDB.Rows.Num * (DMDB.Size[1] - 10)) / (DMDB.Rows.Num - 1))) or 0 end, max = function() return DMDB.Rows.Num > 1 and math.min(20, math.floor((DMDB.Size[2] - 2 - DMDB.Rows.Num * 8) / (DMDB.Rows.Num - 1))) or 20 end, step = 1 }, "relative", function() return DMDB.Rows.Spacing end, function(_, value) DMDB.Rows.Spacing = value Private:UpdateDamageMeter() end)
        Window.args.Rows.args.Spacing.relWidth = 0.5
        Window.args.Rows.args.Texture = ACH:SharedMediaStatusbar("Texture", nil, 3, "relative", function() return DMDB.Rows.Texture end, function(_, value) DMDB.Rows.Texture = value Private:UpdateDamageMeter() end)
        Window.args.Rows.args.Texture.relWidth = 1

        Window.args.Text = ACH:Group("Text", nil, 5)
        Window.args.Text.disabled = function() return not DMDB.Enabled end

        for TextIDX, TextType in ipairs({ "Name", "Amount" }) do
            local TextDB = DMDB[TextType]
            local Text = ACH:Group(TextType, nil, TextIDX)
            Text.inline = true
            Window.args.Text.args[TextType] = Text

            Text.args.Layout = ACH:Group("Layout", nil, 1)
            Text.args.Layout.inline = true
            Text.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return TextDB.Layout[1] end, function(_, value) TextDB.Layout[1] = value Private:UpdateDamageMeter() end)
            Text.args.Layout.args.AnchorFrom.relWidth = 0.5
            Text.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return TextDB.Layout[2] end, function(_, value) TextDB.Layout[2] = value Private:UpdateDamageMeter() end)
            Text.args.Layout.args.AnchorTo.relWidth = 0.5
            Text.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -1000, max = 1000, step = 1 }, "relative", function() return TextDB.Layout[3] end, function(_, value) TextDB.Layout[3] = value Private:UpdateDamageMeter() end)
            Text.args.Layout.args.XOffset.relWidth = 0.5
            Text.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -1000, max = 1000, step = 1 }, "relative", function() return TextDB.Layout[4] end, function(_, value) TextDB.Layout[4] = value Private:UpdateDamageMeter() end)
            Text.args.Layout.args.YOffset.relWidth = 0.5

            Text.args.Font = ACH:Group("Font", nil, 2)
            Text.args.Font.inline = true
            Text.args.Font.args.ColourByClass = ACH:Toggle("Colour By Class", nil, 1, nil, nil, "relative", function() return TextDB.ColourByClass end, function(_, value) TextDB.ColourByClass = value Private:UpdateDamageMeter() end)
            Text.args.Font.args.ColourByClass.relWidth = 1
            Text.args.Font.args.Font = ACH:SharedMediaFont("Font", nil, 2, "relative", function() return TextDB.Font[1] end, function(_, value) TextDB.Font[1] = value Private:UpdateDamageMeter() end)
            Text.args.Font.args.Font.relWidth = 0.5
            Text.args.Font.args.FontFlag = ACH:FontFlags("Font Flags", nil, 3, "relative", function() return TextDB.Font[3] end, function(_, value) TextDB.Font[3] = value Private:UpdateDamageMeter() end)
            Text.args.Font.args.FontFlag.relWidth = 0.5
            Text.args.Font.args.Size = ACH:Range("Font Size", nil, 4, { min = 8, max = 32, step = 1 }, "relative", function() return TextDB.Font[2] end, function(_, value) TextDB.Font[2] = value Private:UpdateDamageMeter() end)
            Text.args.Font.args.Size.relWidth = 0.5
            Text.args.Font.args.Colour = ACH:Color("Colour", nil, 5, true, "relative", function() return unpack(TextDB.Colour) end, function(_, r, g, b, a) TextDB.Colour = { r, g, b, a } Private:UpdateDamageMeter() end, function() return not DMDB.Enabled or TextDB.ColourByClass end)
            Text.args.Font.args.Colour.relWidth = 0.5
        end
    end

    --#endregion

    --#region - ElvUI Enhancements

    GUI.args.ElvUIEnhancements = ACH:Group("|cFF1784D1ElvUI|r Enhancements", nil, 4)
    GUI.args.ElvUIEnhancements.icon = "Interface\\AddOns\\ElvUI\\Game\\Shared\\Media\\Textures\\LogoAddon.tga"
    GUI.args.ElvUIEnhancements.args.ForceAlphaOnLootRoll = ACH:Toggle("Loot Roll: Fix Backdrop", "Force the opacity of the backdrop to be consistent with the rest of the UI.", 1, nil, nil, "full", function() return DB.ElvUIEnhancements.ForceAlphaOnLootRoll end, function(_, value) DB.ElvUIEnhancements.ForceAlphaOnLootRoll = value Private:PromptReload() end)
    GUI.args.ElvUIEnhancements.args.ForceAlphaOnLootRoll.descStyle = "inline"

    GUI.args.ElvUIEnhancements.args.ActionStatus = ACH:Group("Action Status", nil, 2)
    GUI.args.ElvUIEnhancements.args.ActionStatus.inline = true
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Enabled = ACH:Toggle("Enabled", nil, 1, nil, nil, "full", function() return DB.ElvUIEnhancements.ActionStatus.Enabled end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Enabled = value Private:UpdateElvUIEnhancements() end)

    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout = ACH:Group("Layout", nil, 2)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.inline = true
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.disabled = function() return not DB.ElvUIEnhancements.ActionStatus.Enabled end
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Layout[1] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Layout[1] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.AnchorFrom.relWidth = 0.5
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Layout[2] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Layout[2] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.AnchorTo.relWidth = 0.5
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Layout[3] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Layout[3] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.XOffset.relWidth = 0.5
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Layout[4] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Layout[4] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Layout.args.YOffset.relWidth = 0.5

    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font = ACH:Group("Font", nil, 3)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.inline = true
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.disabled = function() return not DB.ElvUIEnhancements.ActionStatus.Enabled end
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.args.Font = ACH:SharedMediaFont("Font", nil, 1, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Font[1] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Font[1] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.args.Font.relWidth = 0.33
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.args.FontFlags = ACH:FontFlags("Font Flags", nil, 3, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Font[3] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Font[3] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.args.FontFlags.relWidth = 0.33
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.args.Size = ACH:Range("Size", nil, 2, { min = 6, max = 32, step = 1 }, "relative", function() return DB.ElvUIEnhancements.ActionStatus.Font[2] end, function(_, value) DB.ElvUIEnhancements.ActionStatus.Font[2] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.ActionStatus.args.Font.args.Size.relWidth = 0.33

    GUI.args.ElvUIEnhancements.args.UIErrorsFrame = ACH:Group("UI Errors", nil, 3)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.inline = true
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Enabled = ACH:Toggle("Enabled", nil, 1, nil, nil, "relative", function() return DB.ElvUIEnhancements.UIErrorsFrame.Enabled end, function(_, value) DB.ElvUIEnhancements.UIErrorsFrame.Enabled = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Enabled.relWidth = 1

    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout = ACH:Group("Layout", nil, 2)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.inline = true
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.disabled = function() return not DB.ElvUIEnhancements.UIErrorsFrame.Enabled end
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DB.ElvUIEnhancements.UIErrorsFrame.Layout[1] end, function(_, value) DB.ElvUIEnhancements.UIErrorsFrame.Layout[1] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.AnchorFrom.relWidth = 0.5
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DB.ElvUIEnhancements.UIErrorsFrame.Layout[2] end, function(_, value) DB.ElvUIEnhancements.UIErrorsFrame.Layout[2] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.AnchorTo.relWidth = 0.5
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.ElvUIEnhancements.UIErrorsFrame.Layout[3] end, function(_, value) DB.ElvUIEnhancements.UIErrorsFrame.Layout[3] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.XOffset.relWidth = 0.5
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -1000, max = 1000, step = 1 }, "relative", function() return DB.ElvUIEnhancements.UIErrorsFrame.Layout[4] end, function(_, value) DB.ElvUIEnhancements.UIErrorsFrame.Layout[4] = value Private:UpdateElvUIEnhancements() end)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.Layout.args.YOffset.relWidth = 0.5

    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.FontDesc = ACH:Description("|cFFCC4040PLEASE NOTE|r: Font, Font Flag & Font Size for this UI Element is controlled by |cFF1784D1ElvUI|r via their options.", 3, nil, nil, nil, nil, nil, "relative", nil)
    GUI.args.ElvUIEnhancements.args.UIErrorsFrame.args.FontDesc.relWidth = 1

    --#endregion

    --#region - Profile Manager

    GUI.args.ProfileManager = ACH:Group("Profile Manager", nil, 4)
    GUI.args.ProfileManager.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\ProfileManager.tga"

    GUI.args.ProfileManager.args.ImportElvUI = ACH:Execute("Import |TInterface\\AddOns\\ElvUI\\Game\\Shared\\Media\\Textures\\LogoAddon:16:16|t|cFF1784D1ElvUI|r", nil, 1, function()
        Private.Distributor:ImportProfile(Private:ImportElvUI()["PROFILE"])
        Private.Distributor:ImportProfile(Private:ImportElvUI()["PRIVATE"])
        Private.Distributor:ImportProfile(Private:ImportElvUI()["GLOBAL"])
    end, nil, nil, "relative")
    GUI.args.ProfileManager.args.ImportElvUI.relWidth = 1

    GUI.args.ProfileManager.args.ImportSkironCooldownManager = ACH:Execute("Import |TInterface\\AddOns\\SkironCooldownManager\\Media\\Logo.png:16:16|t|cFF4080FFSkiron|r|cFFFFFFFFCooldownManager|r", nil, 2, function() SCMAPI.ImportProfile("UnhaltedUI", Private:ImportSkironCooldownManager()) end, nil, nil, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("SkironCooldownManager"))
    GUI.args.ProfileManager.args.ImportSkironCooldownManager.relWidth = 1

    GUI.args.ProfileManager.args.ImportLSToasts = ACH:Execute("Import |TInterface\\AddOns\\ls_Toasts\\assets\\logo-32.TGA:16:16|tLS: |cFF1CD3A2Toasts|r", "|cFFCC4040overwrites the default profile|r.", 3, function() Private:ImportLSToasts() if not DB.AddOnSkins.LSToasts == true then DB.AddOnSkins.LSToasts = true end Private:PromptReload() end, nil, true, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
    GUI.args.ProfileManager.args.ImportLSToasts.relWidth = 0.5
    GUI.args.ProfileManager.args.ImportLSToasts.descStyle = "inline"

    GUI.args.ProfileManager.args.ExportLSToasts = ACH:Execute("Export |TInterface\\AddOns\\ls_Toasts\\assets\\logo-32.TGA:16:16|tLS: |cFF1CD3A2Toasts|r", nil, 4, function() Private:ExportLSToasts() end, nil, nil, "relative", nil, nil, (not C_AddOns.IsAddOnLoaded("ls_Toasts") or not Private:IsDeveloper()))
    GUI.args.ProfileManager.args.ExportLSToasts.relWidth = 0.5
    GUI.args.ProfileManager.args.ExportLSToasts.descStyle = "inline"

    GUI.args.ProfileManager.args.ImportPlatynator = ACH:Execute("Import |TInterface\\AddOns\\Platynator\\Assets\\logo.tga:16:16|tPlatynator", nil, 5, function() Platynator.API.ImportString(Private:ImportPlatynator(), "Default") end, nil, nil, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("Platynator"))
    GUI.args.ProfileManager.args.ImportPlatynator.relWidth = 1

    GUI.args.ProfileManager.args.ImportBaganator = ACH:Execute("Import |TInterface\\AddOns\\Baganator\\Assets\\logo.tga:16:16|tBaganator", nil, 6, function() Baganator.API.ImportString(Private:ImportBaganator(), "Default") end, nil, nil, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("Baganator"))
    GUI.args.ProfileManager.args.ImportBaganator.relWidth = 1

    GUI.args.ProfileManager.args.ImportWarpDeplete = ACH:Execute("Import |TInterface\\AddOns\\WarpDeplete\\logo:16:16|tWarpDeplete", "|cFFCC4040overwrites the default profile|r.", 7, function() Private:ImportWarpDeplete() if not DB.AddOnSkins.WarpDeplete == true then DB.AddOnSkins.WarpDeplete = true end Private:PromptReload() end, nil, true, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("WarpDeplete"))
    GUI.args.ProfileManager.args.ImportWarpDeplete.relWidth = 0.5
    GUI.args.ProfileManager.args.ImportWarpDeplete.descStyle = "inline"

    GUI.args.ProfileManager.args.ExportWarpDeplete = ACH:Execute("Export |TInterface\\AddOns\\WarpDeplete\\logo:16:16|tWarpDeplete", nil, 8, function() Private:ExportWarpDeplete() end, nil, nil, "relative", nil, nil, (not C_AddOns.IsAddOnLoaded("WarpDeplete") or not Private:IsDeveloper()))
    GUI.args.ProfileManager.args.ExportWarpDeplete.relWidth = 0.5
    GUI.args.ProfileManager.args.ExportWarpDeplete.descStyle = "inline"

    GUI.args.ProfileManager.args.ImportBigWigs = ACH:Execute("Import |TInterface\\AddOns\\BigWigs\\Media\\Icons\\minimap_raid.tga:16:16|tBigWigs", nil, 9, function() Private:ImportBigWigs() end, nil, nil, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("BigWigs"))
    GUI.args.ProfileManager.args.ImportBigWigs.relWidth = 1

    GUI.args.ProfileManager.args.ImportMinimapStats = ACH:Execute("Import |TInterface\\AddOns\\MinimapStats\\Media\\MinimapStats.png:16:16|t|cFF8080FFMinimap|rStats", nil, 10, function() Private:ImportMinimapStats() end, nil, nil, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("MinimapStats"))
    GUI.args.ProfileManager.args.ImportMinimapStats.relWidth = 1

    --#endregion

    --#region - Quality Of Life

    GUI.args.QualityOfLife = ACH:Group("Quality Of Life", nil, 5)
    GUI.args.QualityOfLife.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\QualityOfLife.tga"
    GUI.args.QualityOfLife.args.Toggles = ACH:Group("Toggles", nil, 1)
    GUI.args.QualityOfLife.args.Toggles.inline = true
    GUI.args.QualityOfLife.args.Toggles.args.AutoDelete = ACH:Toggle("Auto Delete", "Automatically fills the |cFFFFCC00DELETE|r prompt.", 1, nil, nil, "full", function() return DB.QualityOfLife.Toggles.AutoDelete end, function(_, value) DB.QualityOfLife.Toggles.AutoDelete = value end)
    GUI.args.QualityOfLife.args.Toggles.args.AutoDelete.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.AutoSellGreys = ACH:Toggle("Auto Sell Greys", "Automatically sells all grey items when going to a merchant.", 2, nil, nil, "full", function() return DB.QualityOfLife.Toggles.AutoSellGreys end, function(_, value) DB.QualityOfLife.Toggles.AutoSellGreys = value Private:SetupAutoSellGreys() end)
    GUI.args.QualityOfLife.args.Toggles.args.AutoSellGreys.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.AutoSignUp = ACH:Toggle("Auto Sign Up", "Automatically signs you up for dungeons and raids.", 3, nil, nil, "full", function() return DB.QualityOfLife.Toggles.AutoSignUp end, function(_, value) DB.QualityOfLife.Toggles.AutoSignUp = value end)
    GUI.args.QualityOfLife.args.Toggles.args.AutoSignUp.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.PositionRaidWarningFrame = ACH:Toggle("Position Raid Warning Frame", "Positions the raid warning frame to a more convenient location.", 4, nil, nil, "full", function() return DB.QualityOfLife.Toggles.PositionRaidWarningFrame end, function(_, value) DB.QualityOfLife.Toggles.PositionRaidWarningFrame = value Private:PromptReload() end)
    GUI.args.QualityOfLife.args.Toggles.args.PositionRaidWarningFrame.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.RemoveBossBanner = ACH:Toggle("Remove Boss Banner", "Removes the frame that displays all end of dungeon loot for you.", 5, nil, nil, "full", function() return DB.QualityOfLife.Toggles.RemoveBossBanner end, function(_, value) DB.QualityOfLife.Toggles.RemoveBossBanner = value Private:PromptReload() end)
    GUI.args.QualityOfLife.args.Toggles.args.RemoveBossBanner.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.RemoveLossOfControlFrame = ACH:Toggle("Remove Loss Of Control Frame", "Removes the frame that displays loss of control effects for you.", 6, nil, nil, "full", function() return DB.QualityOfLife.Toggles.RemoveLossOfControlFrame end, function(_, value) DB.QualityOfLife.Toggles.RemoveLossOfControlFrame = value Private:PromptReload() end)
    GUI.args.QualityOfLife.args.Toggles.args.RemoveLossOfControlFrame.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.HideTalkingHead = ACH:Toggle("Remove Talking Head", "Automatically removes the talking head for you.", 7, nil, nil, "full", function() return DB.QualityOfLife.Toggles.RemoveTalkingHead end, function(_, value) DB.QualityOfLife.Toggles.RemoveTalkingHead = value end)
    GUI.args.QualityOfLife.args.Toggles.args.HideTalkingHead.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.SkipCinematics = ACH:Toggle("Skip Cinematics", "Automatically skips all cinematics.", 8, nil, nil, "full", function() return DB.QualityOfLife.Toggles.SkipCinematics end, function(_, value) DB.QualityOfLife.Toggles.SkipCinematics = value end)
    GUI.args.QualityOfLife.args.Toggles.args.SkipCinematics.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.MissingPersonalBuffs = ACH:Toggle("Show Missing Personal Buffs", "Shows missing personal buffs when in a dungeon/raid. |cFFFFCC00Food, Flasks, Weapon Oils, etc|r.", 10, nil, nil, "full", function() return DB.QualityOfLife.Toggles.MissingPersonalBuffs end, function(_, value) DB.QualityOfLife.Toggles.MissingPersonalBuffs = value Private:UpdateMissingPersonalBuffs() end)
    GUI.args.QualityOfLife.args.Toggles.args.MissingPersonalBuffs.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.MissingRaidBuffs = ACH:Toggle("Show Missing Raid Buffs", "Shows missing raid buffs when in a dungeon/raid. |cFFFFCC00Personal raid buffs are always shown|r.", 9, nil, nil, "full", function() return DB.QualityOfLife.Toggles.MissingRaidBuffs end, function(_, value) DB.QualityOfLife.Toggles.MissingRaidBuffs = value Private:UpdateMissingRaidBuffs() end)
    GUI.args.QualityOfLife.args.Toggles.args.MissingRaidBuffs.descStyle = "inline"

    GUI.args.QualityOfLife.args.Alerts = ACH:Group("Alerts", nil, 2)
    GUI.args.QualityOfLife.args.Alerts.inline = true

    GUI.args.QualityOfLife.args.Alerts.args.PowerInfusionAlert = ACH:Toggle("|T135939:18:18|t Power Infusion Alert", nil, 1, nil, nil, "relative", function() return DB.QualityOfLife.Alerts.PowerInfusionAlert end, function(_, value) DB.QualityOfLife.Alerts.PowerInfusionAlert = value Private:SetupPowerInfusionAlert() end)
    GUI.args.QualityOfLife.args.Alerts.args.PowerInfusionAlert.descStyle = "inline"
    GUI.args.QualityOfLife.args.Alerts.args.PowerInfusionAlert.relWidth = 0.5

    GUI.args.QualityOfLife.args.Alerts.args.PowerInfusionAlertSound = ACH:SharedMediaSound("Sound", "Power Infusion Alert Sound", 2, "relative", function() return DB.QualityOfLife.Alerts.PowerInfusionAlertSound end, function(_, value) DB.QualityOfLife.Alerts.PowerInfusionAlertSound = value Private:SetupPowerInfusionAlert() end, function() return not DB.QualityOfLife.Alerts.PowerInfusionAlert end)
    GUI.args.QualityOfLife.args.Alerts.args.PowerInfusionAlertSound.relWidth = 0.5

    GUI.args.QualityOfLife.args.Alerts.args.TimeSpiralAlert = ACH:Toggle("|T4622479:18:18|t Time Spiral Alert", nil, 3, nil, nil, "relative", function() return DB.QualityOfLife.Alerts.TimeSpiralAlert end, function(_, value) DB.QualityOfLife.Alerts.TimeSpiralAlert = value Private:SetupTimeSpiralAlert() end)
    GUI.args.QualityOfLife.args.Alerts.args.TimeSpiralAlert.descStyle = "inline"
    GUI.args.QualityOfLife.args.Alerts.args.TimeSpiralAlert.relWidth = 0.5

    GUI.args.QualityOfLife.args.Alerts.args.TimeSpiralAlertSound = ACH:SharedMediaSound("Sound", "Time Spiral Alert Sound", 4, "relative", function() return DB.QualityOfLife.Alerts.TimeSpiralAlertSound end, function(_, value) DB.QualityOfLife.Alerts.TimeSpiralAlertSound = value Private:SetupTimeSpiralAlert() end, function() return not DB.QualityOfLife.Alerts.TimeSpiralAlert end)
    GUI.args.QualityOfLife.args.Alerts.args.TimeSpiralAlertSound.relWidth = 0.5

    GUI.args.QualityOfLife.args.Alerts.args.BloodlustAlert = ACH:Toggle("|T136012:18:18|t Bloodlust Alert", nil, 5, nil, nil, "relative", function() return DB.QualityOfLife.Alerts.BloodlustAlert end, function(_, value) DB.QualityOfLife.Alerts.BloodlustAlert = value Private:SetupBloodlustAlert() end)
    GUI.args.QualityOfLife.args.Alerts.args.BloodlustAlert.descStyle = "inline"
    GUI.args.QualityOfLife.args.Alerts.args.BloodlustAlert.relWidth = 0.5

    GUI.args.QualityOfLife.args.Alerts.args.BloodlustAlertSound = ACH:SharedMediaSound("Sound", "Bloodlust Alert Sound", 6, "relative", function() return DB.QualityOfLife.Alerts.BloodlustAlertSound end, function(_, value) DB.QualityOfLife.Alerts.BloodlustAlertSound = value Private:SetupBloodlustAlert() end, function() return not DB.QualityOfLife.Alerts.BloodlustAlert end)
    GUI.args.QualityOfLife.args.Alerts.args.BloodlustAlertSound.relWidth = 0.5

    --#endregion

    --#region - Mouse Cursor

    GUI.args.MouseCursor = ACH:Group("Mouse Cursor", nil, 5)
    GUI.args.MouseCursor.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\MouseCursor.tga"

    GUI.args.MouseCursor.args.Toggles = ACH:Group("Toggles", nil, 1)
    GUI.args.MouseCursor.args.Toggles.inline = true

    GUI.args.MouseCursor.args.Toggles.args.Enabled = ACH:Toggle("Enable Mouse Cursor", "Shows an additional texture for the mouse cursor.", 1, nil, nil, "full", function() return DB.MouseCursor.Enabled end, function(_, value) DB.MouseCursor.Enabled = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Toggles.args.Enabled.descStyle = "inline"

    GUI.args.MouseCursor.args.Toggles.args.ShowInCombatOnly = ACH:Toggle("Show In Combat Only", "Shows the mouse cursor indicator in combat.", 2, nil, nil, "full", function() return DB.MouseCursor.ShowInCombatOnly end, function(_, value) DB.MouseCursor.ShowInCombatOnly = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Toggles.args.ShowInCombatOnly.descStyle = "inline"

    GUI.args.MouseCursor.args.Layout = ACH:Group("Layout", nil, 3)
    GUI.args.MouseCursor.args.Layout.inline = true
    GUI.args.MouseCursor.args.Layout.disabled = function() return not DB.MouseCursor.Enabled or DB.MouseCursor.Texture == "CURSOR_01" or DB.MouseCursor.Texture == "CURSOR_02" end

    GUI.args.MouseCursor.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AP, nil, "relative", function() return DB.MouseCursor.Layout[1] end, function(_, value) DB.MouseCursor.Layout[1] = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Layout.args.AnchorFrom.descStyle = "inline"
    GUI.args.MouseCursor.args.Layout.args.AnchorFrom.relWidth = 0.5

    GUI.args.MouseCursor.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AP, nil, "relative", function() return DB.MouseCursor.Layout[2] end, function(_, value) DB.MouseCursor.Layout[2] = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Layout.args.AnchorTo.descStyle = "inline"
    GUI.args.MouseCursor.args.Layout.args.AnchorTo.relWidth = 0.5

    GUI.args.MouseCursor.args.Layout.args.OffsetX = ACH:Range("X Offset", nil, 3, { min = -100, max = 100, step = 1 }, "relative", function() return DB.MouseCursor.Layout[3] end, function(_, value) DB.MouseCursor.Layout[3] = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Layout.args.OffsetX.descStyle = "inline"
    GUI.args.MouseCursor.args.Layout.args.OffsetX.relWidth = 0.33

    GUI.args.MouseCursor.args.Layout.args.OffsetY = ACH:Range("Y Offset", nil, 4, { min = -100, max = 100, step = 1 }, "relative", function() return DB.MouseCursor.Layout[4] end, function(_, value) DB.MouseCursor.Layout[4] = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Layout.args.OffsetY.descStyle = "inline"
    GUI.args.MouseCursor.args.Layout.args.OffsetY.relWidth = 0.33

    GUI.args.MouseCursor.args.Layout.args.CursorSize = ACH:Range("Cursor Size", nil, 5, { min = 1, max = 100, step = 1 }, "relative", function() return DB.MouseCursor.Layout[5] end, function(_, value) DB.MouseCursor.Layout[5] = value DB.MouseCursor.Layout[6] = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Layout.args.CursorSize.descStyle = "inline"
    GUI.args.MouseCursor.args.Layout.args.CursorSize.relWidth = 0.33

    GUI.args.MouseCursor.args.Appearance = ACH:Group("Appearance", nil, 4)
    GUI.args.MouseCursor.args.Appearance.inline = true
    GUI.args.MouseCursor.args.Appearance.disabled = function() return not DB.MouseCursor.Enabled end

    GUI.args.MouseCursor.args.Appearance.args.Texture = ACH:Select("Texture", "Select the texture for the mouse cursor.", 1, Private.MouseCursors.Preview, nil, "relative", function() return DB.MouseCursor.Texture end, function(_, value) DB.MouseCursor.Texture = value Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Appearance.args.Texture.descStyle = "inline"
    GUI.args.MouseCursor.args.Appearance.args.Texture.relWidth = 0.5
    GUI.args.MouseCursor.args.Appearance.args.Texture.disabled = function() return not DB.MouseCursor.Enabled end

    GUI.args.MouseCursor.args.Appearance.args.Colour = ACH:Color("Colour", "Select the colour for the mouse cursor.", 2, true, "relative", function() return unpack(DB.MouseCursor.Colour) end, function(_, r, g, b, a) DB.MouseCursor.Colour = { r, g, b, a } Private:UpdateMouseCursor() end)
    GUI.args.MouseCursor.args.Appearance.args.Colour.descStyle = "inline"
    GUI.args.MouseCursor.args.Appearance.args.Colour.relWidth = 0.5
    GUI.args.MouseCursor.args.Appearance.args.Colour.disabled = function() return not DB.MouseCursor.Enabled or DB.MouseCursor.Texture == "CURSOR_01" or DB.MouseCursor.Texture == "CURSOR_02" end

    --#endregion

    --#region - Vendor Helper

    GUI.args.VendorHelper = ACH:Group("Vendor Helper", nil, 6)
    GUI.args.VendorHelper.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\VendorHelper.tga"

    GUI.args.VendorHelper.args.Enabled = ACH:Toggle("Enable Vendor Helper", "Automatically sells unwanted items when visiting a vendor.", 1, nil, nil, "full", function() return DB.VendorHelper.AutoVendor end, function(_, value) DB.VendorHelper.AutoVendor = value Private:SetupVendorHelper() end)
    GUI.args.VendorHelper.args.Enabled.descStyle = "inline"

    GUI.args.VendorHelper.args.MinimumQuality = ACH:Select("Minimum Quality", "Sets the minimum quality of items to sell automatically.", 2, Private.ItemQualities, nil, "relative", function() return DB.VendorHelper.MinimumQuality end, function(_, value) DB.VendorHelper.MinimumQuality = value end)
    GUI.args.VendorHelper.args.MinimumQuality.descStyle = "inline"
    GUI.args.VendorHelper.args.MinimumQuality.relWidth = 0.5
    GUI.args.VendorHelper.args.MinimumQuality.disabled = function() return not DB.VendorHelper.AutoVendor end

    GUI.args.VendorHelper.args.MinimumItemLevel = ACH:Range("Minimum Item Level", "Sets the minimum item level of items to sell automatically.", 3, { min = 0, max = 500, step = 1 }, "relative", function() return DB.VendorHelper.MinimumItemLevel end, function(_, value) DB.VendorHelper.MinimumItemLevel = value end)
    GUI.args.VendorHelper.args.MinimumItemLevel.descStyle = "inline"
    GUI.args.VendorHelper.args.MinimumItemLevel.relWidth = 0.5
    GUI.args.VendorHelper.args.MinimumItemLevel.disabled = function() return not DB.VendorHelper.AutoVendor end

    --#endregion

    if Private.E then Private.E.Options.args[Private.AddOnName] = GUI end
end
