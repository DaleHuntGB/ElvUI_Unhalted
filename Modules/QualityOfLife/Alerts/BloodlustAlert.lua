local Private = select(2, ...)

local BloodlustSpells = {
    2825, -- Bloodlust
    32182, -- Heroism
    80353, -- Time Warp
    264667, -- Primal Rage
    390386, -- Fury of the Aspects
    466904, -- Harrier's Cry
}

local BloodlustSounds = {}

function Private:SetupBloodlustAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts

    for _, SoundID in pairs(BloodlustSounds) do C_UnitAuras.RemoveAuraSound(SoundID) end
    wipe(BloodlustSounds)

    if not DB.BloodlustAlert then
        if Private.BloodlustAlertTestMode then Private:SetAlertTestMode("BloodlustAlert", false) end
        if Private.BloodlustAlertContainer then Private.BloodlustAlertContainer:Hide() end
        Private:UpdateAlertGlows("BloodlustAlert")
        return
    end

    if not Private.BloodlustAlertContainer then
        local Anchor = CreateFrame("Frame", nil, UIParent)
        Anchor:SetSize(42, 42)
        Anchor:SetPoint("CENTER", UIParent, "CENTER", -125, 75)
        Private.BloodlustAlertAnchor = Anchor

        local AC = CreateFrame("AuraContainer", "BloodlustAlertContainer", Anchor, "CustomAuraContainerTemplate")
        AC:SetSize(42, 42)
        AC:SetPoint("CENTER", Anchor, "CENTER", 0, 0)
        AC:AddAuraSlot("BloodlustAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = { [2825] = true, [32182] = true, [80353] = true, [264667] = true, [390386] = true, [466904] = true } },
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
                Private:CreateAlertGlow("BloodlustAlert", Anchor, 42, Aura)
            end,
        })
        AC:SetUnit("player")
        Private.BloodlustAlertContainer = AC
    end

    if DB.BloodlustAlertSound ~= "None" then
        local Sound = Private.LSM:Fetch("sound", DB.BloodlustAlertSound)
        for _, SpellID in ipairs(BloodlustSpells) do
            BloodlustSounds[SpellID] = C_UnitAuras.AddAuraSound(
                Enum.UnitAuraSoundTrigger.Added, {
                    unitToken = "player",
                    spellID = SpellID,
                    soundFileName = Sound,
                    outputChannel = "Master",
                }
            )
        end
    end

    Private.BloodlustAlertContainer:Show()
    Private.BloodlustAlertContainer:UpdateAllAuras()
    Private:UpdateAlertGlows("BloodlustAlert")
    if Private.BloodlustAlertTestMode then Private:SetAlertTestMode("BloodlustAlert", true) end
end
