local Private = select(2, ...)

function Private:SetupAutoSignUp()
	if Private.isForever then return end
	_G["LFDRoleCheckPopupAcceptButton"]:HookScript("OnShow", function() if not Private.DB.global.Toggles.AutoSignUp then return end if not IsShiftKeyDown() then _G["LFDRoleCheckPopupAcceptButton"]:Click() end end)
	_G["LFGListApplicationDialog"]:HookScript("OnShow", function() if not Private.DB.global.Toggles.AutoSignUp then return end if not IsShiftKeyDown() then _G["LFGListApplicationDialog"].SignUpButton:Click() end end)
end