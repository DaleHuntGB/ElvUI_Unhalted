local Private = select(2, ...)
local AddOn = Private.AddOn

function AddOn:OnInitialize()
    Private.DB = LibStub("AceDB-3.0"):New("UHDB", Private:GetDefaults(), true)
end

function AddOn:OnEnable()
    -- [[ Core ]]
    Private:RegisterSharedMedia()
    Private:SetupGUI()
    -- [[ AddOnSkins ]]
    Private:SetupBigWigsSkin()
    Private:SetupBugSackSkin()
    -- [[ Alerts ]]
    Private:SetupCombatAlert()
    Private:SetupInnervateAlert()
    Private:SetupPowerInfusionAlert()
    Private:SetupTimeSpiralAlert()
    -- [[ Blizzard ]]
    Private:SetupObjectiveTrackerBanner()
    Private:SetupUIErrorsFrame()
    -- [[ Damage Meter ]]
    Private:SetupDamageMeters()
    -- [[ ElvUI]]
    Private:SetupEnhancedMovers()
    Private:SetupInterruptOnCooldown()
    Private:SetupLootRollFix()
    -- [[ Minimap Stats ]]
    Private:SetupInstanceDifficulty()
    Private:SetupLocation()
    Private:SetupSystemStats()
    Private:SetupTime()
    -- [[ Miscellaneous ]]
    Private:SetupCrosshair()
    Private:SetupMouseCursor()
    -- [[ Mythic+ Timer ]]
    Private:SetupMythicPlusTimer()
    -- [[ Toggles ]]
    Private:SetupAutoDelete()
    Private:SetupAutoSignUp()
    Private:SetupBossBanner()
    Private:SetupLossOfControl()
    Private:SetupTalkingHead()
    Private:SkipCinematics()
end
