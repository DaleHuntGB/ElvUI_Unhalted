local Private = select(2, ...)

function Private:SetupAutoSignUp()
	local AcceptButton = _G.LFDRoleCheckPopupAcceptButton
	if AcceptButton then AcceptButton:HookScript("OnShow", function(acceptButton) if not Private.DB.global.QualityOfLife.Toggles.AutoSignUp then return end if not IsShiftKeyDown() then acceptButton:Click() end end) end

	local ApplicationDialog = _G.LFGListApplicationDialog
	if ApplicationDialog then ApplicationDialog:HookScript("OnShow", function(acceptButton) if not Private.DB.global.QualityOfLife.Toggles.AutoSignUp then return end if not IsShiftKeyDown() then acceptButton.SignUpButton:Click() end end) end
end