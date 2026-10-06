local Private = select(2, ...)

function Private:SetupTimeSpiralAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.TimeSpiral

    if not Private.TimeSpiralAlertContainer then
        local AuraContainerAnchor = CreateFrame("Frame", nil, UIParent)
        AuraContainerAnchor:SetSize(DB.Size[1], DB.Size[2])
        AuraContainerAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

        Private.TimeSpiralAlertAnchor = AuraContainerAnchor

        local AuraContainer = CreateFrame("AuraContainer", "ElvUI_Unhalted_TimeSpiralAlertContainer", AuraContainerAnchor, "CustomAuraContainerTemplate")
        AuraContainer:SetSize(DB.Size[1], DB.Size[2])
        AuraContainer:SetPoint("CENTER", AuraContainerAnchor, "CENTER", 0, 0)
        AuraContainer:AddAuraSlot("TimeSpiralAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [375234] = true } },
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

        Private.TimeSpiralAlertContainer = AuraContainer
    end

    Private:UpdateTimeSpiralAlert()
end

function Private:UpdateTimeSpiralAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.TimeSpiral

    if Private.TimeSpiralAlertAnchor then
        Private.TimeSpiralAlertAnchor:ClearAllPoints()
        Private.TimeSpiralAlertAnchor:SetSize(DB.Size[1], DB.Size[2])
        Private.TimeSpiralAlertAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    if Private.TimeSpiralAlertContainer then Private.TimeSpiralAlertContainer:SetSize(DB.Size[1], DB.Size[2]) end

    if Private.TimeSpiralAlertSound then
        C_UnitAuras.RemoveAuraSound(Private.TimeSpiralAlertSound)
        Private.TimeSpiralAlertSound = nil
    end

    if DB.Enable then
        Private.TimeSpiralAlertSound = C_UnitAuras.AddAuraSound(
            Enum.UnitAuraSoundTrigger.Added, {
                unitToken = "player",
                spellID = 375234,
                soundFileName = Private:FetchSound(DB.Sound),
                outputChannel = DB.SoundChannel,
            }
        )
    end

    if Private.TimeSpiralAlertContainer then
        Private.TimeSpiralAlertContainer:SetEnabled(DB.Enable)
        Private.TimeSpiralAlertContainer:SetShown(DB.Enable)
    end

    Private:UpdatePreviewAlerts()
end