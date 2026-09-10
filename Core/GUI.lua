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

    GUI = ACH:Group(format("%s", Private.AddOnName), nil, 20, "tree")
    GUI.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\Dashboard.tga"

    GUI.args.AddOnSKins = ACH:Group("AddOn Skins", nil, 1)
    GUI.args.AddOnSKins.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\Palette.tga"
    GUI.args.AddOnSKins.args.LSToasts = ACH:Toggle("LS: |cFF1CD3A2Toasts|r", "Add a custom skin for LS: |cFF1CD3A2Toasts|r.", 1, nil, nil, "full", function() return DB.AddOnSkins.LSToasts end, function(_, value) DB.AddOnSkins.LSToasts = value Private:PromptReload() end, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
    GUI.args.AddOnSKins.args.LSToasts.descStyle = "inline"

    GUI.args.CombatAlert = ACH:Group("Combat Alert", nil, 2)
    GUI.args.CombatAlert.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\Swords.tga"
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

    GUI.args.CombatTimer = ACH:Group("Combat Timer", nil, 2)
    GUI.args.CombatTimer.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\Timer.tga"
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

    GUI.args.CVars = ACH:Group("CVars", nil, 3)
    GUI.args.CVars.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\Tune.tga"
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

    GUI.args.ProfileManager = ACH:Group("Profile Manager", nil, 4)
    GUI.args.ProfileManager.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\ManageAccounts.tga"

    GUI.args.ProfileManager.args.ImportElvUI = ACH:Execute("Import |TInterface\\AddOns\\ElvUI\\Game\\Shared\\Media\\Textures\\LogoAddon:16:16|t|cFF1784D1ElvUI|r", nil, 1, function()
        Private.Distributor:ImportProfile(Private:ImportElvUI()["PROFILE"])
        Private.Distributor:ImportProfile(Private:ImportElvUI()["PRIVATE"])
        Private.Distributor:ImportProfile(Private:ImportElvUI()["GLOBAL"])
    end, nil, nil, "relative")
    GUI.args.ProfileManager.args.ImportElvUI.relWidth = 0.33

    GUI.args.ProfileManager.args.ImportSkironCooldownManager = ACH:Execute("Import |TInterface\\AddOns\\SkironCooldownManager\\Media\\Logo.png:16:16|t|cFF4080FFSkiron|r|cFFFFFFFFCooldownManager|r", nil, 2, function() SCMAPI.ImportProfile("UnhaltedUI", Private:ImportSkironCooldownManager()) end, nil, nil, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("SkironCooldownManager"))
    GUI.args.ProfileManager.args.ImportSkironCooldownManager.relWidth = 0.33

    GUI.args.ProfileManager.args.ImportLSToasts = ACH:Execute("Import |TInterface\\AddOns\\ls_Toasts\\assets\\logo-32.TGA:16:16|tLS: |cFF1CD3A2Toasts|r", "|cFFCC4040overwrites the default profile|r.", 3, function() Private:ImportLSToasts() if not DB.AddOnSkins.LSToasts == true then DB.AddOnSkins.LSToasts = true end Private:PromptReload() end, nil, true, "relative", nil, nil, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
    GUI.args.ProfileManager.args.ImportLSToasts.relWidth = 0.33
    GUI.args.ProfileManager.args.ImportLSToasts.descStyle = "inline"

    GUI.args.QualityOfLife = ACH:Group("Quality Of Life", nil, 5)
    GUI.args.QualityOfLife.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\AutoAwesome.tga"
    GUI.args.QualityOfLife.args.Toggles = ACH:Group("Toggles", nil, 1)
    GUI.args.QualityOfLife.args.Toggles.inline = true
    GUI.args.QualityOfLife.args.Toggles.args.HideTalkingHead = ACH:Toggle("Remove Talking Head", "Automatically removes the talking head for you.", 1, nil, nil, "full", function() return DB.QualityOfLife.Toggles.RemoveTalkingHead end, function(_, value) DB.QualityOfLife.Toggles.RemoveTalkingHead = value end)
    GUI.args.QualityOfLife.args.Toggles.args.HideTalkingHead.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.SkipCinematics = ACH:Toggle("Skip Cinematics", "Automatically skips all cinematics.", 1, nil, nil, "full", function() return DB.QualityOfLife.Toggles.SkipCinematics end, function(_, value) DB.QualityOfLife.Toggles.SkipCinematics = value end)
    GUI.args.QualityOfLife.args.Toggles.args.SkipCinematics.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.AutoSellGreys = ACH:Toggle("Auto Sell Greys", "Automatically sells all grey items when going to a merchant.", 3, nil, nil, "full", function() return DB.QualityOfLife.Toggles.AutoSellGreys end, function(_, value) DB.QualityOfLife.Toggles.AutoSellGreys = value end)
    GUI.args.QualityOfLife.args.Toggles.args.AutoSellGreys.descStyle = "inline"
    GUI.args.QualityOfLife.args.Toggles.args.AutoDelete = ACH:Toggle("Auto Delete", "Automatically fills the |cFFFFCC00DELETE|r prompt.", 4, nil, nil, "full", function() return DB.QualityOfLife.Toggles.AutoDelete end, function(_, value) DB.QualityOfLife.Toggles.AutoDelete = value end)
    GUI.args.QualityOfLife.args.Toggles.args.AutoDelete.descStyle = "inline"

    GUI.args.VendorHelper = ACH:Group("Vendor Helper", nil, 6)
    GUI.args.VendorHelper.icon = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Icons\\Storefront.tga"

    if Private.E then Private.E.Options.args[Private.AddOnName] = GUI end
end
