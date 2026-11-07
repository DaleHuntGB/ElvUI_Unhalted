local Private = select(2, ...)

local ALL_BOSSES = { Name = "All Bosses", All = true }
local ALL_CLASSES_KEY = "ALL"
local ALL_LEVELS_KEY = 0
local ALL_SLOTS_KEY = "ALL"
local LEVEL_BRACKETS = { { 10, 19 }, { 20, 29 }, { 30, 39 }, { 40, 49 }, { 50, 60 } }

local function CreateList(Inset, ElementHeight, Initializer)
    local ScrollBox = CreateFrame("Frame", nil, Inset, "WowScrollBoxList")
    local ScrollBar = CreateFrame("EventFrame", nil, Inset, "MinimalScrollBar")
    ScrollBar:SetPoint("TOPRIGHT", Inset, "TOPRIGHT", -6, -6)
    ScrollBar:SetPoint("BOTTOMRIGHT", Inset, "BOTTOMRIGHT", -6, 6)

    local View = CreateScrollBoxListLinearView(2, 2, 2, 2)
    View:SetElementExtent(ElementHeight)
    View:SetElementInitializer("Button", Initializer)
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, View)

    local AnchorsWithBar = { CreateAnchor("TOPLEFT", Inset, "TOPLEFT", 4, -4), CreateAnchor("BOTTOMRIGHT", Inset, "BOTTOMRIGHT", -22, 4) }
    local AnchorsWithoutBar = { CreateAnchor("TOPLEFT", Inset, "TOPLEFT", 4, -4), CreateAnchor("BOTTOMRIGHT", Inset, "BOTTOMRIGHT", -4, 4) }
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(ScrollBox, ScrollBar, AnchorsWithBar, AnchorsWithoutBar)

    return ScrollBox
end

local function UpdateDungeonSelection(Row)
    Row.Selected:SetShown(Row.Dungeon == Private.DungeonJournal.Dungeon)
end

local function UpdateBossSelection(Row)
    Row.Selected:SetShown(Row.Boss == Private.DungeonJournal.Boss)
end

local function RefreshReceivedLootRow(Row)
    if Row.ItemID == Private.DungeonJournal.ReceivedItemID then Private.UpdateDungeonJournalLootRow(Row) end
end

