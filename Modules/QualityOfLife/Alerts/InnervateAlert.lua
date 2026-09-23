local Private = select(2, ...)

function Private:SetupInnervateAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts

    if Private.InnervateAlertSound then
        C_UnitAuras.RemoveAuraSound(Private.InnervateAlertSound)
        Private.InnervateAlertSound = nil
    end

    if not DB.InnervateAlert then
        if Private.InnervateAlertTestMode then Private:SetAlertTestMode("InnervateAlert", false) end
        if Private.InnervateAlertContainer then Private.InnervateAlertContainer:Hide() end
        return
    end

    if not Private.InnervateAlertContainer then
        local Anchor = CreateFrame("Frame", nil, UIParent)
        Anchor:SetSize(42, 42)
        Anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 75)
        Private.InnervateAlertAnchor = Anchor

        local AC = CreateFrame("AuraContainer", "InnervateAlertContainer", Anchor, "CustomAuraContainerTemplate")
        AC:SetSize(42, 42)
        AC:SetPoint("CENTER", Anchor, "CENTER", 0, 0)
        AC:AddAuraSlot("InnervateAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [29166] = true } },
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
        Private.InnervateAlertContainer = AC
    end

    if DB.InnervateAlertSound ~= "None" then
        local Sound = Private.LSM:Fetch("sound", DB.InnervateAlertSound)
        Private.InnervateAlertSound = C_UnitAuras.AddAuraSound(
            Enum.UnitAuraSoundTrigger.Added, {
                unitToken = "player",
                spellID = 29166,
                soundFileName = Sound,
                outputChannel = "Master",
            }
        )
    end

    Private.InnervateAlertContainer:Show()
    Private.InnervateAlertContainer:UpdateAllAuras()
    if Private.InnervateAlertTestMode then Private:SetAlertTestMode("InnervateAlert", true) end
end
