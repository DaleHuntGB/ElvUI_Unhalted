local Private = select(2, ...)

function Private:SetupQualityOfLife()
    Private:SetupAutoDelete()
    Private:SetupAutoQuest()
    Private:SetupAutoRepair()
    Private:SetupAutoSellGreys()
    Private:SetupAutoSignUp()
    Private:SetupBloodlustAlert()
    Private:SetupExternalsAlert()
    Private:SetupInnervateAlert()
    Private:SetupKeystoneRerollReminder()
    Private:SetupPowerInfusionAlert()
    Private:SetupRemoveBossBanner()
    Private:SetupRemoveTalkingHead()
    Private:SetupSkipCinematics()
    Private:SetupTimeSpiralAlert()
end

