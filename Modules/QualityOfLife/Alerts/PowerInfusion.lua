local Private = select(2, ...)

function Private:SetupPowerInfusionAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.PowerInfusion

    if not Private.PowerInfusionAlertContainer then
        local AuraContainerAnchor = CreateFrame("Frame", nil, UIParent)
        AuraContainerAnchor:SetSize(DB.Size[1], DB.Size[2])
        AuraContainerAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

        Private.PowerInfusionAlertAnchor = AuraContainerAnchor

        local AuraContainer = CreateFrame("AuraContainer", "ElvUI_Unhalted_PowerInfusionAlertContainer", AuraContainerAnchor, "CustomAuraContainerTemplate")
        AuraContainer:SetSize(DB.Size[1], DB.Size[2])
        AuraContainer:SetPoint("CENTER", AuraContainerAnchor, "CENTER", 0, 0)
        AuraContainer:AddAuraSlot("PowerInfusionAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [10060] = true } },
            initializeFrame = function(Aura)
                Aura:EnableMouseMotion(false)
                Aura:SetAllPoints(AuraContainerAnchor)

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
                Private.ElvUI:RegisterCooldown(Cooldown)
                Cooldown:SetDrawEdge(false)
                Aura:SetDurationCooldown(Cooldown)
            end,
        })

        AuraContainer:SetUnit("player")

        Private.PowerInfusionAlertContainer = AuraContainer
    end

    Private:UpdatePowerInfusionAlert()
end

function Private:UpdatePowerInfusionAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.PowerInfusion

    if Private.PowerInfusionAlertAnchor then
        Private.PowerInfusionAlertAnchor:ClearAllPoints()
        Private.PowerInfusionAlertAnchor:SetSize(DB.Size[1], DB.Size[2])
        Private.PowerInfusionAlertAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    if Private.PowerInfusionAlertContainer then Private.PowerInfusionAlertContainer:SetSize(DB.Size[1], DB.Size[2]) end

    if Private.PowerInfusionAlertSound then
        C_UnitAuras.RemoveAuraSound(Private.PowerInfusionAlertSound)
        Private.PowerInfusionAlertSound = nil
    end

    if DB.Enable then
        Private.PowerInfusionAlertSound = C_UnitAuras.AddAuraSound(
            Enum.UnitAuraSoundTrigger.Added, {
                unitToken = "player",
                spellID = 10060,
                soundFileName = Private:FetchSound(DB.Sound),
                outputChannel = DB.SoundChannel,
            }
        )
    end

    if Private.PowerInfusionAlertContainer then
        Private.PowerInfusionAlertContainer:SetEnabled(DB.Enable)
        Private.PowerInfusionAlertContainer:SetShown(DB.Enable)
    end

    Private:UpdatePreviewAlerts()
end