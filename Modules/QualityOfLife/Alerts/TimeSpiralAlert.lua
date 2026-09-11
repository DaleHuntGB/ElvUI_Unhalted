local Private = select(2, ...)

function Private:SetupTimeSpiralAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.TimeSpiralAlert

    if not DB then if Private.TimeSpiralAlertContainer then Private.TimeSpiralAlertContainer:Hide() end return end

    if not Private.TimeSpiralAlertContainer then
        local AC = CreateFrame("AuraContainer", "TimeSpiralAlertContainer", UIParent, "CustomAuraContainerTemplate")
        AC:SetSize(48, 48)
        AC:SetPoint("CENTER", UIParent, "CENTER", 0, 125)
        AC:AddAuraSlot("TimeSpiralAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [375234] = true } },
            initializeFrame = function(Aura)
                Aura:SetSize(48, 48)
                Aura:EnableMouseMotion(false)
                Aura:SetPoint("CENTER", AC, "CENTER", 0, 0)

                local Border = Aura:CreateTexture(nil, "BACKGROUND")
                Border:SetAllPoints(Aura)
                Border:SetColorTexture(0, 0, 0, 1)

                local Icon = Aura:CreateTexture(nil, "ARTWORK")
                Icon:SetPoint("TOPLEFT", Aura, "TOPLEFT", 1, -1)
                Icon:SetPoint("BOTTOMRIGHT", Aura, "BOTTOMRIGHT", -1, 1)
                Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
                Aura:SetIcon(Icon)

                local Cooldown = CreateFrame("Cooldown", nil, Aura, "CooldownFrameTemplate")
                Cooldown:SetAllPoints(Icon)
                Cooldown:SetDrawSwipe(true)
                Cooldown:SetReverse(true)
                Cooldown:SetHideCountdownNumbers(false)
                Cooldown:SetDrawEdge(false)
                Aura:SetDurationCooldown(Cooldown)

                Private.E:RegisterCooldown(Cooldown)
            end,
        })
        AC:SetUnit("player")
        Private.TimeSpiralAlertContainer = AC

        if not Private.TimeSpiralAlertSound then
            Private.TimeSpiralAlertSound = C_UnitAuras.AddAuraSound(
                Enum.UnitAuraSoundTrigger.Added, {
                    unitToken = "player",
                    spellID = 375234,
                    soundFileName = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Sounds\\TimeSpiral.mp3",
                    outputChannel = "Master",
                }
            )
        end
    end

    Private.TimeSpiralAlertContainer:Show()
    Private.TimeSpiralAlertContainer:UpdateAllAuras()
end
