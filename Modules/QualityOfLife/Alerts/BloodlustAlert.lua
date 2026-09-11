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

    for _, SoundID in pairs(BloodlustSounds) do
        C_UnitAuras.RemoveAuraSound(SoundID)
    end
    wipe(BloodlustSounds)

    if not DB.BloodlustAlert or DB.BloodlustAlertSound == "None" then return end

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
