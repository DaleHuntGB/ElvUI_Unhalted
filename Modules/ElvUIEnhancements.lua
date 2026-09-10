local Private = select(2, ...)
local isFiltered = false
local M = Private.E:GetModule("Misc")

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