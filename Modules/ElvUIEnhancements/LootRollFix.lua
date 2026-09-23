local Private = select(2, ...)
local M = Private.E:GetModule("Misc")

function Private:SetupLootRollFix()
	if not Private.DB.global.ElvUIEnhancements.ForceAlphaOnLootRoll then return end

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
