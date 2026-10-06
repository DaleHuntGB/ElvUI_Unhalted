local Private = select(2, ...)

local Defaults = {
    global = {
        AddOnSkins = {
            BugSack = {
                Enable = false,
                Layout = {"TOPRIGHT", "TOPRIGHT", -1.1, -1.1},
                Size = {18, 18},
            },
            BigWigs = {
                Enable = false,
                Layout = {"TOPRIGHT", "TOPRIGHT", -58.1, -1.1},
                Size = {18, 18},
            },
            AddOnProfiler = {
                Enable = false,
                Layout = {"TOPRIGHT", "TOPRIGHT", -20.1, -1.1},
                Size = {18, 18},
            },
            Miscellaneous = {
                LSToasts = false,
                Baganator = false,
            },
            SkironCooldownManager = {
                Enable = false,
                Layout = {"TOPRIGHT", "TOPRIGHT", -39.1, -1.1},
                Size = {18, 18},
            },
            SimulationCraft = {
                Enable = false,
                Layout = {"TOPRIGHT", "TOPRIGHT", -1.1, -20.1},
                Size = {18, 18},
            },
        },
        Blizzard = {
            ActionStatus = {
                Enable = false,
                Font = "Friz Quadrata TT",
                FontSize = 12,
                FontFlag = "OUTLINE, SLUG",
                Layout = {"CENTER", "CENTER", 0, 35.1},
            },
            UIErrorsFrame = {
                Enable = false,
                Font = "Friz Quadrata TT",
                FontSize = 12,
                FontFlag = "OUTLINE, SLUG",
                Layout = {"CENTER", "CENTER", 0, 125.1},
            },
            ZoneText = {
                Enable = false,
                Layout = {"TOP", "TOP", 0, -125.1},
                Font = "Friz Quadrata TT",
                FontSize = 15,
                FontFlag = "OUTLINE, SLUG",
            },
            SubZoneText = {
                Enable = false,
                Layout = {"TOP", "BOTTOM", 0, -3.1},
                Font = "Friz Quadrata TT",
                FontSize = 12,
                FontFlag = "OUTLINE, SLUG",
            }
        },
        ElvUIEnhancements = {
            ForceAlphaOnLootRoll = false,
            CastbarInterruptCooldown = false,
            OverAbsorbs = false,
            LFGHelper = false,
        },
        CombatAlert = {
            Enable = false,
            Layout = {"CENTER", "CENTER", 0, 25.1},
            Text = {
                Font = "Friz Quadrata TT",
                FontSize = 15,
                FontFlag = "OUTLINE, SLUG",
                EnteringCombat = {
                    Text = "+Combat",
                    Colour = {204/255, 64/255, 64/255}
                },
                ExitingCombat = {
                    Text = "-Combat",
                    Colour = {64/255, 204/255, 64/255}
                },
            },
            HoldTime = 1.5,
        },
        CombatTimer = {
            Enable = false,
            Layout = {"LEFT", "LEFT", 3.1, 0.1},
            AnchorParent = "ElvUF_Player",
            Text = {
                Font = "Friz Quadrata TT",
                FontSize = 12,
                FontFlag = "OUTLINE, SLUG",
                Colour = {255/255, 255/255, 255/255},
                Format = "00:00",
            },
            OOCOpacity = 0.33,
        },
        DamageMeter = {
            AutoResetOnMythicPlus = false,
            [1] = {
                Enable = false,
                ShowBackdrop = false,
                Size = {227, 150},
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
                BackgroundColour = {20/255, 20/255, 20/255, 1 },
                MeterType = Enum.DamageMeterType.DamageDone,
                SessionType = Enum.DamageMeterSessionType.Current,
                TitleBar = {
                    Enable = false,
                    ShowBackdrop = false,
                    MouseoverIcons = false,
                    Height = 24,
                    Layout = {"BOTTOM", "TOP", 0, 1},
                    Icons = {
                        ResetButton = false,
                        EncountersButton = false,
                    },
                    Text = {
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                    }
                },
                Rows = {
                    Num = 5,
                    Spacing = 1,
                    Texture = "Blizzard Raid Bar",
                    Name = {
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                        ColourByClass = false,
                    },
                    Amount = {
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                        ColourByClass = false,
                        Format = "%s • %s"
                    }
                },
            },
            [2] = {
                Enable = false,
                ShowBackdrop = false,
                Size = {226, 150},
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -229, 1},
                BackgroundColour = {20/255, 20/255, 20/255, 1 },
                MeterType = Enum.DamageMeterType.Interrupts,
                SessionType = Enum.DamageMeterSessionType.Current,
                TitleBar = {
                    Enable = false,
                    ShowBackdrop = false,
                    MouseoverIcons = false,
                    Height = 24,
                    Layout = {"BOTTOM", "TOP", 0, 1},
                    Icons = {
                        ResetButton = false,
                        EncountersButton = false,
                    },
                    Text = {
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                    }
                },
                Rows = {
                    Num = 5,
                    Spacing = 1,
                    Texture = "Blizzard Raid Bar",
                    Name = {
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                        ColourByClass = false,
                    },
                    Amount = {
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                        ColourByClass = false,
                        Format = "%s • %s"
                    }
                },
            },
            [3] = {
                Enable = false,
                ShowBackdrop = false,
                Size = {454, 60},
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1, 177},
                BackgroundColour = {20/255, 20/255, 20/255, 1 },
                MeterType = Enum.DamageMeterType.Deaths,
                SessionType = Enum.DamageMeterSessionType.Current,
                TitleBar = {
                    Enable = false,
                    ShowBackdrop = false,
                    MouseoverIcons = false,
                    Height = 24,
                    Layout = {"BOTTOM", "TOP", 0, 1},
                    Icons = {
                        ResetButton = false,
                        EncountersButton = false,
                    },
                    Text = {
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                    }
                },
                Rows = {
                    Num = 2,
                    Spacing = 1,
                    Texture = "Blizzard Raid Bar",
                    Name = {
                        Layout = {"LEFT", "LEFT", 3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                        ColourByClass = false,
                    },
                    Amount = {
                        Layout = {"RIGHT", "RIGHT", -3, 0},
                        Font = "Friz Quadrata TT",
                        FontSize = 12,
                        FontFlag = "OUTLINE, SLUG",
                        Colour = { 1, 1, 1, 1 },
                        ColourByClass = false,
                        Format = "%s • %s"
                    }
                },
            },
        },
        DungeonCasts = {
            Enable = false,
            Layout = {"CENTER", "CENTER", 0, 0 },
            GrowthDirection = "DOWN",
            BackgroundColour = {20/255, 20/255, 20/255, 1},
            InterruptibleColour = {96/255, 128/255, 255/255, 1},
            NonInterruptibleColour = {204/255, 64/255, 64/255, 1},
            InterruptOnCooldownColour = {128/255, 128/255, 128/255, 1},
            Spacing = 1,
            Num = 5,
            Size = {250, 28},
            Font = "Friz Quadrata TT",
            FontSize = 12,
            FontFlag = "OUTLINE, SLUG",
            Texture = "Blizzard Raid Bar",
        },
        MouseCursor = {
            Enable = false,
            Layout = {"CENTER", "TOPLEFT", 0, 0},
            Texture = "CURSOR_01",
            Colour = {255/255, 255/255, 255/255},
            Size = {24, 24},
        },
        QualityOfLife = {
            Alerts = {
                Bloodlust = {
                    Enable = false,
                    Layout = {"CENTER", "CENTER", -75.1, 35.1},
                    Size = {42, 42},
                    Sound = "None",
                    SoundChannel = "Master",
                },
                Externals = {
                    Enable = false,
                    Layout = {"CENTER", "CENTER", -175.1, 0.1, 1, "LEFT"},
                    Size = {48, 48},
                    Sound = "None",
                    SoundChannel = "Master",
                },
                Innervate = {
                    Enable = false,
                    Layout = {"CENTER", "CENTER", -125.1, 125.1},
                    Size = {42, 42},
                    Sound = "None",
                    SoundChannel = "Master",
                },
                PowerInfusion = {
                    Enable = false,
                    Layout = {"CENTER", "CENTER", 125.1, 125.1},
                    Size = {42, 42},
                    Sound = "None",
                    SoundChannel = "Master",
                },
                TimeSpiral = {
                    Enable = false,
                    Layout = {"CENTER", "CENTER", 0.1, 125.1},
                    Size = {42, 42},
                    Sound = "None",
                    SoundChannel = "Master",
                },
            },
            Toggles = {
                AutoDelete = false,
                AutoQuest = false,
                AutoRepair = false,
                AutoSellGreys = false,
                AutoSignUp = false,
                KeystoneReroll = false,
                RemoveBossBanner = false,
                RemoveTalkingHead = false,
                SkipCinematics = false,
            },
        },
        VendorSupport = {
            Enable = false,
            MinimumQuality = 3,
            MinimumItemLevel = 266,
        },
    },
}

function Private:GetDefaults()
    return Defaults
end
