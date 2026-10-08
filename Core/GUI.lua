local Private = select(2, ...)
local AG = Private.AG

function Private:CreateGUI()
    local GUIFrame = AG:Create("Frame")
    GUIFrame:SetTitle(Private.AddOnName)
    GUIFrame:SetStatusText("V" .. Private.AddOnVersion)
    GUIFrame:SetWidth(1040)
    GUIFrame:SetHeight(780)
    GUIFrame:SetLayout("Fill")
    GUIFrame:SetCallback("OnClose",
    function(GUIWidgets)
        AG:Release(GUIFrame)
        Private.PreviewAlertsActive = false
        Private.PreviewCombatAlertActive = false
        Private:SetupPreviewAlerts()
        Private:PreviewCombatAlert()
        Private:SetDamageMeterTestMode(false)
        Private.PreviewDungeonCastsActive = false
        Private:TestDungeonCasts()
    end)

    local TabGroup = AG:Create("TabGroup")
    TabGroup:SetLayout("Fill")
    TabGroup:SetFullWidth(true)
    TabGroup:SetTabs({
        { text = "AddOn Skins", value = "AddOnSkins" },
        { text = "Blizzard", value = "Blizzard" },
        { text = "ElvUI Enhancements", value = "ElvUIEnhancements" },
        { text = "Quality of Life", value = "QualityOfLife" },
        { text = "Damage Meter", value = "DamageMeter" },
        { text = "Dungeon Casts", value = "DungeonCasts" },
        { text = "Combat Alert", value = "CombatAlert" },
        { text = "Combat Timer", value = "CombatTimer" },
        { text = "Mouse Cursor", value = "MouseCursor" },
        { text = "Vendor Support", value = "VendorSupport" },
        { text = "Profiles", value = "Profiles" },
    })
    TabGroup:SetCallback("OnGroupSelected", function(_GF, Event, Group)
        _GF:ReleaseChildren()
        if Group == "AddOnSkins" then
            local Options = {
                { text = "AddOn Profiler", value = "AddOnProfiler", disabled = not C_AddOns.IsAddOnLoaded("!!AddonProfiler") },
                { text = "BigWigs", value = "BigWigs", disabled = not C_AddOns.IsAddOnLoaded("BigWigs") },
                { text = "BugSack", value = "BugSack", disabled = not C_AddOns.IsAddOnLoaded("BugSack") },
                { text = "SimulationCraft", value = "SimulationCraft", disabled = not C_AddOns.IsAddOnLoaded("SimulationCraft") },
                { text = "Skiron Cooldown Manager", value = "SkironCooldownManager", disabled = not C_AddOns.IsAddOnLoaded("SkironCooldownManager") },
                { text = "Miscellaneous", value = "Miscellaneous" }
            }

            local TreeGroup = AG:Create("TreeGroup")
            TreeGroup:SetLayout("Fill")
            TreeGroup:SetFullWidth(true)
            TreeGroup:SetFullHeight(true)
            TreeGroup:SetTree(Options)
            TreeGroup:SetCallback("OnGroupSelected", function(__GF, _, Value)
                __GF:ReleaseChildren()
                if Value == "BugSack" then
                    local DB = Private.DB.global.AddOnSkins.BugSack
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", "Skins & Positioning the BugSack Minimap Button", nil, DB, "Enable", function() Private:PromptReload() end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateBugSackSkin() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
                elseif Value == "AddOnProfiler" then
                    local DB = Private.DB.global.AddOnSkins.AddOnProfiler
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", "Skins & Positioning the AddOn Profiler Minimap Button", nil, DB, "Enable", function() Private:PromptReload() end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateAddOnProfilerSkin() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
                elseif Value == "SkironCooldownManager" then
                    local DB = Private.DB.global.AddOnSkins.SkironCooldownManager
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", "Skins & Positioning the Skiron Cooldown Manager Minimap Button", nil, DB, "Enable", function() Private:PromptReload() end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateSkironCooldownManagerSkin() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
                elseif Value == "BigWigs" then
                    local DB = Private.DB.global.AddOnSkins.BigWigs
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", "Skins & Positioning the BigWigs Minimap Button", nil, DB, "Enable", function() Private:PromptReload() end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateBigWigsSkin() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
                elseif Value == "SimulationCraft" then
                    local DB = Private.DB.global.AddOnSkins.SimulationCraft
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", "Skins & Positioning the SimulationCraft Minimap Button", nil, DB, "Enable", function() Private:PromptReload() end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateSimulationCraftSkin() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
                elseif Value == "Miscellaneous" then
                    local DB = Private.DB.global.AddOnSkins.Miscellaneous
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\LSToasts.TGA:16:16|t LS: |cFF1CD3A2Toasts|r", "Adds a skin to LS: Toasts to match the UI aesthetic.", nil, DB, "LSToasts", function() Private:PromptReload() end)
                end
            end)
            TreeGroup:SelectByValue("BugSack")
            _GF:AddChild(TreeGroup)
        elseif Group == "Blizzard" then
            local DB = Private.DB.global.Blizzard

            local Options = {
                { text = "Action Status", value = "ActionStatus" },
                { text = "Better Prey", value = "BetterPrey" },
                { text = "UI Errors", value = "UIErrorsFrame" },
                { text = "Zone Text", value = "ZoneText" },
                { text = "Sub Zone Text", value = "SubZoneText" }
            }

            local TreeGroup = AG:Create("TreeGroup")
            TreeGroup:SetLayout("Fill")
            TreeGroup:SetFullWidth(true)
            TreeGroup:SetFullHeight(true)
            TreeGroup:SetTree(Options)
            TreeGroup:SetCallback("OnGroupSelected", function(__GF, _, Value)
                __GF:ReleaseChildren()
                if Value == "ActionStatus" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, DB.ActionStatus, "Enable", function() Private:UpdateActionStatusFrame() Private.GUI:UpdateGUIState(ScrollFrame, DB.ActionStatus.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB.ActionStatus, function() Private:UpdateActionStatusFrame() end)
                    Private.GUI:FontOptions(ScrollFrame, DB.ActionStatus, function() Private:UpdateActionStatusFrame() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.ActionStatus.Enable)
                elseif Value == "BetterPrey" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", "Displays Prey progression in a more convenient way.", 0.5, DB.BetterPrey, "Enable", function() Private:UpdateBetterPrey() Private.GUI:UpdateGUIState(ScrollFrame, DB.BetterPrey.Enable) end)
                    Private.GUI:CreateToggle(ScrollFrame, "Colour by Stage", nil, 0.5, DB.BetterPrey, "ColourByStage", function() Private:UpdateBetterPrey() Private.GUI:UpdateGUIState(ScrollFrame, DB.BetterPrey.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB.BetterPrey, function() Private:UpdateBetterPrey() Private.GUI:UpdateGUIState(ScrollFrame, DB.BetterPrey.Enable) end, function() return 12, 12 end)
                    local TextOptions = Private.GUI:CreateInlineGroup(ScrollFrame, "Text Options", "CENTER")
                    Private.GUI:CreateToggle(TextOptions, "Enable", nil, nil, DB.BetterPrey.Text, "Enable", function() Private:UpdateBetterPrey() Private.GUI:UpdateGUIState(ScrollFrame, DB.BetterPrey.Enable) end)
                    Private.GUI:FontOptions(TextOptions, DB.BetterPrey.Text, function() Private:UpdateBetterPrey() Private.GUI:UpdateGUIState(ScrollFrame, DB.BetterPrey.Enable) end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.BetterPrey.Enable)
                elseif Value == "UIErrorsFrame" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, DB.UIErrorsFrame, "Enable", function() Private:UpdateUIErrorsFrame() Private.GUI:UpdateGUIState(ScrollFrame, DB.UIErrorsFrame.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, DB.UIErrorsFrame, function() Private:UpdateUIErrorsFrame() end)
                    Private.GUI:FontOptions(ScrollFrame, DB.UIErrorsFrame, function() Private:UpdateUIErrorsFrame() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, DB.UIErrorsFrame.Enable)
                elseif Value == "ZoneText" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, Private.DB.global.Blizzard.ZoneText, "Enable", function() Private:UpdateZoneText() Private.GUI:UpdateGUIState(ScrollFrame, Private.DB.global.Blizzard.ZoneText.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, Private.DB.global.Blizzard.ZoneText, function() Private:UpdateZoneText() end)
                    Private.GUI:FontOptions(ScrollFrame, Private.DB.global.Blizzard.ZoneText, function() Private:UpdateZoneText() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, Private.DB.global.Blizzard.ZoneText.Enable)
                elseif Value == "SubZoneText" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, Private.DB.global.Blizzard.SubZoneText, "Enable", function() Private:UpdateZoneText() Private.GUI:UpdateGUIState(ScrollFrame, Private.DB.global.Blizzard.SubZoneText.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, Private.DB.global.Blizzard.SubZoneText, function() Private:UpdateZoneText() end)
                    Private.GUI:FontOptions(ScrollFrame, Private.DB.global.Blizzard.SubZoneText, function() Private:UpdateZoneText() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, Private.DB.global.Blizzard.SubZoneText.Enable)
                end
            end)
            TreeGroup:SelectByValue("ActionStatus")
            _GF:AddChild(TreeGroup)
        elseif Group == "ElvUIEnhancements" then
            local DB = Private.DB.global.ElvUIEnhancements
            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)
            Private.GUI:CreateToggle(ScrollFrame, "Loot Roll: Fix Backdrop", "Force the loot roll backdrop to be fully opaque.", nil, DB, "ForceAlphaOnLootRoll", function() Private:PromptReload() end)
            Private.GUI:CreateToggle(ScrollFrame, "Castbar: Interrupt On Cooldown", "Colours interruptible enemy unit frame and nameplate castbars grey while your interrupt is on cooldown.", nil, DB, "CastbarInterruptCooldown", function() Private:UpdateCastbarInterruptCooldown() end)
            Private.GUI:CreateToggle(ScrollFrame, "Health: Over Absorbs", "Shows a reverse fill absorb bar when absorbs exceed missing health.", nil, DB, "OverAbsorbs", function() Private:UpdateOverAbsorbs() end)
            Private.GUI:CreateToggle(ScrollFrame, "LFG: Keystone Helper", "Shows an additional window when searching for Mythic+ dungeons.", nil, DB, "LFGHelper", function() Private:UpdateLFGHelper() end)
        elseif Group == "QualityOfLife" then
            local DB = Private.DB.global.QualityOfLife
            local ToggleDB = DB.Toggles
            local AlertsDB = DB.Alerts

            local Options = {
                { text = "Toggles", value = "Toggles" },
                {
                    text = "Alerts",
                    value = "Alerts",
                    children = {
                        { text = "Bloodlust", value = "Bloodlust", icon = Private:FetchSpellTexture(2825) },
                        { text = "Externals", value = "Externals", icon = Private:FetchSpellTexture(33206) },
                        { text = "Innervate", value = "Innervate", icon = Private:FetchSpellTexture(29166) },
                        { text = "Power Infusion", value = "PowerInfusion", icon = Private:FetchSpellTexture(10060) },
                        { text = "Time Spiral", value = "TimeSpiral", icon = Private:FetchSpellTexture(375234) },
                    }
                },
            }

            local TreeGroup = AG:Create("TreeGroup")
            TreeGroup:SetLayout("Fill")
            TreeGroup:SetFullWidth(true)
            TreeGroup:SetFullHeight(true)
            TreeGroup:SetTree(Options)
            TreeGroup:SetCallback("OnGroupSelected", function(__GF, _, Value)
                __GF:ReleaseChildren()
                if Value == "Toggles" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Auto Delete", "Automatically complete |cFFFFCC00DELETE|r when applicable.", nil, ToggleDB, "AutoDelete", nil)
                    Private.GUI:CreateToggle(ScrollFrame, "Auto Quest", "Automatically accept and turn in quests when applicable. Hold |cFFFFCC00SHIFT|r to override.", nil, ToggleDB, "AutoQuest", function() Private:SetupAutoQuest() end)
                    Private.GUI:CreateToggle(ScrollFrame, "Auto Repair", "Automatically repair items when visiting a merchant. |cFFFFCC00Guild|r then |cFFFFCC00Personal|r.", nil, ToggleDB, "AutoRepair", nil)
                    Private.GUI:CreateToggle(ScrollFrame, "Auto Sell Greys", "Automatically sell grey/junk items when visiting a merchant.", nil, ToggleDB, "AutoSellGreys", function() Private:SetupAutoSellGreys() end)
                    Private.GUI:CreateToggle(ScrollFrame, "Auto Sign Up", "Automatically select your role when signing up for a group. Hold |cFFFFCC00SHIFT|r to override.", nil, ToggleDB, "AutoSignUp", nil)
                    Private.GUI:CreateToggle(ScrollFrame, "Keystone Reroll", "Shows a reminder to reroll your keystone at the end of a Mythic+.", nil, ToggleDB, "KeystoneReroll", function() Private:UpdateKeystoneRerollReminder() end)
                    Private.GUI:CreateToggle(ScrollFrame, "Remove Boss Banner", "Prevents the Boss Banner frame from appearing.", nil, ToggleDB, "RemoveBossBanner", nil)
                    Private.GUI:CreateToggle(ScrollFrame, "Remove Talking Head", "Prevents the Talking Head frame from appearing.", nil, ToggleDB, "RemoveTalkingHead", nil)
                    Private.GUI:CreateToggle(ScrollFrame, "Skip Cinematics", "Automatically skip cinematics.", nil, ToggleDB, "SkipCinematics", nil)
                elseif Value == "Alerts" then
                    TreeGroup:SelectByValue("Alerts\001Bloodlust")
                elseif Value == "Alerts\001PowerInfusion" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, AlertsDB.PowerInfusion, "Enable", function() Private:UpdatePowerInfusionAlert() Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.PowerInfusion.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, AlertsDB.PowerInfusion, function() Private:UpdatePowerInfusionAlert() end)
                    Private.GUI:SoundOptions(ScrollFrame, AlertsDB.PowerInfusion, function() Private:UpdatePowerInfusionAlert() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.PowerInfusion.Enable)
                elseif Value == "Alerts\001Innervate" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, AlertsDB.Innervate, "Enable", function() Private:UpdateInnervateAlert() Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.Innervate.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, AlertsDB.Innervate, function() Private:UpdateInnervateAlert() end)
                    Private.GUI:SoundOptions(ScrollFrame, AlertsDB.Innervate, function() Private:UpdateInnervateAlert() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.Innervate.Enable)
                elseif Value == "Alerts\001TimeSpiral" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, AlertsDB.TimeSpiral, "Enable", function() Private:UpdateTimeSpiralAlert() Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.TimeSpiral.Enable)end)
                    Private.GUI:LayoutOptions(ScrollFrame, AlertsDB.TimeSpiral, function() Private:UpdateTimeSpiralAlert() end)
                    Private.GUI:SoundOptions(ScrollFrame, AlertsDB.TimeSpiral, function() Private:UpdateTimeSpiralAlert() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.TimeSpiral.Enable)
                elseif Value == "Alerts\001Bloodlust" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, AlertsDB.Bloodlust, "Enable", function() Private:UpdateBloodlustAlert() Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.Bloodlust.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, AlertsDB.Bloodlust, function() Private:UpdateBloodlustAlert() end)
                    Private.GUI:SoundOptions(ScrollFrame, AlertsDB.Bloodlust, function() Private:UpdateBloodlustAlert() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.Bloodlust.Enable)
                elseif Value == "Alerts\001Externals" then
                    local ScrollFrame = Private.GUI:CreateScrollFrame(__GF)
                    Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, AlertsDB.Externals, "Enable", function() Private:UpdateExternalsAlert() Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.Externals.Enable) end)
                    Private.GUI:LayoutOptions(ScrollFrame, AlertsDB.Externals, function() Private:UpdateExternalsAlert() end)
                    Private.GUI:SoundOptions(ScrollFrame, AlertsDB.Externals, function() Private:UpdateExternalsAlert() end)
                    Private.GUI:UpdateGUIState(ScrollFrame, AlertsDB.Externals.Enable)
                end
            end)
            TreeGroup:SelectByValue("Toggles")
            _GF:AddChild(TreeGroup)
        elseif Group == "DamageMeter" then
            local DB = Private.DB.global.DamageMeter

            local Options = {
                { text = "Window #1", value = "WindowOne" },
                { text = "Window #2", value = "WindowTwo" },
                { text = "Window #3", value = "WindowThree" },
            }

            local TreeGroup = AG:Create("TreeGroup")
            TreeGroup:SetLayout("Fill")
            TreeGroup:SetFullWidth(true)
            TreeGroup:SetFullHeight(true)
            TreeGroup:SetTree(Options)
            TreeGroup:SetCallback("OnGroupSelected", function(__GF, _, Value)
                __GF:ReleaseChildren()
                if Value == "WindowOne" then
                    Private.GUI:DamageMeterOptions(__GF, DB[1], function() Private:UpdateDamageMeter() end)
                elseif Value == "WindowTwo" then
                    Private.GUI:DamageMeterOptions(__GF, DB[2], function() Private:UpdateDamageMeter() end)
                elseif Value == "WindowThree" then
                    Private.GUI:DamageMeterOptions(__GF, DB[3], function() Private:UpdateDamageMeter() end)
                end
            end)
            TreeGroup:SelectByValue("WindowOne")
            _GF:AddChild(TreeGroup)
        elseif Group == "CombatAlert" then
            local DB = Private.DB.global.CombatAlert
            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)

            Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, DB, "Enable", function() Private:UpdateCombatAlert() Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable) end)

            Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateCombatAlert() end)
            Private.GUI:FontOptions(ScrollFrame, DB.Text, function() Private:UpdateCombatAlert() end)

            local TextOptionsGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Text Options", "CENTER")

            Private.GUI:CreateHeading(TextOptionsGroup, "Entering Combat")
            Private.GUI:CreateColourPicker(TextOptionsGroup, "Colour", 0.5, DB.Text.EnteringCombat, "Colour", function() Private:UpdateCombatAlert() end)
            Private.GUI:CreateEditBox(TextOptionsGroup, nil, 0.5, DB.Text.EnteringCombat, "Text", function() Private:UpdateCombatAlert() end)

            Private.GUI:CreateHeading(TextOptionsGroup, "Exiting Combat")
            Private.GUI:CreateColourPicker(TextOptionsGroup, "Colour", 0.5, DB.Text.ExitingCombat, "Colour", function() Private:UpdateCombatAlert() end)
            Private.GUI:CreateEditBox(TextOptionsGroup, nil, 0.5, DB.Text.ExitingCombat, "Text", function() Private:UpdateCombatAlert() end)

            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        elseif Group == "DungeonCasts" then
            local DB = Private.DB.global.DungeonCasts
            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)
            local Update = function()
                Private:SetupDungeonCasts()
                if Private.PreviewDungeonCastsActive and not Private.DungeonCastsFrame.Testing then Private:TestDungeonCasts() end
            end
            Private.GUI:CreateToggle(ScrollFrame, "Enable", "Tracks enemy NPC casts on nearby nameplates.", nil, DB, "Enable", function() Update() Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable) end)
            Private.GUI:LayoutOptions(ScrollFrame, DB, Update)

            local Colours = Private.GUI:CreateInlineGroup(ScrollFrame, "Colours & Textures", "CENTER")
            local Texture = AG:Create("LSM30_Statusbar")
            Texture:SetLabel("Texture")
            Texture:SetList(Private.LSM:HashTable("statusbar"))
            Texture:SetValue(DB.Texture)
            Texture:SetFullWidth(true)
            Texture:SetCallback("OnValueChanged", function(_, _, Value) Texture:SetValue(Value) DB.Texture = Value Update() end)
            Colours:AddChild(Texture)
            Private.GUI:CreateColourPicker(Colours, "Background", 0.5, DB, "BackgroundColour", Update)
            Private.GUI:CreateColourPicker(Colours, "Interrupt Ready", 0.5, DB, "InterruptibleColour", Update)
            Private.GUI:CreateColourPicker(Colours, "Cannot Interrupt", 0.5, DB, "NonInterruptibleColour", Update)
            Private.GUI:CreateColourPicker(Colours, "Interrupt On Cooldown", 0.5, DB, "InterruptOnCooldownColour", Update)
            Private.GUI:FontOptions(ScrollFrame, DB, Update, true)
            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        elseif Group == "CombatTimer" then
            local DB = Private.DB.global.CombatTimer
            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)

            Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, nil, DB, "Enable", function() Private:UpdateCombatTimer() Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable) end)

            Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateCombatTimer() end)
            Private.GUI:FontOptions(ScrollFrame, DB.Text, function() Private:UpdateCombatTimer() end)

            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        elseif Group == "MouseCursor" then
            local DB = Private.DB.global.MouseCursor

            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)
            Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, 0.33, DB, "Enable", function() Private:UpdateMouseCursor() Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable) end)

            Private.GUI:CreateColourPicker(ScrollFrame, "Colour", 0.33, DB, "Colour", function() Private:UpdateMouseCursor() end)

            local MouseCursorTextureDropdown = AG:Create("Dropdown")
            MouseCursorTextureDropdown:SetLabel("Texture")
            MouseCursorTextureDropdown:SetList(Private.MouseCursorTexturePreviews)
            MouseCursorTextureDropdown:SetValue(DB.Texture)
            MouseCursorTextureDropdown:SetRelativeWidth(0.33)
            MouseCursorTextureDropdown:SetCallback("OnValueChanged", function(_, _, Value) DB.Texture = Value Private:UpdateMouseCursor() end)
            MouseCursorTextureDropdown:SetDisabled(not DB.Enable)
            ScrollFrame:AddChild(MouseCursorTextureDropdown)

            Private.GUI:LayoutOptions(ScrollFrame, DB, function() Private:UpdateMouseCursor() end)
            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        elseif Group == "VendorSupport" then
            local DB = Private.DB.global.VendorSupport
            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)
            Private.GUI:CreateToggle(ScrollFrame, "Enable", "This will automatically vendor items that meet the criteria.", nil, DB, "Enable", function() Private:SetupVendorSupport() Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable) end)

            local MinimumQualityDropdown = AG:Create("Dropdown")
            MinimumQualityDropdown:SetLabel("Minimum Quality")
            MinimumQualityDropdown:SetList(Private.ItemQualities)
            MinimumQualityDropdown:SetValue(DB.MinimumQuality)
            MinimumQualityDropdown:SetCallback("OnValueChanged", function(_, _, value) DB.MinimumQuality = value end)
            MinimumQualityDropdown:SetRelativeWidth(0.5)
            ScrollFrame:AddChild(MinimumQualityDropdown)

            local MinimumItemLevelSlider = AG:Create("Slider")
            MinimumItemLevelSlider:SetLabel("Minimum Item Level")
            MinimumItemLevelSlider:SetSliderValues(0, 500, 1)
            MinimumItemLevelSlider:SetValue(DB.MinimumItemLevel)
            MinimumItemLevelSlider:SetCallback("OnValueChanged", function(_, _, value) DB.MinimumItemLevel = value end)
            MinimumItemLevelSlider:SetRelativeWidth(0.5)
            ScrollFrame:AddChild(MinimumItemLevelSlider)

            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        elseif Group == "Profiles" then
            local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)

            local ProfileInlineGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Profiles", "CENTER")

            local DescriptionLabel = AG:Create("Label")
            DescriptionLabel:SetText(Private.AddOnName .. " uses a |cFFFFCC00global|r profile shared across all characters. Importing a profile will overwrite your existing settings.")
            DescriptionLabel:SetJustifyH("CENTER")
            DescriptionLabel:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE, SLUG")
            DescriptionLabel:SetFullWidth(true)
            ProfileInlineGroup:AddChild(DescriptionLabel)

            Private.GUI:CreateButton(ProfileInlineGroup, "Export Profile", 0.33, function() Private:ExportProfile() end)
            Private.GUI:CreateButton(ProfileInlineGroup, "Import Profile", 0.33, function() Private:ImportProfile() end)
            Private.GUI:CreateButton(ProfileInlineGroup, "Reset Profile", 0.33, function() Private:ResetProfile() end)

            local ProfileImportsInlineGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Profile Imports", "CENTER")

            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\ElvUI.tga:16:16|t ElvUI: Profile", 0.5, function() Private.Distributor:ImportProfile(Private:ImportElvUI()["PROFILE"]) end)
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\ElvUI.tga:16:16|t ElvUI: Private", 0.5, function() Private.Distributor:ImportProfile(Private:ImportElvUI()["PRIVATE"]) end)

            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\Baganator.tga:16:16|t Baganator", nil, function() Baganator.API.ImportString(Private:ImportBaganator(), "Default") end, not C_AddOns.IsAddOnLoaded("Baganator"))
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\BigWigs.tga:16:16|t BigWigs", nil, function() Private:ImportBigWigs() end, not C_AddOns.IsAddOnLoaded("BigWigs"))
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\LSToasts.TGA:16:16|t LS: Toasts", nil, function() Private:ImportLSToasts() end, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\Platynator.tga:16:16|t Platynator", nil, function() Platynator.API.ImportString(Private:ImportPlatynator(), "Default") end, not C_AddOns.IsAddOnLoaded("Platynator"))
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\SkironCooldownManager.png:16:16|t Skiron Cooldown Manager", nil, function() SCMAPI.ImportProfile("ElvUI_Unhalted", Private:ImportSkironCooldownManager()) end, not C_AddOns.IsAddOnLoaded("SkironCooldownManager"))
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Logo_64.png:16:16|t UnhaltedUI", nil, function() Private:ImportUnhaltedUI() end)
            Private.GUI:CreateButton(ProfileImportsInlineGroup, "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\WarpDeplete.blp:16:16|t WarpDeplete", nil, function() Private:ImportWarpDeplete() Private:PromptReload() end, not C_AddOns.IsAddOnLoaded("WarpDeplete"))

            if Private:IsDeveloper() then
                local ProfileExportsInlineGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Profile Exports", "CENTER")

                Private.GUI:CreateButton(ProfileExportsInlineGroup, "Export |TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\LSToasts.TGA:16:16|t LS: Toasts", nil, function() Private:ExportLSToasts() end, not C_AddOns.IsAddOnLoaded("ls_Toasts"))
                Private.GUI:CreateButton(ProfileExportsInlineGroup, "Export |TInterface\\AddOns\\ElvUI_Unhalted\\Media\\AddOns\\WarpDeplete.blp:16:16|t WarpDeplete", nil, function() Private:ExportWarpDeplete() end, not C_AddOns.IsAddOnLoaded("WarpDeplete"))
            end
        end
        if Group == "CombatAlert" then Private.PreviewCombatAlertActive = true; Private:PreviewCombatAlert() else Private.PreviewCombatAlertActive = false; Private:PreviewCombatAlert() end
        if Group ~= "DamageMeter" then Private:SetDamageMeterTestMode(false) end
        Private.PreviewDungeonCastsActive = Group == "DungeonCasts"
        Private:TestDungeonCasts()
        if Group == "QualityOfLife" then Private.PreviewAlertsActive = true; Private:SetupPreviewAlerts() else Private.PreviewAlertsActive = false; Private:SetupPreviewAlerts() end
    end)
    TabGroup:SelectTab("AddOnSkins")
    GUIFrame:AddChild(TabGroup)
    return GUIFrame
end

function Private:SetupGUI()
    Private.ElvUI.Options.args.ElvUI_Unhalted = {
        type = "group",
        name = Private.AddOnName,
        order = 20,
        args = {
            OpenOptions = {
                type = "execute",
                name = "Open Options",
                order = 1,
                width = "full",
                func = function() Private:CreateGUI() end,
            },
        },
    }
end