local function Journal_RefreshLoot(Journal)
    local Loot, Total = Private:GetDungeonJournalLoot(Journal.Dungeon, Journal.Boss, Journal.ClassFilter, Journal.SlotFilter)
    Journal.LootList:SetDataProvider(CreateDataProvider(Loot))

    if #Journal.Dungeon.Bosses == 0 then
        Journal.EmptyText:SetText("The bosses for this dungeon haven't been published yet.")
    elseif Total == 0 then
        Journal.EmptyText:SetText(Journal.Boss.All and "The loot for this dungeon hasn't been published yet." or "The loot for this boss hasn't been published yet.")
    else
        Journal.EmptyText:SetText("No loot matches the current filters.")
    end
    Journal.EmptyText:SetShown(#Loot == 0)
end

local function Journal_SelectBoss(Journal, Boss)
    Journal.Boss = Boss
    Journal.BossList:ForEachFrame(UpdateBossSelection)
    Journal_RefreshLoot(Journal)
end

local function Journal_SelectDungeon(Journal, Dungeon)
    local Bosses = Private:GetDungeonJournalBosses(Dungeon, Journal.ClassFilter, Journal.SlotFilter)
    if Journal.Dungeon ~= Dungeon or not tContains(Bosses, Journal.Boss) then Journal.Boss = ALL_BOSSES end
    Journal.Dungeon = Dungeon
    Journal.DungeonName:SetText(Dungeon.Name)
    Journal.DungeonInfo:SetFormattedText("Level %d-%d  |cFFAAAAAA%s|r", Dungeon.Levels[1], Dungeon.Levels[2], Dungeon.Zone)
    Journal.DungeonList:ForEachFrame(UpdateDungeonSelection)

    local BossProvider = CreateDataProvider()
    if #Bosses > 0 then
        BossProvider:Insert(ALL_BOSSES)
        BossProvider:InsertTable(Bosses)
    end
    Journal.BossList:SetDataProvider(BossProvider)
    Journal_RefreshLoot(Journal)
end

local function Journal_RefreshDungeons(Journal)
    local Dungeons = Private:GetDungeonJournalDungeons(LEVEL_BRACKETS[Journal.LevelBracket], Journal.ClassFilter, Journal.SlotFilter)
    Journal.DungeonList:SetDataProvider(CreateDataProvider(Dungeons))

    local Dungeon = tContains(Dungeons, Journal.Dungeon) and Journal.Dungeon or Dungeons[1]
    if Dungeon then
        Journal_SelectDungeon(Journal, Dungeon)
        Journal.DungeonList:ScrollToElementData(Dungeon, ScrollBoxConstants.AlignCenter, 0, ScrollBoxConstants.NoScrollInterpolation)
        return
    end

    Journal.Dungeon = nil
    Journal.DungeonName:SetText("")
    Journal.DungeonInfo:SetText("")
    Journal.BossList:SetDataProvider(CreateDataProvider())
    Journal.LootList:SetDataProvider(CreateDataProvider())
    Journal.EmptyText:SetText("No dungeons match the current filters.")
    Journal.EmptyText:Show()
end

local function Journal_SetClassFilter(Journal, ClassFile)
    Journal.ClassFilter = ClassFile
    Journal_RefreshDungeons(Journal)
end

local function Journal_SetSlotFilter(Journal, Slot)
    Journal.SlotFilter = Slot
    Journal_RefreshDungeons(Journal)
end

local function Journal_SetLevelBracket(Journal, Index)
    Journal.LevelBracket = Index
    Journal_RefreshDungeons(Journal)
end

local function GetDefaultDungeon()
    local InstanceName, InstanceType = GetInstanceInfo()
    local Level = UnitLevel("player")
    local Default
    for _, Dungeon in ipairs(Private.DungeonJournalData) do
        if InstanceType == "party" and Dungeon.Name == InstanceName then return Dungeon end
        if not Default and Level >= Dungeon.Levels[1] and Level <= Dungeon.Levels[2] then Default = Dungeon end
    end
    return Default or Private.DungeonJournalData[1]
end

local function Journal_OnShow(Journal)
    Journal:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    if Journal.Initialised then return end

    Journal.Initialised = true
    Journal.Dungeon = GetDefaultDungeon()
    Journal_RefreshDungeons(Journal)
end

local function Journal_OnHide(Journal)
    Journal:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
end

local function Journal_OnEvent(Journal, _, ItemID, Success)
    if not Success then return end
    Journal.ReceivedItemID = ItemID
    Journal.LootList:ForEachFrame(RefreshReceivedLootRow)
end

local function ClassDropdown_IsSelected(ClassFile)
    return (Private.DungeonJournal.ClassFilter or ALL_CLASSES_KEY) == ClassFile
end

local function ClassDropdown_SetSelected(ClassFile)
    Private.DungeonJournal:SetClassFilter(ClassFile ~= ALL_CLASSES_KEY and ClassFile or nil)
end

local function ClassDropdown_SetupMenu(_, RootDescription)
    RootDescription:CreateRadio(ALL_CLASSES, ClassDropdown_IsSelected, ClassDropdown_SetSelected, ALL_CLASSES_KEY)
    for ClassID = 1, GetNumClasses() do
        local ClassName, ClassFile = GetClassInfo(ClassID)
        if ClassFile and Private.DungeonJournalClasses[ClassFile] then
            RootDescription:CreateRadio(RAID_CLASS_COLORS[ClassFile]:WrapTextInColorCode(ClassName), ClassDropdown_IsSelected, ClassDropdown_SetSelected, ClassFile)
        end
    end
end

local function LevelDropdown_IsSelected(Index)
    return Private.DungeonJournal.LevelBracket == Index
end

local function LevelDropdown_SetSelected(Index)
    Private.DungeonJournal:SetLevelBracket(Index)
end

local function LevelDropdown_SetupMenu(_, RootDescription)
    RootDescription:CreateRadio("All Levels", LevelDropdown_IsSelected, LevelDropdown_SetSelected, ALL_LEVELS_KEY)
    for Index, Bracket in ipairs(LEVEL_BRACKETS) do
        RootDescription:CreateRadio(string.format("Level %d-%d", Bracket[1], Bracket[2]), LevelDropdown_IsSelected, LevelDropdown_SetSelected, Index)
    end
end

local function SlotDropdown_IsSelected(Slot)
    return (Private.DungeonJournal.SlotFilter or ALL_SLOTS_KEY) == Slot
end

local function SlotDropdown_SetSelected(Slot)
    Private.DungeonJournal:SetSlotFilter(Slot ~= ALL_SLOTS_KEY and Slot or nil)
end

local function SlotDropdown_SetupMenu(_, RootDescription)
    RootDescription:CreateRadio("All Slots", SlotDropdown_IsSelected, SlotDropdown_SetSelected, ALL_SLOTS_KEY)
    for _, Slot in ipairs(Private.DungeonJournalSlots) do
        RootDescription:CreateRadio(Slot, SlotDropdown_IsSelected, SlotDropdown_SetSelected, Slot)
    end
end

function Private:CreateDungeonJournal()
    local Journal = CreateFrame("Frame", "UnhaltedDungeonJournal", UIParent, "PortraitFrameTemplate")
    Journal:SetSize(900, 560)
    Journal:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    Journal:SetFrameStrata("HIGH")
    Journal:SetToplevel(true)
    Journal:SetMovable(true)
    Journal:SetClampedToScreen(true)
    Journal:EnableMouse(true)
    Journal:RegisterForDrag("LeftButton")
    Journal:SetScript("OnDragStart", Journal.StartMoving)
    Journal:SetScript("OnDragStop", Journal.StopMovingOrSizing)
    Journal:SetTitle("Dungeon Journal")
    Journal:SetPortraitToAsset("Interface\\EncounterJournal\\UI-EJ-PortraitIcon")
    Journal:Hide()
    tinsert(UISpecialFrames, Journal:GetName())

    Journal.SelectDungeon = Journal_SelectDungeon
    Journal.SelectBoss = Journal_SelectBoss
    Journal.SetClassFilter = Journal_SetClassFilter
    Journal.SetSlotFilter = Journal_SetSlotFilter
    Journal.SetLevelBracket = Journal_SetLevelBracket
    Journal.ClassFilter = select(2, UnitClass("player"))
    Journal.LevelBracket = ALL_LEVELS_KEY
    Private.DungeonJournal = Journal

    Journal.DungeonName = Journal:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    Journal.DungeonName:SetPoint("TOPLEFT", Journal, "TOPLEFT", 64, -30)
    Journal.DungeonInfo = Journal:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    Journal.DungeonInfo:SetPoint("TOPLEFT", Journal.DungeonName, "BOTTOMLEFT", 0, -3)

    Journal.ClassDropdown = CreateFrame("DropdownButton", nil, Journal, "WowStyle1DropdownTemplate")
    Journal.ClassDropdown:SetWidth(170)
    Journal.ClassDropdown:SetPoint("TOPRIGHT", Journal, "TOPRIGHT", -12, -32)
    Journal.ClassDropdown:SetupMenu(ClassDropdown_SetupMenu)

    Journal.LevelDropdown = CreateFrame("DropdownButton", nil, Journal, "WowStyle1DropdownTemplate")
    Journal.LevelDropdown:SetWidth(130)
    Journal.LevelDropdown:SetPoint("RIGHT", Journal.ClassDropdown, "LEFT", -8, 0)
    Journal.LevelDropdown:SetupMenu(LevelDropdown_SetupMenu)

    Journal.SlotDropdown = CreateFrame("DropdownButton", nil, Journal, "WowStyle1DropdownTemplate")
    Journal.SlotDropdown:SetWidth(120)
    Journal.SlotDropdown:SetPoint("RIGHT", Journal.LevelDropdown, "LEFT", -8, 0)
    Journal.SlotDropdown:SetupMenu(SlotDropdown_SetupMenu)

    local DungeonInset = CreateFrame("Frame", nil, Journal, "InsetFrameTemplate")
    DungeonInset:SetPoint("TOPLEFT", Journal, "TOPLEFT", 6, -66)
    DungeonInset:SetPoint("BOTTOMLEFT", Journal, "BOTTOMLEFT", 6, 6)
    DungeonInset:SetWidth(250)

    local BossInset = CreateFrame("Frame", nil, Journal, "InsetFrameTemplate")
    BossInset:SetPoint("TOPLEFT", DungeonInset, "TOPRIGHT", 4, 0)
    BossInset:SetPoint("BOTTOMLEFT", DungeonInset, "BOTTOMRIGHT", 4, 0)
    BossInset:SetWidth(210)

    local LootInset = CreateFrame("Frame", nil, Journal, "InsetFrameTemplate")
    LootInset:SetPoint("TOPLEFT", BossInset, "TOPRIGHT", 4, 0)
    LootInset:SetPoint("BOTTOMRIGHT", Journal, "BOTTOMRIGHT", -6, 6)

    Journal.DungeonList = CreateList(DungeonInset, 40, Private.InitDungeonJournalDungeonRow)
    Journal.BossList = CreateList(BossInset, 30, Private.InitDungeonJournalBossRow)
    Journal.LootList = CreateList(LootInset, 44, Private.InitDungeonJournalLootRow)

    Journal.EmptyText = LootInset:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    Journal.EmptyText:SetPoint("CENTER", LootInset, "CENTER", 0, 0)
    Journal.EmptyText:SetWidth(360)

    Journal:SetScript("OnShow", Journal_OnShow)
    Journal:SetScript("OnHide", Journal_OnHide)
    Journal:SetScript("OnEvent", Journal_OnEvent)
end
