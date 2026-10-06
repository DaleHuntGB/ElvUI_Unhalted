local Private = select(2, ...)

function Private:SetupInnervateAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.Innervate

    if not Private.InnervateAlertContainer then
        local AuraContainerAnchor = CreateFrame("Frame", nil, UIParent)
        AuraContainerAnchor:SetSize(DB.Size[1], DB.Size[2])
        AuraContainerAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

        Private.InnervateAlertAnchor = AuraContainerAnchor

        local AuraContainer = CreateFrame("AuraContainer", "ElvUI_Unhalted_InnervateAlertContainer", AuraContainerAnchor, "CustomAuraContainerTemplate")
        AuraContainer:SetSize(DB.Size[1], DB.Size[2])
        AuraContainer:SetPoint("CENTER", AuraContainerAnchor, "CENTER", 0, 0)
        AuraContainer:AddAuraSlot("InnervateAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [29166] = true } },
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

        Private.InnervateAlertContainer = AuraContainer
    end

    Private:UpdateInnervateAlert()
end

function Private:UpdateInnervateAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.Innervate

    if Private.InnervateAlertAnchor then
        Private.InnervateAlertAnchor:ClearAllPoints()
        Private.InnervateAlertAnchor:SetSize(DB.Size[1], DB.Size[2])
        Private.InnervateAlertAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    if Private.InnervateAlertContainer then Private.InnervateAlertContainer:SetSize(DB.Size[1], DB.Size[2]) end

    if Private.InnervateAlertSound then
        C_UnitAuras.RemoveAuraSound(Private.InnervateAlertSound)
        Private.InnervateAlertSound = nil
    end

    if DB.Enable then
        Private.InnervateAlertSound = C_UnitAuras.AddAuraSound(
            Enum.UnitAuraSoundTrigger.Added, {
                unitToken = "player",
                spellID = 29166,
                soundFileName = Private:FetchSound(DB.Sound),
                outputChannel = DB.SoundChannel,
            }
        )
    end

    if Private.InnervateAlertContainer then
        Private.InnervateAlertContainer:SetEnabled(DB.Enable)
        Private.InnervateAlertContainer:SetShown(DB.Enable)
    end

    Private:UpdatePreviewAlerts()
end