local Private = select(2, ...)

local Defaults = {
    global = {
        AddOnSkins = {
            BugSack = {
                Enable = true,
                Layout = {"TOPRIGHT", "TOPRIGHT", -1.1, -1.1},
                Size = {18, 18},
            },
        },
        Alerts = {
            Combat = {
                Enable = true,
                Layout = {"CENTER", "CENTER", 0, 75.1},
                Text = {
                    FontSize = 15,
                    Enter = {
                        Text = "+Combat",
                        Colour = {204/255, 64/255, 64/255}
                    },
                    Exit = {
                        Text = "-Combat",
                        Colour = {64/255, 204/255, 64/255}
                    },
                },
                HoldTime = 1.5,
            },
            Innervate = {
                Enable = false,
                Layout = {"CENTER", "CENTER", 0.1, 203.1},
                Size = {38, 38},
                Sound = "None",
                SoundChannel = "Master",
            },
            PowerInfusion = {
                Enable = false,
                Layout = {"CENTER", "CENTER", 0.1, 125.1},
                Size = {38, 38},
                Sound = "None",
                SoundChannel = "Master",
            },
            TimeSpiral = {
                Enable = false,
                Layout = {"CENTER", "CENTER", 0.1, 164.1},
                Size = {38, 38},
                Sound = "None",
                SoundChannel = "Master",
            }
        },
        Blizzard = {
            CleanObjectiveTrackerBanner = true,
            UIErrorsFrame = {
                Enable = false,
                Hide = false,
                Layout = {"CENTER", "CENTER", 0, 125.1},
            }
        },
        DamageMeter = {
            [1] = {
                Enable = true,
                ShowBackdrop = true,
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1.1, 1.1},
                Size = {220, 153},
                MeterType = Enum.DamageMeterType.Dps,
                SessionType = Enum.DamageMeterSessionType.Current,
                Rows = 5,
                Texture = "Blizzard Raid Bar",
                TitleBar = {
                    Enable = true,
                    ShowBackdrop = true,
                    Height = 24,
                    XOffset = 0,
                    YOffset = 1,
                    Text = {
                        Enable = true,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        FontSize = 12,
                        Colour = {255/255, 255/255, 255/255}
                    }
                },
                Text = {
                    Name_FontSize = 12,
                    Name_XOffset = 3,
                    Name_YOffset = 0,
                    Name_ColourByClass = false,
                    Name_Colour = {255/255, 255/255, 255/255},
                    Amount_FontSize = 12,
                    Amount_XOffset = -3,
                    Amount_YOffset = 0,
                    Amount_ColourByClass = false,
                    Amount_Colour = {255/255, 255/255, 255/255},
                    Amount_Format = "%s • %s",
                },
            },
            [2] = {
                Enable = true,
                ShowBackdrop = true,
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -1.1, 180.1},
                Size = {220, 92},
                MeterType = Enum.DamageMeterType.HealingDone,
                SessionType = Enum.DamageMeterSessionType.Current,
                Rows = 3,
                Texture = "Blizzard Raid Bar",
                TitleBar = {
                    Enable = true,
                    ShowBackdrop = true,
                    Height = 24,
                    XOffset = 0,
                    YOffset = 1,
                    Text = {
                        Enable = true,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        FontSize = 12,
                        Colour = {255/255, 255/255, 255/255}
                    }
                },
                Text = {
                    Name_FontSize = 12,
                    Name_XOffset = 3,
                    Name_YOffset = 0,
                    Name_ColourByClass = false,
                    Name_Colour = {255/255, 255/255, 255/255},
                    Amount_FontSize = 12,
                    Amount_XOffset = -3,
                    Amount_YOffset = 0,
                    Amount_ColourByClass = false,
                    Amount_Colour = {255/255, 255/255, 255/255},
                    Amount_Format = "%s • %s",
                },
            },
            [3] = {
                Enable = false,
                ShowBackdrop = true,
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -222.1, 1.1},
                Size = {220, 153},
                MeterType = Enum.DamageMeterType.Dps,
                SessionType = Enum.DamageMeterSessionType.Current,
                Rows = 5,
                Texture = "Blizzard Raid Bar",
                TitleBar = {
                    Enable = true,
                    ShowBackdrop = true,
                    Height = 24,
                    XOffset = 0,
                    YOffset = 1,
                    Text = {
                        Enable = true,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        FontSize = 12,
                        Colour = {255/255, 255/255, 255/255}
                    }
                },
                Text = {
                    Name_FontSize = 12,
                    Name_XOffset = 3,
                    Name_YOffset = 0,
                    Name_ColourByClass = false,
                    Name_Colour = {255/255, 255/255, 255/255},
                    Amount_FontSize = 12,
                    Amount_XOffset = -3,
                    Amount_YOffset = 0,
                    Amount_ColourByClass = false,
                    Amount_Colour = {255/255, 255/255, 255/255},
                    Amount_Format = "%s • %s",
                },
            },
            [4] = {
                Enable = false,
                ShowBackdrop = true,
                Layout = {"BOTTOMRIGHT", "BOTTOMRIGHT", -222.1, 180.1},
                Size = {220, 92},
                MeterType = Enum.DamageMeterType.Hps,
                SessionType = Enum.DamageMeterSessionType.Current,
                Rows = 3,
                Texture = "Blizzard Raid Bar",
                TitleBar = {
                    Enable = true,
                    ShowBackdrop = true,
                    Height = 24,
                    XOffset = 0,
                    YOffset = 1,
                    Text = {
                        Enable = true,
                        Layout = {"LEFT", "LEFT", 3, 0},
                        FontSize = 12,
                        Colour = {255/255, 255/255, 255/255}
                    }
                },
                Text = {
                    Name_FontSize = 12,
                    Name_XOffset = 3,
                    Name_YOffset = 0,
                    Name_ColourByClass = false,
                    Name_Colour = {255/255, 255/255, 255/255},
                    Amount_FontSize = 12,
                    Amount_XOffset = -3,
                    Amount_YOffset = 0,
                    Amount_ColourByClass = false,
                    Amount_Colour = {255/255, 255/255, 255/255},
                    Amount_Format = "%s • %s",
                },
            }
        },
        ElvUI = {
            LootRollFix = true,
            InterruptOnCooldown = true,
            Movers = {
                ElvAB_1 = {
                    Enable = false,
                    Layout = {"CENTER", "ElvUIParent", "CENTER", 0, 0},
                },
                ElvAB_2 = {
                    Enable = false,
                    Layout = {"CENTER", "ElvUIParent", "CENTER", 0, 0},
                },
                ElvAB_3 = {
                    Enable = false,
                    Layout = {"CENTER", "ElvUIParent", "CENTER", 0, 0},
                },
                ElvAB_4 = {
                    Enable = false,
                    Layout = {"CENTER", "ElvUIParent", "CENTER", 0, 0},
                },
                ElvAB_5 = {
                    Enable = false,
                    Layout = {"CENTER", "ElvUIParent", "CENTER", 0, 0},
                },
                ElvAB_6 = {
                    Enable = false,
                    Layout = {"CENTER", "ElvUIParent", "CENTER", 0, 0},
                },
                ElvUF_PlayerMover = {
                    Enable = false,
                    Layout = {"CENTER", "UIParent", "CENTER", -425.1, -275.1},
                },
                ElvUF_TargetMover = {
                    Enable = false,
                    Layout = {"CENTER", "UIParent", "CENTER", 425.1, -275.1},
                },
                ElvUF_TargetCastbarMover = {
                    Enable = false,
                    Layout = {"TOPLEFT", "ElvUF_Target", "BOTTOMLEFT", -0.1, -1.1},
                },
                ElvUF_PetMover = {
                    Enable = false,
                    Layout = {"TOPLEFT", "ElvUF_Player", "BOTTOMLEFT", 0, -1.1},
                },
                ElvUF_FocusMover = {
                    Enable = false,
                    Layout = {"BOTTOMRIGHT", "UIParent", "TOPLEFT", -1.1, 1.1},
                },
            }
        },
        MinimapStats = {
            Time = {
                Enable = true,
                UpdateInterval = 30,
                Format = "24H",
                Layout = { "BOTTOMLEFT", "BOTTOMLEFT", 1, 16 },
                FontSize = 15,
                Colour = {255/255, 255/255, 255/255},
            },
            SystemStats = {
                Enable = true,
                UpdateInterval = 3,
                Format = "FPS_MS",
                Seperator = "•",
                Layout = { "BOTTOMLEFT", "BOTTOMLEFT", 3, 2 },
                FontSize = 12,
                Colour = {255/255, 255/255, 255/255},
            },
            Location = {
                Enable = true,
                Layout = { "TOPLEFT", "TOPLEFT", 3, -3 },
                FontSize = 12,
                ShowSubZone = true,
            },
            InstanceDifficulty = {
                Enable = true,
                Layout = { "TOPLEFT", "TOPLEFT", 3, -15 },
                FontSize = 12,
            }
        },
        Miscellaneous = {
            CombatTimer = {
                Enable = true,
                OOCOpacity = 0.33,
                Layout = {"LEFT", "LEFT", 3.1, 0.1},
                AnchorParent = "ElvUF_Player",
                Text = {
                    FontSize = 12,
                    Colour = {255/255, 255/255, 255/255},
                    Format = "00:00",
                },
            },
            CombatResurrection = {
                Enable = true,
                Layout = {"CENTER", "CENTER", 0.1, 0.1},
                AnchorParent = "ElvUF_Player",
                Text = {
                    FontSize = 12,
                    Colour = {255/255, 255/255, 255/255},
                    Format = "%s • %s",
                },
            },
            Crosshair = {
                Enable = false,
                Size = {16, 16},
                Layout = {"CENTER", "CENTER", 0, 0},
                Colour = {1, 1, 1, 1},
                Texture = "CROSSHAIR_02",
            },
            MouseCursor = {
                Enable = false,
                Size = {24, 24},
                Layout = {"CENTER", "CENTER", 0, 0},
                Colour = {1, 1, 1, 1},
                Texture = "CURSOR_01",
            },
        },
        MythicPlusTimer = {
            Enable = true,
            ShowBackdrop = true,
            ShowDeaths = true,
            ShowBosses = true,
            ShowForces = true,
            Layout = {"RIGHT", "RIGHT", 0, 0},
            Width = 300,
            RowHeight = 24,
            Texture = "Blizzard Raid Bar",
            TitleBar = {
                Enable = true,
                ShowBackdrop = true,
                Height = 24,
                XOffset = 0,
                YOffset = 1,
                Text = {
                    Enable = true,
                    Layout = {"LEFT", "LEFT", 3, 0},
                    FontSize = 12,
                    Colour = {1, 1, 1},
                },
            },
            Text = {
                Name_FontSize = 12,
                Name_XOffset = 3,
                Name_YOffset = 0,
                Name_Colour = {1, 1, 1},
                Amount_FontSize = 12,
                Amount_XOffset = -3,
                Amount_YOffset = 0,
                Amount_Colour = {1, 1, 1},
            },
            Colours = {
                Progress = {96/255, 128/255, 255/255},
                Second = {64/255, 128/255, 255/255},
                Third = {128/255, 64/255, 204/255},
                Complete = {64/255, 204/255, 64/255},
                Expired = {204/255, 64/255, 64/255},
            },
        },
        Toggles = {
            AutoDelete = true,
            AutoSignUp = true,
            HideBossBanner = true,
            HideLossOfControl = true,
            HideTalkingHead = true,
            SkipCinematics = true,
        }
    }
}

function Private:GetDefaults()
    return Defaults
end
