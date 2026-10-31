local Private = select(2, ...)
local ACH = Private.ACH

--[[
    ACH:Color(name, desc, order, alpha, width, get, set, disabled, hidden)
    ACH:Description(name, order, fontSize, image, imageCoords, imageWidth, imageHeight, width, hidden)
    ACH:Execute(name, desc, order, func, image, confirm, width, get, set, disabled, hidden)
    ACH:FontFlags(name, desc, order, width, get, set, disabled, hidden)
    ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden, func)
    ACH:Header(name, order, get, set, hidden)
    ACH:Input(name, desc, order, multiline, width, get, set, disabled, hidden, validate)
    ACH:MultiSelect(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
    ACH:Range(name, desc, order, values, width, get, set, disabled, hidden)
    ACH:Select(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
    ACH:SharedMediaBackground(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaBorder(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaFont(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaSound(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaStatusbar(name, desc, order, width, get, set, disabled, hidden)
    ACH:Spacer(order, width, hidden)
    ACH:Toggle(name, desc, order, tristate, confirm, width, get, set, disabled, hidden)
]]

function Private:SetupGUI()
    Private.GUI = ACH:Group(format("|cFF6080FF%s|r", "Unhalted"), nil, 999, "tree")

    Private.GUI.args.AddOnSkins = ACH:Group("AddOn Skins", nil, 1, "tab")
    Private.GUI.args.AddOnSkins.args.BugSack = ACH:Group("BugSack", nil, 1, "tab", nil, nil, nil, function() return not C_AddOns.IsAddOnLoaded("BugSack") end)

    Private.GUI.args.AddOnSkins.args.BugSack.args.Enable = ACH:Toggle("Enable", "Skins the minimap icon to much the UI, and provides layout options.", 1, nil, nil, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Enable end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Enable = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.Enable.descStyle = "inline"
    Private.GUI.args.AddOnSkins.args.BugSack.args.Enable.relWidth = 1

    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.inline = true

    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[1] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[1] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[2] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[2] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[3] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[3] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[4] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[4] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Size[1] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Size[1] = value Private.DB.global.AddOnSkins.BugSack.Size[2] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts = ACH:Group("Alerts", nil, 2, "tab")

    Private.GUI.args.Alerts.args.Combat = ACH:Group("Combat", nil, 1, "tab")

    Private.GUI.args.Alerts.args.Combat.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.Combat.Enable end, function(_, value) Private.DB.global.Alerts.Combat.Enable = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.Alerts.args.Combat.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.Combat.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.Combat.Layout[1] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[1] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.Combat.Layout[2] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[2] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.Combat.Layout[3] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[3] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.Combat.Layout[4] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[4] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.HoldTime = ACH:Range("Hold Time", "The time that the text will remain on the screen before disappearing.", 5, {min = 0, max = 10, softMin = 0, softMax = 5, step = 0.5}, "relative", function() return Private.DB.global.Alerts.Combat.HoldTime end, function(_, value) Private.DB.global.Alerts.Combat.HoldTime = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.HoldTime.relWidth = 0.33

    Private.GUI.args.Alerts.args.Combat.args.FontGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.inline = true

    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Alerts.Combat.Text.FontSize end, function(_, value) Private.DB.global.Alerts.Combat.Text.FontSize = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.FontSize.relWidth = 1

    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatText = ACH:Input("Entering Combat: Text", nil, 6, nil, "relative", function() return Private.DB.global.Alerts.Combat.Text.Enter.Text end, function(_, value) Private.DB.global.Alerts.Combat.Text.Enter.Text = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatText.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatColour = ACH:Color("Entering Combat: Colour", nil, 7, false, "relative", function() return unpack(Private.DB.global.Alerts.Combat.Text.Enter.Colour) end, function(_, r, g, b) Private.DB.global.Alerts.Combat.Text.Enter.Colour = {r, g, b} Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatColour.relWidth = 0.5

    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatText = ACH:Input("Exiting Combat: Text", nil, 8, nil, "relative", function() return Private.DB.global.Alerts.Combat.Text.Exit.Text end, function(_, value) Private.DB.global.Alerts.Combat.Text.Exit.Text = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatText.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatColour = ACH:Color("Exiting Combat: Colour", nil, 9, false, "relative", function() return unpack(Private.DB.global.Alerts.Combat.Text.Exit.Colour) end, function(_, r, g, b) Private.DB.global.Alerts.Combat.Text.Exit.Colour = {r, g, b} Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatColour.relWidth = 0.5

    Private.GUI.args.Alerts.args.PowerInfusion = ACH:Group("Power Infusion", nil, 2, "tab")

    Private.GUI.args.Alerts.args.PowerInfusion.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Enable end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Enable = value Private:UpdatePowerInfusionAlert() end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.PowerInfusion.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[1] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[1] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[2] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[2] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[3] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[3] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[4] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[4] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 0, max = 64, softMin = 8, softMax = 48, step = 1}, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Size[1] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Size[1] = value Private.DB.global.Alerts.PowerInfusion.Size[2] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.inline = true

    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.Sound = ACH:SharedMediaSound("Sound", nil, 1, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Sound end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Sound = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.Sound.relWidth = 0.5
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.SoundChannel = ACH:Select("Sound Channel", nil, 2, {["Master"] = "Master", ["SFX"] = "SFX", ["Music"] = "Music", ["Ambience"] = "Ambience"}, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.SoundChannel end, function(_, value) Private.DB.global.Alerts.PowerInfusion.SoundChannel = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.SoundChannel.relWidth = 0.5

    Private.GUI.args.Alerts.args.TimeSpiral = ACH:Group("Time Spiral", nil, 3, "tab")

    Private.GUI.args.Alerts.args.TimeSpiral.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Enable end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Enable = value Private:UpdateTimeSpiralAlert() end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.TimeSpiral.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[1] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[1] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[2] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[2] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[3] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[3] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[4] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[4] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 0, max = 64, softMin = 8, softMax = 48, step = 1}, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Size[1] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Size[1] = value Private.DB.global.Alerts.TimeSpiral.Size[2] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.inline = true

    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.Sound = ACH:SharedMediaSound("Sound", nil, 1, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Sound end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Sound = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.Sound.relWidth = 0.5
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.SoundChannel = ACH:Select("Sound Channel", nil, 2, {["Master"] = "Master", ["SFX"] = "SFX", ["Music"] = "Music", ["Ambience"] = "Ambience"}, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.SoundChannel end, function(_, value) Private.DB.global.Alerts.TimeSpiral.SoundChannel = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.SoundChannel.relWidth = 0.5

    Private.GUI.args.Blizzard = ACH:Group("Blizzard", nil, 3, "tab")
    Private.GUI.args.Blizzard.args.Miscellaneous = ACH:Group("Miscellaneous", nil, 0)
    Private.GUI.args.Blizzard.args.Miscellaneous.inline = true
    Private.GUI.args.Blizzard.args.Miscellaneous.args.CleanObjectiveTrackerBanner = ACH:Toggle("Clean-up Point of Interest Banner", "This will position & tidy up the banner that appears when entering a |cFFFFCC00point of interest|r.", 0, nil, nil, "relative", function() return Private.DB.global.Blizzard.CleanObjectiveTrackerBanner end, function(_, value) Private.DB.global.Blizzard.CleanObjectiveTrackerBanner = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.Blizzard.args.Miscellaneous.args.CleanObjectiveTrackerBanner.descStyle = "inline"
    Private.GUI.args.Blizzard.args.Miscellaneous.args.CleanObjectiveTrackerBanner.relWidth = 1

    Private.GUI.args.Blizzard.args.UIErrorsFrame = ACH:Group("UIErrorsFrame", nil, 1)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Enable end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Enable = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Enable.relWidth = 0.5

    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Hide = ACH:Toggle("Hide", nil, 2, nil, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Hide end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Hide = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Hide.relWidth = 0.5

    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup = ACH:Group("Layout", nil, 2)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.inline = true
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[1] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[1] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[2] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[2] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[3] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[3] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.XOffset.relWidth = 0.5
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[4] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[4] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.YOffset.relWidth = 0.5

    Private.GUI.args.DamageMeter = ACH:Group("Damage Meter", nil, 4, "tab")

    Private.GUI.args.ElvUI = ACH:Group("ElvUI", nil, 5, "tab")
    Private.GUI.args.ElvUI.args.EnhancedAnchors = ACH:Group("Enhanced Anchors", nil, 1)
    Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars = ACH:Group("Action Bars", nil, 1, "tab")

    for i = 1, 6 do
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i] = ACH:Group("Bar "..i, nil, i, "tab")
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "full", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable = value Private:UpdateMover(value, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end)

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup = ACH:Group("Layout", nil, 2)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.inline = true
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[1] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[1] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorFrom.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorParent = ACH:Input("Anchor Parent", nil, 3, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[2] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[2] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorParent.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 4, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[3] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[3] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorTo.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 5, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[4] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[4] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.XOffset.relWidth = 0.5
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 6, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[5] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[5] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.YOffset.relWidth = 0.5

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.SetAsSkyridingVehicleBar = ACH:Execute("Set As Skyriding / Vehicle Bar", "This will set |cFFFFCC00paging|r & |cFFFFCC00visibility|r for this action bar.", 3, function() Private:SetVisibilityConditions("bar" .. i) end, nil, nil, "full", nil, nil, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
    end

    Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames = ACH:Group("Unit Frames", nil, 2, "tab")

    local UnitFrames = {
        [1] = "Player",
        [2] = "Target",
        [3] = "TargetCastbar",
        [4] = "Pet",
        [5] = "Focus"
    }

    local PrettifyUnitFrames = {
        ["Player"] = "Player",
        ["Target"] = "Target",
        ["TargetCastbar"] = "Target Cast Bar",
        ["Pet"] = "Pet",
        ["Focus"] = "Focus"
    }

    for i, unitFrame in ipairs(UnitFrames) do
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"] = ACH:Group(PrettifyUnitFrames[unitFrame], nil, i, "tab")
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "full", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable = value Private:UpdateMover(value, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end)

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup = ACH:Group("Layout", nil, 2)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.inline = true

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[1] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[1] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorFrom.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorParent = ACH:Input("Anchor Parent", nil, 3, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[2] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[2] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorParent.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 4, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[3] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[3] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorTo.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 5, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[4] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[4] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.XOffset.relWidth = 0.5
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 6, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[5] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[5] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.YOffset.relWidth = 0.5
    end

    Private.GUI.args.ElvUI.args.Miscellaneous = ACH:Group("Miscellaneous", nil, 2)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.InterruptOnCooldown = ACH:Toggle( "Interrupt on Cooldown", "Colours the castbar |cFF808080grey|r when your |cFFFFCC00interrupt|r is on cooldown.", 1, nil, nil, "full", function() return Private.DB.global.ElvUI.InterruptOnCooldown end, function(_, value) Private.DB.global.ElvUI.InterruptOnCooldown = value Private.E:StaticPopup_Show("CONFIG_RL") end )
    Private.GUI.args.ElvUI.args.Miscellaneous.args.InterruptOnCooldown.descStyle = "inline"
    Private.GUI.args.ElvUI.args.Miscellaneous.args.LootRollFix = ACH:Toggle( "Fix Loot Roll Alpha", "Correctly applies the alpha to the |cFFFFCC00loot roll|r windows.", 1, nil, nil, "full", function() return Private.DB.global.ElvUI.LootRollFix end, function(_, value) Private.DB.global.ElvUI.LootRollFix = value Private.E:StaticPopup_Show("CONFIG_RL") end )
    Private.GUI.args.ElvUI.args.Miscellaneous.args.LootRollFix.descStyle = "inline"

    Private.GUI.args.MinimapStats = ACH:Group("Minimap Stats", nil, 6, "tab")
    Private.GUI.args.MinimapStats.args.Time = ACH:Group("Time", nil, 1)

    Private.GUI.args.MinimapStats.args.Time.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Enable end, function(_, value) Private.DB.global.MinimapStats.Time.Enable = value Private:UpdateTime() end)
    Private.GUI.args.MinimapStats.args.Time.args.Enable.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Time.args.Format = ACH:Select("Format", nil, 2, {["24H"] = "24H", ["12H"] = "12H"}, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Format end, function(_, value) Private.DB.global.MinimapStats.Time.Format = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Format.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Time.args.UpdateInterval = ACH:Range("Update Interval", nil, 3, {min = 1, max = 60, softMin = 1, softMax = 30, step = 1}, "relative", function() return Private.DB.global.MinimapStats.Time.UpdateInterval end, function(_, value) Private.DB.global.MinimapStats.Time.UpdateInterval = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.UpdateInterval.relWidth = 0.33

    Private.GUI.args.MinimapStats.args.Time.args.Layout = ACH:Group("Layout", nil, 4)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[1] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[2] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[3] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[4] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.Time.args.Font = ACH:Group("Font", nil, 5)
    Private.GUI.args.MinimapStats.args.Time.args.Font.inline = true
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.Colour = ACH:Color("Font Colour", nil, 1, false, "relative", function() return unpack(Private.DB.global.MinimapStats.Time.Colour) end, function(_, r, g, b) Private.DB.global.MinimapStats.Time.Colour = {r, g, b} Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.Colour.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.FontSize = ACH:Range("Font Size", nil, 2, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.Time.FontSize end, function(_, value) Private.DB.global.MinimapStats.Time.FontSize = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.FontSize.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.SystemStats = ACH:Group("SystemStats", nil, 2)

    Private.GUI.args.MinimapStats.args.SystemStats.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Enable end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Enable = value Private:UpdateSystemStats() end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Enable.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Format = ACH:Select("Format", nil, 2, { ["FPS_MS"] = "FPS & MS", ["MS"] = "MS", ["FPS"] = "FPS" }, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Format end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Format = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Format.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Seperator = ACH:Select("Seperator", nil, 2, {["•"] = "•", ["||"] = "|", ["-"] = "-"}, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Seperator end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Seperator = value Private:UpdateSystemStats() end, function() return (not Private.DB.global.MinimapStats.SystemStats.Enable) or not (Private.DB.global.MinimapStats.SystemStats.Format == "FPS_MS") end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Seperator.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.UpdateInterval = ACH:Range("Update Interval", nil, 3, {min = 1, max = 60, softMin = 1, softMax = 30, step = 1}, "relative", function() return Private.DB.global.MinimapStats.SystemStats.UpdateInterval end, function(_, value) Private.DB.global.MinimapStats.SystemStats.UpdateInterval = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.UpdateInterval.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout = ACH:Group("Layout", nil, 4)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[1] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[2] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[3] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[4] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.SystemStats.args.Font = ACH:Group("Font", nil, 5)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.inline = true
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.Colour = ACH:Color("Font Colour", nil, 1, false, "relative", function() return unpack(Private.DB.global.MinimapStats.SystemStats.Colour) end, function(_, r, g, b) Private.DB.global.MinimapStats.SystemStats.Colour = {r, g, b} Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.Colour.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.FontSize = ACH:Range("Font Size", nil, 2, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.SystemStats.FontSize end, function(_, value) Private.DB.global.MinimapStats.SystemStats.FontSize = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.FontSize.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.Location = ACH:Group("Location", nil, 3)

    Private.GUI.args.MinimapStats.args.Location.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.Location.Enable end, function(_, value) Private.DB.global.MinimapStats.Location.Enable = value Private:UpdateLocation() end)
    Private.GUI.args.MinimapStats.args.Location.args.Enable.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Location.args.ShowSubZone = ACH:Toggle("Show Sub Zone", nil, 2, nil, nil, "relative", function() return Private.DB.global.MinimapStats.Location.ShowSubZone end, function(_, value) Private.DB.global.MinimapStats.Location.ShowSubZone = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.ShowSubZone.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.Location.args.Layout = ACH:Group("Layout", nil, 3)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[1] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[2] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[3] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.XOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[4] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.YOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.Location.FontSize end, function(_, value) Private.DB.global.MinimapStats.Location.FontSize = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.FontSize.relWidth = 0.33

    Private.GUI.args.MinimapStats.args.InstanceDifficulty = ACH:Group("Instance Difficulty", nil, 4)

    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Enable end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Enable = value Private:UpdateInstanceDifficulty() end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Enable.relWidth = 1

    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout = ACH:Group("Layout", nil, 2)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[1] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[2] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[3] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.XOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[4] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.YOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.FontSize end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.FontSize = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.FontSize.relWidth = 0.33

    Private.GUI.args.Toggles = ACH:Group("Toggles", nil, 7, "tab")

    local Toggles = {
        [1] = { name = "Auto Delete", desc = "Auto populates |cFFFFCC00delete|r where required.", value = Private.DB.global.Toggles.AutoDelete, requiresReload = false },
        [2] = { name = "Auto Sign Up", desc = "Automatically accept |cFFFFCC00role|r popups.", value = Private.DB.global.Toggles.AutoSignUp, requiresReload = false },
        [3] = { name = "Hide Boss Banner", desc = "Hides the popup that appears when a boss is |cFFFFCC00defeated|r.", value = Private.DB.global.Toggles.HideBossBanner, requiresReload = true },
        [4] = { name = "Hide Loss of Control", desc = "Hides the popup that shows when you are |cFFFFCC00crowd-controlled|r.", value = Private.DB.global.Toggles.HideLossOfControl, requiresReload = true },
        [5] = { name = "Hide Talking Head", desc = nil, value = Private.DB.global.Toggles.HideTalkingHead, requiresReload = true },
        [6] = { name = "Skip Cinematics", desc = "Automatically skip |cFFFFCC00seen|r & |cFFFFCC00unseen|r cinematics.", value = Private.DB.global.Toggles.SkipCinematics, requiresReload = true },
    }

    for i, toggle in ipairs(Toggles) do
        Private.GUI.args.Toggles.args[toggle.name] = ACH:Toggle(toggle.name, toggle.desc, i, nil, nil, "full", function() return toggle.value end, function(_, value) toggle.value = value if toggle.requiresReload then Private.E:StaticPopup_Show("CONFIG_RL") end end)
        Private.GUI.args.Toggles.args[toggle.name].descStyle = "inline"
    end

    if Private.E then Private.E.Options.args.ElvUIAnchors = Private.GUI end
end