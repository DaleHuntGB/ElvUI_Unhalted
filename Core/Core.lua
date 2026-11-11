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
    -- [[ Blizzard ]]
    Private:SetupObjectiveTrackerBanner()
    Private:SetupUIErrorsFrame()
    -- [[ Damage Meter ]]
    Private:SetupDamageMeters()
    -- [[ ElvUI]]
    Private:SetupEnhancedMovers()
    Private:SetupInterruptOnCooldown()
    Private:SetupLootRollFix()
    Private:SetupRemoveFogOfWar()
    -- [[ Minimap Stats ]]
    Private:SetupInstanceDifficulty()
    Private:SetupLocation()
    Private:SetupSystemStats()
    Private:SetupTime()
    -- [[ Miscellaneous ]]
    Private:SetupCombatResurrection()
    Private:SetupCombatTimer()
    Private:SetupCrosshair()
    Private:SyncCVars()
    Private:SetupMouseCursor()
    -- [[ Toggles ]]
    Private:SetupAutoDelete()
    Private:SetupAutoQuest()
    Private:SetupLossOfControl()
    Private:SkipCinematics()

    if Private.isForever then
        -- [[ Forever ]]
        Private:SetupAmmoCounter()
        Private:SetupAutoPurchase()
        Private:SetupBeastLore()
        Private:SetupDungeonJournal()
        Private:SetupWorldMapZoneLevels()
    else
        -- [[ Retail ]]
        Private:SetupInnervateAlert()
        Private:SetupPowerInfusionAlert()
        Private:SetupTimeSpiralAlert()
        Private:SetupMythicPlusTimer()
        Private:SetupAutoSignUp()
        Private:SetupBossBanner()
        Private:SetupTalkingHead()
    end
end
