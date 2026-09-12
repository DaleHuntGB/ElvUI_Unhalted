local Private = select(2, ...)

local Defaults = {
    global = {
        AddOnSkins = {
            BigWigs = false,
            BugSack = false,
            LSToasts = false,
        },
        CombatAlert = {
            Enabled = false,
            Layout = {"CENTER", "CENTER", 0, 175},
            EnteringCombat = "+Combat",
            ExitingCombat = "-Combat",
            Font = { "Friz Quadrata TT", 15, "OUTLINE, SLUG" },
            EnteringCombatColour = { 1, 0.5, 0.5, 1 },
            ExitingCombatColour = { 0.5, 1, 0.5, 1 },
            HoldTime = 1.5,
        },
        CombatTimer = {
            Enabled = false,
            Layout = {"LEFT", "LEFT", 3, 0},
            Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
            Colour = { 1, 1, 1, 1 },
            OutOfCombatAlpha = 0.33,
        },
        CVars = {
            SyncCVars = false,
        },
        DamageMeter = {
            AutoResetOnMythicPlus = false,
            [1] = {
                Enabled = true,
                ShowBackdrop = true,
                Size = {227, 150},
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                BackgroundColour = {20/255, 20/255, 20/255, 1 },
                MeterType = Enum.DamageMeterType.DamageDone,
                SessionType = Enum.DamageMeterSessionType.Current,
                TitleBar = {
                    Enabled = true,
                    Height = 24,
                    Layout = {"LEFT", "LEFT", 3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    Icons = {
                        ResetButton = true,
                        EncountersButton = true,
                    }
                },
                Rows = {
                    Num = 5,
                    Spacing = 1,
                    Texture = "Blizzard Raid Bar",
                },
                Name = {
                    Layout = {"LEFT", "LEFT", 3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    ColourByClass = false,
                },
                Amount = {
                    Layout = {"RIGHT", "RIGHT", -3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    ColourByClass = false,
                }
            },
            [2] = {
                Enabled = true,
                ShowBackdrop = true,
                Size = {226, 150},
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -229, 1},
                BackgroundColour = {20/255, 20/255, 20/255, 1 },
                MeterType = Enum.DamageMeterType.Interrupts,
                SessionType = Enum.DamageMeterSessionType.Current,
                TitleBar = {
                    Enabled = true,
                    Height = 24,
                    Layout = {"LEFT", "LEFT", 3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    Icons = {
                        ResetButton = true,
                        EncountersButton = true,
                    }
                },
                Rows = {
                    Num = 5,
                    Spacing = 1,
                    Texture = "Blizzard Raid Bar",
                },
                Name = {
                    Layout = {"LEFT", "LEFT", 3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    ColourByClass = false,
                },
                Amount = {
                    Layout = {"RIGHT", "RIGHT", -3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    ColourByClass = false,
                }
            },
            [3] = {
                Enabled = false,
                ShowBackdrop = true,
                Size = {454, 60},
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 177},
                BackgroundColour = {20/255, 20/255, 20/255, 1 },
                MeterType = Enum.DamageMeterType.Deaths,
                SessionType = Enum.DamageMeterSessionType.Current,
                TitleBar = {
                    Enabled = true,
                    Height = 24,
                    Layout = {"LEFT", "LEFT", 3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    Icons = {
                        ResetButton = true,
                        EncountersButton = true,
                    }
                },
                Rows = {
                    Num = 2,
                    Spacing = 1,
                    Texture = "Blizzard Raid Bar",
                },
                Name = {
                    Layout = {"LEFT", "LEFT", 3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    ColourByClass = false,
                },
                Amount = {
                    Layout = {"RIGHT", "RIGHT", -3, 0},
                    Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
                    Colour = { 1, 1, 1, 1 },
                    ColourByClass = false,
                }
            },
        },
        ElvUIEnhancements = {
            ForceAlphaOnLootRoll = false,
            ActionStatus = {
                Enabled = false,
                Layout = {"CENTER", "CENTER", 0, 75},
                Font = { "Friz Quadrata TT", 12, "OUTLINE, SLUG" },
            },
            UIErrorsFrame = {
                Enabled = false,
                Layout = {"CENTER", "CENTER", 0, 125},
            },
        },
        MouseCursor = {
            Enabled = false,
            ShowInCombatOnly = false,
            Layout = {"CENTER", "CENTER", 0, 0, 32, 32},
            Texture = "CURSOR_03",
            Colour = { 1, 1, 1, 1 },
        },
        QualityOfLife = {
            Toggles = {
                RemoveTalkingHead = false,
                SkipCinematics = false,
                AutoRepair = false,
                AutoSellGreys = false,
                AutoDelete = false,
                RemoveBossBanner = false,
                RemoveLossOfControlFrame = false,
                AutoSignUp = false,
                PositionRaidWarningFrame = false,
                MissingPersonalBuffs = false,
                MissingRaidBuffs = false,
            },
            Alerts = {
                BloodlustAlert = false,
                BloodlustAlertSound = "|cFF6080FFUnhalted|r: Buff",
                TimeSpiralAlert = false,
                TimeSpiralAlertSound = "|cFF6080FFUnhalted|r: Time Spiral",
                PowerInfusionAlert = false,
                PowerInfusionAlertSound = "|cFF6080FFUnhalted|r: PI",
            }
        },
        VendorHelper = {
            AutoVendor = false,
            MinimumQuality = 3,
            MinimumItemLevel = 266,
        }
    }
}

function Private:GetDefaults()
    return Defaults
end