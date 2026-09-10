local Private = select(2, ...)

local function EasyDelete_OnShow(frame)
    if not Private.DB.global.QualityOfLife.Toggles.AutoDelete then return end
	frame.EditBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end

function Private:SetupAutoDelete()
    hooksecurefunc(StaticPopupDialogs.DELETE_GOOD_ITEM, 'OnShow', EasyDelete_OnShow)
	hooksecurefunc(StaticPopupDialogs.DELETE_GOOD_QUEST_ITEM, 'OnShow', EasyDelete_OnShow)
end