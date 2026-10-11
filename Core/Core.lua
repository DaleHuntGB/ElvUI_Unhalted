local Private = select(2, ...)
local AddOn = Private.AddOn

function AddOn:OnInitialize()
    Private.DB = LibStub("AceDB-3.0"):New("ElvUI_UnhaltedDB", Private:GetDefaults(), true)
    Private.AC:RegisterChatCommand("uhui", function() Private:CreateGUI() end)
    Private.AC:RegisterChatCommand("uh", function() Private:CreateGUI() end)
    Private.ElvUI.Libs.EP:RegisterPlugin("ElvUI_Unhalted", function() Private:SetupGUI() end)
end

function AddOn:OnEnable()
    Private:RegisterSharedMedia()
    Private:SetupAddOnSkins()
    Private:SetupBlizzard()
    Private:SetupElvUIEnhancements()
    Private:SetupCombatAlert()
    Private:SetupCombatTimer()
    Private:SetupDamageMeter()
    Private:SetupDungeonCasts()
    Private:SetupMouseCursor()
    Private:SetupQualityOfLife()
    Private:SetupVendorSupport()
end
