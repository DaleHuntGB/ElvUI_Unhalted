local Private = select(2, ...)
local UF = Private.E:GetModule("UnitFrames")
local OverAbsorbBars = {}
local OverAbsorbsHooked = false

local function UpdateOverAbsorb(Prediction)
	local Bar = OverAbsorbBars[Prediction]
	local DB = Prediction.frame.db and Prediction.frame.db.healPrediction
	local Absorb = Prediction.damageAbsorb
	if not Private.DB.global.ElvUIEnhancements.OverAbsorbs or not DB or not DB.enable or DB.absorbStyle == "NONE" or DB.absorbStyle == "REVERSED" or not Prediction.values or not Absorb:IsShown() then
		Bar.Clip:Hide()
		return
	end

	local Values = Prediction.values
	Bar:SetMinMaxValues(Absorb:GetMinMaxValues())
	Bar:SetValue(Values:GetTotalDamageAbsorbs())
	Bar:SetStatusBarColor(Absorb:GetStatusBarColor())

	-- Read the overflow flag without changing ElvUI's configured prediction behaviour.
	local ClampMode = Values:GetDamageAbsorbClampMode()
	Values:SetDamageAbsorbClampMode(Enum.UnitDamageAbsorbClampMode.MissingHealthWithoutIncomingHeals)
	local Clamped = select(2, Values:GetDamageAbsorbs())
	Values:SetDamageAbsorbClampMode(ClampMode)
	Bar.Clip:SetAlphaFromBoolean(Clamped, 1, 0)
	Bar.Clip:Show()
	Bar:Show()
end

local function ConfigureOverAbsorb(_, UnitFrame)
	local Prediction = UnitFrame.HealthPrediction
	if not Prediction then return end
	local Bar = OverAbsorbBars[Prediction]
	local DB = UnitFrame.db and UnitFrame.db.healPrediction
	if not Private.DB.global.ElvUIEnhancements.OverAbsorbs or not DB or not DB.enable or DB.absorbStyle == "NONE" or DB.absorbStyle == "REVERSED" then
		if Bar then Bar.Clip:Hide() end
		return
	end

	local Health = UnitFrame.Health
	local Absorb = Prediction.damageAbsorb
	if not Bar then
		local Clip = CreateFrame("Frame", nil, Absorb)
		Clip:EnableMouse(false)
		Clip:SetClipsChildren(true)
		Clip:Hide()
		Bar = CreateFrame("StatusBar", nil, Clip)
		Bar:EnableMouse(false)
		Bar.Clip = Clip
		OverAbsorbBars[Prediction] = Bar
		hooksecurefunc(Prediction, "PostUpdate", UpdateOverAbsorb)
	end

	local Orientation = Health:GetOrientation()
	local ReverseFill = Health:GetReverseFill()
	Bar.Clip:ClearAllPoints()
	Bar.Clip:SetAllPoints(Health:GetStatusBarTexture())
	Bar.Clip:SetFrameLevel(Absorb:GetFrameLevel() + 1)
	Bar:SetFrameLevel(Bar.Clip:GetFrameLevel() + 1)
	Bar:SetOrientation(Orientation)
	Bar:SetReverseFill(not ReverseFill)
	Bar:SetStatusBarTexture(Absorb:GetStatusBarTexture():GetTexture())
	Bar:ClearAllPoints()
	-- Absorb layout dimensions can be secret; use health anchors and configured thickness.
	if not DB.height or DB.height == -1 then
		Bar:SetAllPoints(Health)
	else
		local Anchor = Prediction.anchor == "CENTER" and "" or Prediction.anchor
		if Orientation == "HORIZONTAL" then
			Bar:SetPoint(Anchor .. "LEFT", Health, Anchor .. "LEFT")
			Bar:SetPoint(Anchor .. "RIGHT", Health, Anchor .. "RIGHT")
			Bar:SetHeight(math.min(DB.height, Health.HEIGHT))
		else
			Bar:SetPoint("TOP" .. Anchor, Health, "TOP" .. Anchor)
			Bar:SetPoint("BOTTOM" .. Anchor, Health, "BOTTOM" .. Anchor)
			Bar:SetWidth(math.min(DB.height, Health.WIDTH))
		end
	end
	if UnitFrame.__unit then Prediction:ForceUpdate() end
end

function Private:UpdateOverAbsorbs()
	if Private.DB.global.ElvUIEnhancements.OverAbsorbs and not OverAbsorbsHooked then
		hooksecurefunc(UF, "Configure_HealComm", ConfigureOverAbsorb)
		OverAbsorbsHooked = true
	end
	for _, UnitFrame in ipairs(Private.E.oUF.objects) do
		if UnitFrame.unitframeType then ConfigureOverAbsorb(nil, UnitFrame) end
	end
end
