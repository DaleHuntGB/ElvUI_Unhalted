local Private = select(2, ...)
local isFiltered = false

local function FilterMessages()
	if isFiltered then return end
	UIErrorsFrameAddMessage = UIErrorsFrame.AddMessage
	UIErrorsFrame.AddMessage = function(Frame, Message, ...)
		if not (issecretvalue and issecretvalue(Message)) and Private.FilteredMessages[Message] then return end
		return UIErrorsFrameAddMessage(Frame, Message, ...)
	end
	isFiltered = true
end

function Private:UpdateBlizzardEnhancements()
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
