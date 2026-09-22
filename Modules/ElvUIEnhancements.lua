local Private = select(2, ...)
local isFiltered = false
local M = Private.E:GetModule("Misc")
local UF = Private.E:GetModule("UnitFrames")
local Castbars = {}
local InterruptSpellID
local InterruptReady = true
local InterruptSpells = {
	DEATHKNIGHT = { 47528 },
	DEMONHUNTER = { 183752 },
	DRUID = { 106839, 78675 },
	EVOKER = { 351338 },
	HUNTER = { 187707, 147362 },
	MAGE = { 2139 },
	MONK = { 116705 },
	PALADIN = { 96231, 31935 },
	PRIEST = { 15487 },
	ROGUE = { 1766 },
	SHAMAN = { 57994 },
	WARLOCK = { 19647, 132409, 89766, 119910, 1276467 },
	WARRIOR = { 6552 },
}

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

local function HookInterruptCastbar(_, UnitFrame)
	if not Private.DB.global.ElvUIEnhancements.CastbarInterruptCooldown then return end
	local Castbar = UnitFrame.Castbar
	if not Castbar then return end
	if not Castbars[Castbar] then
		Castbars[Castbar] = true
		hooksecurefunc(Castbar, "PostCastStart", ColourInterruptCooldown)
		hooksecurefunc(Castbar, "PostCastInterruptible", ColourInterruptCooldown)
	end
	if Castbar:IsShown() and (Castbar.casting or Castbar.channeling) then Castbar:PostCastInterruptible(UnitFrame.__unit) end
end

local function UpdateInterruptCooldown(_, Event, Unit)
	if Event == "UNIT_PET" and Unit ~= "player" then return end
	InterruptReady = true
	if Private.DB.global.ElvUIEnhancements.CastbarInterruptCooldown then
		if Event ~= "SPELL_UPDATE_COOLDOWN" then
			InterruptSpellID = nil
			local SpellIDs = InterruptSpells[Private.E.myclass]
			if SpellIDs then
				for _, SpellID in ipairs(SpellIDs) do
					if C_SpellBook.IsSpellKnown(SpellID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(SpellID, Enum.SpellBookSpellBank.Pet) then
						InterruptSpellID = SpellID
						break
					end
				end
			end
		end

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
	end

	for _, UnitFrame in ipairs(Private.E.oUF.objects) do
		if UnitFrame.unitframeType then HookInterruptCastbar(nil, UnitFrame) end
	end
	Private.InterruptCooldownFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	Private.InterruptCooldownFrame:RegisterEvent("SPELLS_CHANGED")
	Private.InterruptCooldownFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	Private.InterruptCooldownFrame:RegisterUnitEvent("UNIT_PET", "player")
	UpdateInterruptCooldown()
end

local function FilterMessages()
	if isFiltered then return end
	UIErrorsFrameAddMessage = UIErrorsFrame.AddMessage
	UIErrorsFrame.AddMessage = function(Frame, Message, ...)
		if not (issecretvalue and issecretvalue(Message)) and Private.FilteredMessages[Message] then return end
		return UIErrorsFrameAddMessage(Frame, Message, ...)
	end
	isFiltered = true
end

function Private:SetupElvUIEnhancements()
    local DB = Private.DB.global.ElvUIEnhancements
	local UIErrorsFrameDB = DB.UIErrorsFrame
	local ActionStatusDB = DB.ActionStatus

	UIErrorsFrame:ClearAllPoints()
	UIErrorsFrame:SetPoint(UIErrorsFrameDB.Layout[1], UIParent, UIErrorsFrameDB.Layout[2], UIErrorsFrameDB.Layout[3], UIErrorsFrameDB.Layout[4])
	UIErrorsFrame:SetShadowColor(0, 0, 0, 0)
	UIErrorsFrame:SetAlpha(UIErrorsFrameDB.Enabled and 1 or 0)

	FilterMessages()

    ActionStatus.Text:SetFont(Private.LSM:Fetch("font", ActionStatusDB.Font), ActionStatusDB.Font[2], ActionStatusDB.Font[3])
	ActionStatus.Text:ClearAllPoints()
	ActionStatus.Text:SetPoint(ActionStatusDB.Layout[1], UIParent, ActionStatusDB.Layout[2], ActionStatusDB.Layout[3], ActionStatusDB.Layout[4])
	ActionStatus.Text:SetShadowColor(0, 0, 0, 0)
	ActionStatus.Text:SetAlpha(ActionStatusDB.Enabled and 1 or 0)

	if DB.ForceAlphaOnLootRoll then
		hooksecurefunc(M, "START_LOOT_ROLL", function(_, _, rollID)
			for _, bar in next, M.RollBars do
				if bar.rollID == rollID then
					local r, g, b = unpack(Private.E.media.backdropfadecolor)
					bar.status.backdrop:SetBackdropColor(r, g, b, 1)
					break
				end
			end
		end)
	end

	Private:UpdateCastbarInterruptCooldown()
end

function Private:UpdateElvUIEnhancements()
    local DB = Private.DB.global.ElvUIEnhancements
	local UIErrorsFrameDB = DB.UIErrorsFrame
	local ActionStatusDB = DB.ActionStatus

	UIErrorsFrame:ClearAllPoints()
	UIErrorsFrame:SetPoint(UIErrorsFrameDB.Layout[1], UIParent, UIErrorsFrameDB.Layout[2], UIErrorsFrameDB.Layout[3], UIErrorsFrameDB.Layout[4])
	UIErrorsFrame:SetShadowColor(0, 0, 0, 0)
	UIErrorsFrame:SetAlpha(UIErrorsFrameDB.Enabled and 1 or 0)

	FilterMessages()

    ActionStatus.Text:SetFont(Private.LSM:Fetch("font", ActionStatusDB.Font), ActionStatusDB.Font[2], ActionStatusDB.Font[3])
	ActionStatus.Text:ClearAllPoints()
	ActionStatus.Text:SetPoint(ActionStatusDB.Layout[1], UIParent, ActionStatusDB.Layout[2], ActionStatusDB.Layout[3], ActionStatusDB.Layout[4])
	ActionStatus.Text:SetShadowColor(0, 0, 0, 0)
	ActionStatus.Text:SetAlpha(ActionStatusDB.Enabled and 1 or 0)
end