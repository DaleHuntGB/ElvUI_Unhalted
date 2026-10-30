local Private = select(2, ...)
local isFiltered = false

local FilteredMessages = {
    ["There is nothing to attack."] = true,
    ["A more powerful spell is already active"] = true,
    ["Item is not ready yet."] = true,
    ["You can't do that right now."] = true,
    ["Invalid target"] = true,
    ["Your level is now restricted to 60."] = true,
    ["Can't do that while moving"] = true,
    ["You cannot attack that target."] = true,
}

local function FilterMessages()
	if isFiltered then return end
	UIErrorsFrameAddMessage = UIErrorsFrame.AddMessage
	UIErrorsFrame.AddMessage = function(Frame, Message, ...)
		if not (issecretvalue and issecretvalue(Message)) and FilteredMessages[Message] then return end
		return UIErrorsFrameAddMessage(Frame, Message, ...)
	end
	isFiltered = true
end

function Private:SetupUIErrorsFrame()
    local DB = Private.DB.global.Blizzard.UIErrorsFrame
    local UEF = _G["UIErrorsFrame"]

    if UEF and DB.Enable then
        UEF:ClearAllPoints()
        UEF:SetPoint(DB.Layout[1], _G["ElvUIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        UEF:SetShadowColor(0, 0, 0, 0)
        UEF:SetShadowOffset(0, 0)
        UEF:SetAlpha(DB.Hide and 0 or 1)
        FilterMessages()
    end

end

function Private:UpdateUIErrorsFrame()
    local DB = Private.DB.global.Blizzard.UIErrorsFrame
    local UEF = _G["UIErrorsFrame"]

    if UEF and DB.Enable then
        UEF:ClearAllPoints()
        UEF:SetPoint(DB.Layout[1], _G["ElvUIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        UEF:SetShadowColor(0, 0, 0, 0)
        UEF:SetShadowOffset(0, 0)
        UEF:SetAlpha(DB.Hide and 0 or 1)

        UEF:AddMessage(C_AddOns.GetAddOnMetadata("ElvUI_Unhalted", "Title") .. ": " .. "Sample Text...", 1, 1, 1)
    end

end