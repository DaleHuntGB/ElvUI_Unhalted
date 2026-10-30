local Private = select(2, ...)
local UF = Private.E:GetModule("UnitFrames")
local Castbars = {}
local InterruptSpellID;
local canInterrupt = false

local function ColourInterruptCooldown(Castbar, Unit)
    if not Private.DB.global.ElvUI.InterruptOnCooldown or not UnitCanAttack("player", Unit) then return end
    local Texture = Castbar:GetStatusBarTexture()
    local R, G, B, A = Texture:GetVertexColor()
    Texture:SetVertexColor(
        C_CurveUtil.EvaluateColorValueFromBoolean(Castbar.notInterruptible, R, C_CurveUtil.EvaluateColorValueFromBoolean(canInterrupt, R, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Castbar.notInterruptible, G, C_CurveUtil.EvaluateColorValueFromBoolean(canInterrupt, G, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Castbar.notInterruptible, B, C_CurveUtil.EvaluateColorValueFromBoolean(canInterrupt, B, 128/255)),
        A
    )
end

local function HookInterruptCastbar(_, Frame)
    if not Private.DB.global.ElvUI.InterruptOnCooldown then return end
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
    canInterrupt = false
    if Private.DB.global.ElvUI.InterruptOnCooldown then
        if Event ~= "SPELL_UPDATE_COOLDOWN" then
            InterruptSpellID = nil
            local SpellIDs = Private.InterruptIDs[Private.E.myclass]
            if SpellIDs then
                for _, SpellID in ipairs(SpellIDs) do
                    if C_SpellBook.IsSpellKnown(SpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(SpellID, Enum.SpellBookSpellBank.Pet) then
                        InterruptSpellID = SpellID
                        break
                    end
                end
            end
        end

        canInterrupt = InterruptSpellID ~= nil
        local Duration = InterruptSpellID and C_Spell.GetSpellCooldownDuration(InterruptSpellID)
        if Duration then canInterrupt = Duration:IsZero() end
    end

    for Castbar in pairs(Castbars) do
        if Castbar:IsShown() and (Castbar.casting or Castbar.channeling) then
            Castbar:PostCastInterruptible(Castbar.__owner.__unit)
        end
    end
end

function Private:SetupInterruptOnCooldown()
    if not Private.DB.global.ElvUI.InterruptOnCooldown then return end

    if not Private.IOCEF then
        local Frame = CreateFrame("Frame")
        Frame:SetScript("OnEvent", UpdateInterruptCooldown)
        Private.IOCEF = Frame
        hooksecurefunc(UF, "Configure_Castbar", HookInterruptCastbar)
    end

    for _, UnitFrame in ipairs(Private.E.oUF.objects) do if UnitFrame.unitframeType then HookInterruptCastbar(nil, UnitFrame) end end

    Private.IOCEF:RegisterEvent("PLAYER_ENTERING_WORLD")
    Private.IOCEF:RegisterEvent("SPELLS_CHANGED")
    Private.IOCEF:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    Private.IOCEF:RegisterUnitEvent("UNIT_PET", "player")

    UpdateInterruptCooldown()
end