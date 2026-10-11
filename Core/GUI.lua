local Private = select(2, ...)
local ACH = Private.ElvUI.Libs.ACH

function Private:CreateGUI()
    Private.ElvUI:ToggleOptions("ElvUI_Unhalted")
end

function Private:UpdateGUIPreviews(Group)
    if Private.GUIGroup == Group then return end
    Private.GUIGroup = Group

    if Private.PreviewCombatAlertActive or Group == "CombatAlert" then
        Private.PreviewCombatAlertActive = Group == "CombatAlert"
        Private:PreviewCombatAlert()
    end
    if Group ~= "DamageMeter" and Private.DamageMeterTestMode then Private:SetDamageMeterTestMode(false) end
    if Private.PreviewDungeonCastsActive or Group == "DungeonCasts" then
        Private.PreviewDungeonCastsActive = Group == "DungeonCasts"
        Private:TestDungeonCasts()
    end
    if Private.PreviewAlertsActive or Group == "QualityOfLife" then
        Private.PreviewAlertsActive = Group == "QualityOfLife"
        Private:SetupPreviewAlerts()
    end
end

function Private:SetupGUI()
    local GUI = Private.GUI
    local DB = Private.DB.global
    local Options = ACH:Group(Private.AddOnName, "V" .. Private.AddOnVersion, 20, "tab")
    local Args = Options.args

    local AddOnSkins = ACH:Group("AddOn Skins", nil, 1, "tree")
    for Order, Skin in ipairs({
        {Key = "AddOnProfiler", Name = "AddOn Profiler", AddOn = "!!AddonProfiler", Update = "UpdateAddOnProfilerSkin"},
        {Key = "BigWigs", Name = "BigWigs", AddOn = "BigWigs", Update = "UpdateBigWigsSkin"},
        {Key = "BugSack", Name = "BugSack", AddOn = "BugSack", Update = "UpdateBugSackSkin"},
        {Key = "SimulationCraft", Name = "SimulationCraft", AddOn = "SimulationCraft", Update = "UpdateSimulationCraftSkin"},
        {Key = "SkironCooldownManager", Name = "Skiron Cooldown Manager", AddOn = "SkironCooldownManager", Update = "UpdateSkironCooldownManagerSkin"},
    }) do
        local SkinDB = DB.AddOnSkins[Skin.Key]
        local Group = ACH:Group(Skin.Name, nil, Order)
        Group.disabled = not C_AddOns.IsAddOnLoaded(Skin.AddOn)
        local Description = Skin.Key == "BigWigs" and "Skins & Positions the BigWigs Minimap Button, along with providing consistent skinning for bars/windows." or "Skins & Positioning the " .. Skin.Name .. " Minimap Button"
        Group.args.Enable = GUI:Toggle("Enable", Description, 1, 1, SkinDB, "Enable", function() Private:PromptReload() end)
        Group.args.LayoutOptions = GUI:LayoutOptions(SkinDB, function() Private[Skin.Update](Private) end)
        GUI:DisableOptions(Group, SkinDB)
        AddOnSkins.args[Skin.Key] = Group
    end
    local Miscellaneous = ACH:Group("Miscellaneous", nil, 6)
    Miscellaneous.args.LSToasts = GUI:Toggle("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\LSToasts.TGA:16:16|t LS: |cFF1CD3A2Toasts|r", "Adds a skin to LS: Toasts to match the UI aesthetic.", 1, 1, DB.AddOnSkins.Miscellaneous, "LSToasts", function() Private:PromptReload() end)
    AddOnSkins.args.Miscellaneous = Miscellaneous
    Args.AddOnSkins = AddOnSkins

    local Blizzard = ACH:Group("Blizzard", nil, 2, "tree")
    for _, Setting in ipairs({
        {Key = "ActionStatus", Name = "Action Status", Order = 1, Update = "UpdateActionStatusFrame"},
        {Key = "UIErrorsFrame", Name = "UI Errors", Order = 3, Update = "UpdateUIErrorsFrame"},
        {Key = "ZoneText", Name = "Zone Text", Order = 4, Update = "UpdateZoneText"},
        {Key = "SubZoneText", Name = "Sub Zone Text", Order = 5, Update = "UpdateZoneText"},
    }) do
        local SettingDB = DB.Blizzard[Setting.Key]
        local Update = function() Private[Setting.Update](Private) end
        local Group = ACH:Group(Setting.Name, nil, Setting.Order)
        Group.args.Enable = GUI:Toggle("Enable", nil, 1, 1, SettingDB, "Enable", Update)
        Group.args.LayoutOptions = GUI:LayoutOptions(SettingDB, Update)
        Group.args.FontOptions = GUI:FontOptions(SettingDB, Update)
        GUI:DisableOptions(Group, SettingDB)
        Blizzard.args[Setting.Key] = Group
    end
    local PreyDB = DB.Blizzard.BetterPrey
    local UpdatePrey = function() Private:UpdateBetterPrey() end
    local BetterPrey = ACH:Group("Better Prey", nil, 2)
    BetterPrey.args.Enable = GUI:Toggle("Enable", "Displays Prey progression in a more convenient way.", 1, 0.5, PreyDB, "Enable", UpdatePrey)
    BetterPrey.args.ColourByStage = GUI:Toggle("Colour by Stage", nil, 2, 0.5, PreyDB, "ColourByStage", UpdatePrey)
    BetterPrey.args.LayoutOptions = GUI:LayoutOptions(PreyDB, UpdatePrey, function() return 12, 12 end)
    local PreyText = GUI:InlineGroup("Text Options", 11)
    PreyText.args.Enable = GUI:Toggle("Enable", nil, 1, 1, PreyDB.Text, "Enable", UpdatePrey)
    PreyText.args.FontOptions = GUI:FontOptions(PreyDB.Text, UpdatePrey)
    GUI:DisableOptions(PreyText, PreyDB.Text, PreyDB)
    BetterPrey.args.TextOptions = PreyText
    GUI:DisableOptions(BetterPrey, PreyDB)
    Blizzard.args.BetterPrey = BetterPrey
    Args.Blizzard = Blizzard

    local EnhancementsDB = DB.ElvUIEnhancements
    local Enhancements = ACH:Group("ElvUI Enhancements", nil, 3)
    Enhancements.args.ForceAlphaOnLootRoll = GUI:Toggle("Loot Roll: Fix Backdrop", "Force the loot roll backdrop to be fully opaque.", 1, 1, EnhancementsDB, "ForceAlphaOnLootRoll", function() Private:PromptReload() end)
    Enhancements.args.CastbarInterruptCooldown = GUI:Toggle("Castbar: Interrupt On Cooldown", "Colours interruptible enemy unit frame and nameplate castbars grey while your interrupt is on cooldown.", 2, 1, EnhancementsDB, "CastbarInterruptCooldown", function() Private:UpdateCastbarInterruptCooldown() end)
    Enhancements.args.OverAbsorbs = GUI:Toggle("Health: Over Absorbs", "Shows a reverse fill absorb bar when absorbs exceed missing health.", 3, 1, EnhancementsDB, "OverAbsorbs", function() Private:UpdateOverAbsorbs() end)
    Enhancements.args.LFGHelper = GUI:Toggle("LFG: Keystone Helper", "Shows an additional window when searching for Mythic+ dungeons.", 4, 1, EnhancementsDB, "LFGHelper", function() Private:UpdateLFGHelper() end)
    local OverlayDB = EnhancementsDB.NameplateTextureOverlay
    local UpdateOverlay = function() Private:UpdateNameplateTextureOverlay() end
    local Overlay = GUI:InlineGroup("Nameplate: Focus Texture Overlay", 5)
    Overlay.args.Enable = GUI:Toggle("Enable", "Applies a custom texture over the focus nameplate.", 1, 1, OverlayDB, "Enable", UpdateOverlay)
    Overlay.args.Texture = GUI:Media("Texture", 2, 0.33, "statusbar", OverlayDB, "Texture", UpdateOverlay)
    Overlay.args.Colour = GUI:Colour("Colour", 3, 0.33, OverlayDB, "Colour", UpdateOverlay)
    Overlay.args.Opacity = GUI:Range("Opacity", 4, 0.33, 0, 1, 0.01, OverlayDB, "Opacity", UpdateOverlay, true)
    GUI:DisableOptions(Overlay, OverlayDB)
    Enhancements.args.NameplateTextureOverlay = Overlay
    Args.ElvUIEnhancements = Enhancements

    local QualityOfLife = ACH:Group("Quality of Life", nil, 4, "tree")
    local Toggles = ACH:Group("Toggles", nil, 1)
    local ToggleDB = DB.QualityOfLife.Toggles
    Toggles.args.AutoDelete = GUI:Toggle("Auto Delete", "Automatically complete |cFFFFCC00DELETE|r when applicable.", 1, 1, ToggleDB, "AutoDelete")
    Toggles.args.AutoQuest = GUI:Toggle("Auto Quest", "Automatically accept and turn in quests when applicable. Hold |cFFFFCC00SHIFT|r to override.", 2, 1, ToggleDB, "AutoQuest", function() Private:SetupAutoQuest() end)
    Toggles.args.AutoRepair = GUI:Toggle("Auto Repair", "Automatically repair items when visiting a merchant. |cFFFFCC00Guild|r then |cFFFFCC00Personal|r.", 3, 1, ToggleDB, "AutoRepair")
    Toggles.args.AutoSellGreys = GUI:Toggle("Auto Sell Greys", "Automatically sell grey/junk items when visiting a merchant.", 4, 1, ToggleDB, "AutoSellGreys", function() Private:SetupAutoSellGreys() end)
    Toggles.args.AutoSignUp = GUI:Toggle("Auto Sign Up", "Automatically select your role when signing up for a group. Hold |cFFFFCC00SHIFT|r to override.", 5, 1, ToggleDB, "AutoSignUp")
    Toggles.args.KeystoneReroll = GUI:Toggle("Keystone Reroll", "Shows a reminder to reroll your keystone at the end of a Mythic+.", 6, 1, ToggleDB, "KeystoneReroll", function() Private:UpdateKeystoneRerollReminder() end)
    Toggles.args.RemoveBossBanner = GUI:Toggle("Remove Boss Banner", "Prevents the Boss Banner frame from appearing.", 7, 1, ToggleDB, "RemoveBossBanner")
    Toggles.args.RemoveTalkingHead = GUI:Toggle("Remove Talking Head", "Prevents the Talking Head frame from appearing.", 8, 1, ToggleDB, "RemoveTalkingHead")
    Toggles.args.SkipCinematics = GUI:Toggle("Skip Cinematics", "Automatically skip cinematics.", 9, 1, ToggleDB, "SkipCinematics")
    QualityOfLife.args.Toggles = Toggles
    local Alerts = ACH:Group("Alerts", nil, 2, "tree")
    for Order, Alert in ipairs({
        {Key = "Bloodlust", Name = "Bloodlust", Spell = 2825, Update = "UpdateBloodlustAlert"},
        {Key = "Externals", Name = "Externals", Spell = 33206, Update = "UpdateExternalsAlert"},
        {Key = "Innervate", Name = "Innervate", Spell = 29166, Update = "UpdateInnervateAlert"},
        {Key = "PowerInfusion", Name = "Power Infusion", Spell = 10060, Update = "UpdatePowerInfusionAlert"},
        {Key = "TimeSpiral", Name = "Time Spiral", Spell = 375234, Update = "UpdateTimeSpiralAlert"},
    }) do
        local AlertDB = DB.QualityOfLife.Alerts[Alert.Key]
        local Update = function() Private[Alert.Update](Private) end
        local Group = ACH:Group(Alert.Name, nil, Order)
        Group.icon = Private:FetchSpellTexture(Alert.Spell)
        Group.args.Enable = GUI:Toggle("Enable", nil, 1, 1, AlertDB, "Enable", Update)
        Group.args.LayoutOptions = GUI:LayoutOptions(AlertDB, Update)
        Group.args.SoundOptions = GUI:SoundOptions(AlertDB, Update)
        GUI:DisableOptions(Group, AlertDB)
        Alerts.args[Alert.Key] = Group
    end
    QualityOfLife.args.Alerts = Alerts
    Args.QualityOfLife = QualityOfLife

    local DamageMeter = ACH:Group("Damage Meter", nil, 5, "tree")
    DamageMeter.args.WindowOne = GUI:DamageMeterOptions(DB.DamageMeter[1], 1)
    DamageMeter.args.WindowTwo = GUI:DamageMeterOptions(DB.DamageMeter[2], 2)
    DamageMeter.args.WindowThree = GUI:DamageMeterOptions(DB.DamageMeter[3], 3)
    Args.DamageMeter = DamageMeter

    local CastDB = DB.DungeonCasts
    local UpdateCasts = function()
        Private:SetupDungeonCasts()
        if Private.PreviewDungeonCastsActive and not Private.DungeonCastsFrame.Testing then Private:TestDungeonCasts() end
    end
    local DungeonCasts = ACH:Group("Dungeon Casts", nil, 6)
    DungeonCasts.args.Enable = GUI:Toggle("Enable", "Tracks enemy NPC casts on nearby nameplates.", 1, 1, CastDB, "Enable", UpdateCasts)
    DungeonCasts.args.LayoutOptions = GUI:LayoutOptions(CastDB, UpdateCasts)
    local Colours = GUI:InlineGroup("Colours & Textures", 11)
    Colours.args.Texture = GUI:Media("Texture", 1, 1, "statusbar", CastDB, "Texture", UpdateCasts)
    Colours.args.BackgroundColour = GUI:Colour("Background", 2, 0.5, CastDB, "BackgroundColour", UpdateCasts)
    Colours.args.InterruptibleColour = GUI:Colour("Interrupt Ready", 3, 0.5, CastDB, "InterruptibleColour", UpdateCasts)
    Colours.args.NonInterruptibleColour = GUI:Colour("Cannot Interrupt", 4, 0.5, CastDB, "NonInterruptibleColour", UpdateCasts)
    Colours.args.InterruptOnCooldownColour = GUI:Colour("Interrupt On Cooldown", 5, 0.5, CastDB, "InterruptOnCooldownColour", UpdateCasts)
    DungeonCasts.args.Colours = Colours
    DungeonCasts.args.FontOptions = GUI:FontOptions(CastDB, UpdateCasts, true)
    DungeonCasts.args.FontOptions.order = 12
    GUI:DisableOptions(DungeonCasts, CastDB)
    Args.DungeonCasts = DungeonCasts

    local CombatDB = DB.CombatAlert
    local UpdateCombat = function() Private:UpdateCombatAlert() end
    local CombatAlert = ACH:Group("Combat Alert", nil, 7)
    CombatAlert.args.Enable = GUI:Toggle("Enable", nil, 1, 1, CombatDB, "Enable", UpdateCombat)
    CombatAlert.args.LayoutOptions = GUI:LayoutOptions(CombatDB, UpdateCombat)
    CombatAlert.args.FontOptions = GUI:FontOptions(CombatDB.Text, UpdateCombat)
    local CombatText = GUI:InlineGroup("Text Options", 12)
    CombatText.args.EnteringCombat = ACH:Header("|cFFCCCCCCEntering Combat|r", 1)
    CombatText.args.EnteringColour = GUI:Colour("Colour", 2, 0.5, CombatDB.Text.EnteringCombat, "Colour", UpdateCombat)
    CombatText.args.EnteringText = GUI:Input(nil, 3, 0.5, CombatDB.Text.EnteringCombat, "Text", UpdateCombat)
    CombatText.args.ExitingCombat = ACH:Header("|cFFCCCCCCExiting Combat|r", 4)
    CombatText.args.ExitingColour = GUI:Colour("Colour", 5, 0.5, CombatDB.Text.ExitingCombat, "Colour", UpdateCombat)
    CombatText.args.ExitingText = GUI:Input(nil, 6, 0.5, CombatDB.Text.ExitingCombat, "Text", UpdateCombat)
    CombatAlert.args.TextOptions = CombatText
    GUI:DisableOptions(CombatAlert, CombatDB)
    Args.CombatAlert = CombatAlert

    local TimerDB = DB.CombatTimer
    local UpdateTimer = function() Private:UpdateCombatTimer() end
    local CombatTimer = ACH:Group("Combat Timer", nil, 8)
    CombatTimer.args.Enable = GUI:Toggle("Enable", nil, 1, 1, TimerDB, "Enable", UpdateTimer)
    CombatTimer.args.LayoutOptions = GUI:LayoutOptions(TimerDB, UpdateTimer)
    CombatTimer.args.FontOptions = GUI:FontOptions(TimerDB.Text, UpdateTimer)
    GUI:DisableOptions(CombatTimer, TimerDB)
    Args.CombatTimer = CombatTimer

    local CursorDB = DB.MouseCursor
    local UpdateCursor = function() Private:UpdateMouseCursor() end
    local MouseCursor = ACH:Group("Mouse Cursor", nil, 9)
    MouseCursor.args.Enable = GUI:Toggle("Enable", nil, 1, 0.33, CursorDB, "Enable", UpdateCursor)
    MouseCursor.args.Colour = GUI:Colour("Colour", 2, 0.33, CursorDB, "Colour", UpdateCursor)
    MouseCursor.args.Texture = GUI:Select("Texture", 3, 0.33, Private.MouseCursorTexturePreviews, CursorDB, "Texture", UpdateCursor)
    MouseCursor.args.LayoutOptions = GUI:LayoutOptions(CursorDB, UpdateCursor)
    GUI:DisableOptions(MouseCursor, CursorDB)
    Args.MouseCursor = MouseCursor

    local VendorDB = DB.VendorSupport
    local VendorSupport = ACH:Group("Vendor Support", nil, 10)
    VendorSupport.args.Enable = GUI:Toggle("Enable", "This will automatically vendor items that meet the criteria.", 1, 1, VendorDB, "Enable", function() Private:SetupVendorSupport() end)
    VendorSupport.args.MinimumQuality = GUI:Select("Minimum Quality", 2, 0.5, Private.ItemQualities, VendorDB, "MinimumQuality")
    VendorSupport.args.MinimumItemLevel = GUI:Range("Minimum Item Level", 3, 0.5, 0, 500, 1, VendorDB, "MinimumItemLevel")
    GUI:DisableOptions(VendorSupport, VendorDB)
    Args.VendorSupport = VendorSupport

    local Profiles = ACH:Group("Profiles", nil, 11)
    local Profile = GUI:InlineGroup("Profiles", 1)
    Profile.args.Description = ACH:Description(Private.AddOnName .. " uses a |cFFFFCC00global|r profile shared across all characters. Importing a profile will overwrite your existing settings.", 1)
    Profile.args.Export = GUI:Button("Export Profile", 2, 0.33, function() Private:ExportProfile() end)
    Profile.args.Import = GUI:Button("Import Profile", 3, 0.33, function() Private:ImportProfile() end)
    Profile.args.Reset = GUI:Button("Reset Profile", 4, 0.33, function() Private:ResetProfile() end)
    Profiles.args.Profiles = Profile
    local Imports = GUI:InlineGroup("Profile Imports", 2)
    Imports.args.ElvUIProfile = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\ElvUI.tga:16:16|t ElvUI: Profile", 1, 0.5, function() Private.Distributor:ImportProfile(Private:ImportElvUI()["PROFILE"]) end)
    Imports.args.ElvUIPrivate = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\ElvUI.tga:16:16|t ElvUI: Private", 2, 0.5, function() Private.Distributor:ImportProfile(Private:ImportElvUI()["PRIVATE"]) end)
    Imports.args.Baganator = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\Baganator.tga:16:16|t Baganator", 3, nil, function() Baganator.API.ImportString(Private:ImportBaganator(), "Default") end, not C_AddOns.IsAddOnLoaded("Baganator"))
    Imports.args.BigWigs = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\BigWigs.tga:16:16|t BigWigs", 4, nil, function() Private:ImportBigWigs() end, not C_AddOns.IsAddOnLoaded("BigWigs"))
    Imports.args.LSToasts = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\LSToasts.TGA:16:16|t LS: Toasts", 5, nil, function() Private:ImportLSToasts() end, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
    Imports.args.Platynator = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\Platynator.tga:16:16|t Platynator", 6, nil, function() Platynator.API.ImportString(Private:ImportPlatynator(), "Default") end, not C_AddOns.IsAddOnLoaded("Platynator"))
    Imports.args.SkironCooldownManager = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\SkironCooldownManager.png:16:16|t Skiron Cooldown Manager", 7, nil, function() SCMAPI.ImportProfile("ElvUI_Unhalted", Private:ImportSkironCooldownManager()) end, not C_AddOns.IsAddOnLoaded("SkironCooldownManager"))
    Imports.args.UnhaltedUI = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Logo_64.png:16:16|t UnhaltedUI", 8, nil, function() Private:ImportUnhaltedUI() end)
    Imports.args.WarpDeplete = GUI:Button("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\WarpDeplete.blp:16:16|t WarpDeplete", 9, nil, function() Private:ImportWarpDeplete() Private:PromptReload() end, not C_AddOns.IsAddOnLoaded("WarpDeplete"))
    Profiles.args.Imports = Imports
    if Private:IsDeveloper() then
        local Exports = GUI:InlineGroup("Profile Exports", 3)
        Exports.args.LSToasts = GUI:Button("Export |TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\LSToasts.TGA:16:16|t LS: Toasts", 1, nil, function() Private:ExportLSToasts() end, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
        Exports.args.WarpDeplete = GUI:Button("Export |TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\WarpDeplete.blp:16:16|t WarpDeplete", 2, nil, function() Private:ExportWarpDeplete() end, not C_AddOns.IsAddOnLoaded("WarpDeplete"))
        Profiles.args.Exports = Exports
    end
    Args.Profiles = Profiles

    Private.ElvUI.Options.args.ElvUI_Unhalted = Options
    local SkinStatus = Private.ElvUI.Libs.AceConfigDialog:GetStatusTable("ElvUI", {"ElvUI_Unhalted", "AddOnSkins"})
    if not SkinStatus.groups then SkinStatus.groups = {selected = "BugSack"} end

    hooksecurefunc(Private.ElvUI.Libs.AceConfigDialog, "FeedGroup", function(_, AppName, _, _, RootFrame, Path)
        if AppName ~= "ElvUI" then return end
        if not RootFrame.frame.UnhaltedPreviewsHooked then
            RootFrame.frame:HookScript("OnHide", function() Private:UpdateGUIPreviews() end)
            RootFrame.frame.UnhaltedPreviewsHooked = true
        end
        if Path[1] == "ElvUI_Unhalted" then
            if Path[2] then Private:UpdateGUIPreviews(Path[2]) end
            if Path[2] == "QualityOfLife" and Path[3] == "Alerts" and not Path[4] then
                Private.ElvUI.Libs.AceConfigDialog:SelectGroup("ElvUI", "ElvUI_Unhalted", "QualityOfLife", "Alerts", "Bloodlust")
            end
        elseif Path[1] then
            Private:UpdateGUIPreviews()
        end
    end)
end
