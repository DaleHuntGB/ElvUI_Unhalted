local Private = select(2, ...)

function Private:SetupPowerInfusionAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts

    if Private.PowerInfusionAlertSound then
        C_UnitAuras.RemoveAuraSound(Private.PowerInfusionAlertSound)
        Private.PowerInfusionAlertSound = nil
    end

    if not DB.PowerInfusionAlert then if Private.PowerInfusionAlertContainer then Private.PowerInfusionAlertContainer:Hide() end return end

    if not Private.PowerInfusionAlertContainer then
        local AC = CreateFrame("AuraContainer", "PowerInfusionAlertContainer", UIParent, "CustomAuraContainerTemplate")
        AC:SetSize(42, 42)
        AC:SetPoint("CENTER", UIParent, "CENTER", 125, 75)
        AC:AddAuraSlot("PowerInfusionAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [10060] = true } },
            initializeFrame = function(Aura)
                Aura:SetSize(42, 42)
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
        Private.PowerInfusionAlertContainer = AC
    end

    if DB.PowerInfusionAlertSound ~= "None" then
        local Sound = Private.LSM:Fetch("sound", DB.PowerInfusionAlertSound)
        Private.PowerInfusionAlertSound = C_UnitAuras.AddAuraSound(
            Enum.UnitAuraSoundTrigger.Added, {
                unitToken = "player",
                spellID = 10060,
                soundFileName = Sound,
                outputChannel = "Master",
            }
        )
    end

    Private.PowerInfusionAlertContainer:Show()
    Private.PowerInfusionAlertContainer:UpdateAllAuras()
end
