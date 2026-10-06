local Private = select(2, ...)
local UF = Private.ElvUI:GetModule("UnitFrames")
local NP = Private.ElvUI:GetModule("NamePlates")
local Castbars = {}
local InterruptSpellID
local InterruptReady = false

local function ColourInterruptCooldown(Castbar, Unit)
    if not Private.DB.global.ElvUIEnhancements.CastbarInterruptCooldown or not UnitCanAttack("player", Unit) then return end
    local Texture = Castbar:GetStatusBarTexture()
    local R, G, B, A = Texture:GetVertexColor()
    Texture:SetVertexColor(
        C_CurveUtil.EvaluateColorValueFromBoolean(Castbar.notInterruptible, R, C_CurveUtil.EvaluateColorValueFromBoolean(InterruptReady, R, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Castbar.notInterruptible, G, C_CurveUtil.EvaluateColorValueFromBoolean(InterruptReady, G, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Castbar.notInterruptible, B, C_CurveUtil.EvaluateColorValueFromBoolean(InterruptReady, B, 128/255)),
        A
    )
end

local function HookInterruptCastbar(_, Frame)
    if not Private.DB.global.ElvUIEnhancements.CastbarInterruptCooldown then return end
    local Castbar = Frame.Castbar
    if not Castbar then return end
    if not Castbars[Castbar] then
        Castbars[Castbar] = true
        hooksecurefunc(Castbar, "PostCastStart", ColourInterruptCooldown)
        hooksecurefunc(Castbar, "PostCastInterruptible", ColourInterruptCooldown)
    end
    if Castbar:IsShown() and (Castbar.casting or Castbar.channeling) then Castbar:PostCastInterruptible(Frame.__unit) end
end

local function UpdateInterruptCooldown(_, Event, Unit)
    if Event == "UNIT_PET" and Unit ~= "player" then return end
    InterruptReady = false
    if Private.DB.global.ElvUIEnhancements.CastbarInterruptCooldown then
        if Event ~= "SPELL_UPDATE_COOLDOWN" then
            InterruptSpellID = nil
            local SpellIDs = Private.InterruptIDs[Private.ElvUI.myclass]
            if SpellIDs then
                for _, SpellID in ipairs(SpellIDs) do
                    if C_SpellBook.IsSpellKnown(SpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(SpellID, Enum.SpellBookSpellBank.Pet) then
                        InterruptSpellID = SpellID
                        break
                    end
                end
            end
        end

        InterruptReady = InterruptSpellID ~= nil
        local Duration = InterruptSpellID and C_Spell.GetSpellCooldownDuration(InterruptSpellID, true)
        if Duration then InterruptReady = Duration:IsZero() end
    end

    for Castbar in pairs(Castbars) do
        if Castbar:IsShown() and (Castbar.casting or Castbar.channeling) then
            Castbar:PostCastInterruptible(Castbar.__owner.__unit)
        end
    end
end

function Private:UpdateCastbarInterruptCooldown()
    if not Private.DB.global.ElvUIEnhancements.CastbarInterruptCooldown then
        if Private.InterruptCooldownFrame then Private.InterruptCooldownFrame:UnregisterAllEvents() end
        UpdateInterruptCooldown()
        return
    end

    if not Private.InterruptCooldownFrame then
        local Frame = CreateFrame("Frame")
        Frame:SetScript("OnEvent", UpdateInterruptCooldown)
        Private.InterruptCooldownFrame = Frame

        hooksecurefunc(UF, "Configure_Castbar", HookInterruptCastbar)
        hooksecurefunc(NP, "Update_Castbar", HookInterruptCastbar)
    end

    for _, UnitFrame in ipairs(Private.ElvUI.oUF.objects) do
        if UnitFrame.unitframeType then HookInterruptCastbar(nil, UnitFrame) end
    end
    if NP.Initialized then
        for Nameplate in pairs(NP.Plates) do HookInterruptCastbar(nil, Nameplate) end
    end
    Private.InterruptCooldownFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    Private.InterruptCooldownFrame:RegisterEvent("SPELLS_CHANGED")
    Private.InterruptCooldownFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    Private.InterruptCooldownFrame:RegisterUnitEvent("UNIT_PET", "player")
    UpdateInterruptCooldown()
end
