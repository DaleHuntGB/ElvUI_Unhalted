local Private = select(2, ...)
local AddOn = Private.AddOn

function AddOn:OnInitialize()
    Private.DB = LibStub("AceDB-3.0"):New("UnhaltedUIDB", Private:GetDefaults(), true)
end

function AddOn:OnEnable()
    Private:CreateGUI()
    Private:SetupAutoDelete()
    Private:SetupAutoSellGreys()
    Private:SetupCombatAlert()
    Private:SetupCombatTimer()
    Private:SetupCVars()
    Private:SetupDamageMeter()
    Private:SetupElvUIEnhancements()
    Private:SetupLSToasts()
    Private:SetupRemoveTalkingHead()
    Private:SetupSkipCinematics()
end