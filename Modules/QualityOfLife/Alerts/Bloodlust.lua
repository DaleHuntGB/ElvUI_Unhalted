local Private = select(2, ...)

local BloodlustSpells = {
    [1] = 2825,     -- Bloodlust
    [2] = 32182,    -- Heroism
    [3] = 80353,    -- Time Warp
    [4] = 264667,   -- Primal Rage
    [5] = 390386,   -- Fury of the Aspects
    [6] = 466904,   -- Harrier's Cry
}

local BloodlustSounds = {}

function Private:SetupBloodlustAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.Bloodlust

    if not Private.BloodlustAlertContainer then
        local AuraContainerAnchor = CreateFrame("Frame", nil, UIParent)
        AuraContainerAnchor:SetSize(DB.Size[1], DB.Size[2])
        AuraContainerAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

        Private.BloodlustAlertAnchor = AuraContainerAnchor

        local AuraContainer = CreateFrame("AuraContainer", "ElvUI_Unhalted_BloodlustAlertContainer", AuraContainerAnchor, "CustomAuraContainerTemplate")
        AuraContainer:SetSize(DB.Size[1], DB.Size[2])
        AuraContainer:SetPoint("CENTER", AuraContainerAnchor, "CENTER", 0, 0)
        AuraContainer:AddAuraSlot("BloodlustAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [2825] = true, [32182] = true, [80353] = true, [264667] = true, [390386] = true, [466904] = true } },
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

        Private.BloodlustAlertContainer = AuraContainer
    end

    Private:UpdateBloodlustAlert()
end

function Private:UpdateBloodlustAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.Bloodlust

    if Private.BloodlustAlertAnchor then
        Private.BloodlustAlertAnchor:ClearAllPoints()
        Private.BloodlustAlertAnchor:SetSize(DB.Size[1], DB.Size[2])
        Private.BloodlustAlertAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    if Private.BloodlustAlertContainer then Private.BloodlustAlertContainer:SetSize(DB.Size[1], DB.Size[2]) end

    for SpellID, SoundID in pairs(BloodlustSounds) do
        C_UnitAuras.RemoveAuraSound(SoundID)
        BloodlustSounds[SpellID] = nil
    end

    if DB.Enable then
        for _, SpellID in ipairs(BloodlustSpells) do
            BloodlustSounds[SpellID] = C_UnitAuras.AddAuraSound(
                Enum.UnitAuraSoundTrigger.Added, {
                    unitToken = "player",
                    spellID = SpellID,
                    soundFileName = Private:FetchSound(DB.Sound),
                    outputChannel = DB.SoundChannel,
                }
            )
        end
    end

    if Private.BloodlustAlertContainer then
        Private.BloodlustAlertContainer:SetEnabled(DB.Enable)
        Private.BloodlustAlertContainer:SetShown(DB.Enable)
    end

    Private:UpdatePreviewAlerts()
end
