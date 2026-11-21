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
    -- [[ Blizzard ]]
    Private:SetupObjectiveTracker()
    Private:SetupObjectiveTrackerBanner()
    Private:SetupUIErrorsFrame()
    -- [[ Damage Meter ]]
    Private:SetupDamageMeters()
    -- [[ ElvUI]]
    Private:SetupColouredQuestMobs()
    Private:SetupEnhancedMovers()
    Private:SetupFocusTexture()
    Private:SetupLootRollFix()
    Private:SetupRemoveFogOfWar()
    -- [[ Minimap Stats ]]
    Private:SetupInstanceDifficulty()
    Private:SetupLocation()
    Private:SetupSystemStats()
    Private:SetupTime()
    -- [[ Miscellaneous ]]
    Private:SetupCombatTimer()
    Private:SetupCrosshair()
    Private:SyncCVars()
    Private:SetupExtraQuestButton()
    Private:SetupMouseCursor()
    -- [[ Toggles ]]
    Private:SetupAutoDelete()
    Private:SetupAutoQuest()
    Private:SetupLossOfControl()
    Private:SkipCinematics()

    if Private.isForever then
        -- [[ Forever ]]
        Private:SetupAmmoCounter()
        Private:SetupFeedPet()
        Private:SetupAutoPurchase()
        Private:SetupBeastLore()
        Private:SetupDungeonJournal()
        Private:SetupMergeIcons()
        Private:SetupNavigation()
        Private:SetupWorldMapZoneLevels()
    else
        -- [[ Retail ]]
        Private:SetupTimeSpiralAlert()
        Private:SetupInterruptOnCooldown()
        Private:SetupCombatResurrection()
        Private:SetupMythicPlusTimer()
        Private:SetupAutoSignUp()
        Private:SetupBossBanner()
        Private:SetupTalkingHead()
    end

    Private.PackedData = nil
end
