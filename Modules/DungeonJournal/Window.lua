local Private = select(2, ...)

local JOURNAL_TEXTURES = "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
local ALL_BOSSES = { Name = "All Bosses", All = true }
local ALL_CLASSES_KEY = "ALL"
local ALL_LEVELS_KEY = 0
local ALL_SLOTS_KEY = "ALL"
local LEVEL_BRACKETS = { { 10, 19 }, { 20, 29 }, { 30, 39 }, { 40, 49 }, { 50, 60 } }

local function GetDungeonButtonSize()
    return 174, 96
end

local function RefreshReceivedLootRow(Row)
    if Row.ItemID == Private.DungeonJournal.ReceivedItemID then Private.UpdateDungeonJournalLootRow(Row) end
end

local function Journal_RefreshDungeons(Journal)
    local Dungeons = Private:GetDungeonJournalDungeons(LEVEL_BRACKETS[Journal.LevelBracket], Journal.ClassFilter, Journal.SlotFilter)
    Journal.DungeonGrid:SetDataProvider(CreateDataProvider(Dungeons))
    Journal.DungeonsEmpty:SetShown(#Dungeons == 0)
end

local function Journal_RefreshLoot(Journal)
    local Loot, Total = Private:GetDungeonJournalLoot(Journal.Dungeon, Journal.Boss, Journal.ClassFilter, Journal.SlotFilter)
    Journal.LootList:SetDataProvider(CreateDataProvider(Loot))
    Journal.BossTitle:SetText(Journal.Boss.Name)

    if #Journal.Dungeon.Bosses == 0 then
        Journal.LootEmpty:SetText("The bosses for this dungeon haven't been published yet.")
    elseif Total == 0 then
        Journal.LootEmpty:SetText(Journal.Boss.All and "The loot for this dungeon hasn't been published yet." or "The loot for this boss hasn't been published yet.")
    else
        Journal.LootEmpty:SetText("No loot matches the current filters.")
    end
    Journal.LootEmpty:SetShown(#Loot == 0)
end

local function Journal_RefreshBosses(Journal)
    local Bosses = Private:GetDungeonJournalBosses(Journal.Dungeon, Journal.ClassFilter, Journal.SlotFilter)
    if not tContains(Bosses, Journal.Boss) then Journal.Boss = ALL_BOSSES end

    local Provider = CreateDataProvider()
    if #Bosses > 0 then
        Provider:Insert(ALL_BOSSES)
        Provider:InsertTable(Bosses)
    end
    Journal.BossList:SetDataProvider(Provider)
    Journal_RefreshLoot(Journal)
end

local function Journal_ShowDungeons(Journal)
    Journal.Dungeon = nil
    Journal.Encounter:Hide()
    Journal.BackButton:Hide()
    Journal.DungeonSelect:Show()
end

local function BackButton_OnClick()
    Journal_ShowDungeons(Private.DungeonJournal)
end

local function BackButton_OnEnter(Button)
    GameTooltip:SetOwner(Button, "ANCHOR_RIGHT")
    GameTooltip:SetText(BACK)
    GameTooltip:Show()
end

local function Journal_SelectDungeon(Journal, Dungeon)
    Journal.Dungeon = Dungeon
    Journal.Boss = ALL_BOSSES
    Journal.DungeonTitle:SetText(Dungeon.Name)
    Journal.DungeonLevels:SetFormattedText("Level %d-%d", Dungeon.Levels[1], Dungeon.Levels[2])
    Journal.DungeonSelect:Hide()
    Journal.Encounter:Show()
    Journal.BackButton:Show()
    Journal_RefreshBosses(Journal)
end

local function Journal_SelectBoss(Journal, Boss)
    Journal.Boss = Boss
    Journal.BossList:ForEachFrame(Private.UpdateDungeonJournalBossSelection)
    Journal_RefreshLoot(Journal)
end

local function Journal_RefreshFilters(Journal)
    Journal_RefreshDungeons(Journal)
    if Journal.Dungeon then Journal_RefreshBosses(Journal) end
end

local function Journal_SetClassFilter(Journal, ClassFile)
    Journal.ClassFilter = ClassFile
    Journal_RefreshFilters(Journal)
end

local function Journal_SetSlotFilter(Journal, Slot)
    Journal.SlotFilter = Slot
    Journal_RefreshFilters(Journal)
end

local function Journal_SetLevelBracket(Journal, Index)
    Journal.LevelBracket = Index
    Journal_RefreshDungeons(Journal)
    Journal_ShowDungeons(Journal)
end

local function GetInstanceDungeon()
    local InstanceName, InstanceType = GetInstanceInfo()
    if InstanceType ~= "party" then return end
    for _, Dungeon in ipairs(Private.DungeonJournalData) do
        if Dungeon.Name == InstanceName then return Dungeon end
    end
end

local function Journal_OnShow(Journal)
    Journal:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    if not Journal.Initialised then
        Journal.Initialised = true
        Journal_RefreshDungeons(Journal)
    end

    local Dungeon = GetInstanceDungeon()
    if Dungeon and Dungeon ~= Journal.Dungeon then Journal_SelectDungeon(Journal, Dungeon) end
end

local function Journal_OnHide(Journal)
    Journal:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
end

local function Journal_OnEvent(Journal, _, ItemID, Success)
    if not Success or not Journal.Dungeon then return end
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

local function CreateDropdown(Journal, Width, SetupMenu)
    local Dropdown = CreateFrame("DropdownButton", nil, Journal, "WowStyle1DropdownTemplate")
    Dropdown:SetWidth(Width)
    Dropdown:SetupMenu(SetupMenu)
    return Dropdown
end

local function CreateScrollList(Parent, View)
    local ScrollBox = CreateFrame("Frame", nil, Parent, "WowScrollBoxList")
    local ScrollBar = CreateFrame("EventFrame", nil, Parent, "MinimalScrollBar")
    ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT", 5, -5)
    ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT", 5, 5)
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, View)
    return ScrollBox
end

local function CreateDungeonSelect(Journal)
    local DungeonSelect = CreateFrame("Frame", nil, Journal)
    DungeonSelect:SetPoint("TOPLEFT", Journal.Inset, "TOPLEFT", 0, -2)
    DungeonSelect:SetPoint("BOTTOMRIGHT", Journal.Inset, "BOTTOMRIGHT", -3, 0)

    local Background = DungeonSelect:CreateTexture(nil, "BACKGROUND")
    Background:SetPoint("TOPLEFT", DungeonSelect, "TOPLEFT", 3, -1)
    if C_Texture.GetAtlasInfo("UI-EJ-Classic") then
        Background:SetAtlas("UI-EJ-Classic", true)
    else
        Background:SetPoint("BOTTOMRIGHT", DungeonSelect, "BOTTOMRIGHT", 0, 0)
        Background:SetTexture("Interface\\EncounterJournal\\UI-EJ-Classic")
    end

    local View = CreateScrollBoxListGridView(4, 5, 0, 0, 0, 15, 15)
    View:SetElementInitializer("Button", Private.InitDungeonJournalDungeonButton)
    View:SetElementSizeCalculator(GetDungeonButtonSize)
    Journal.DungeonGrid = CreateScrollList(DungeonSelect, View)
    Journal.DungeonGrid:SetPoint("TOPLEFT", DungeonSelect, "TOPLEFT", 18, -14)
    Journal.DungeonGrid:SetPoint("BOTTOMRIGHT", DungeonSelect, "BOTTOMRIGHT", -26, 6)

    Journal.DungeonsEmpty = Private:CreateDungeonJournalText(DungeonSelect, "GameFontHighlightLarge")
    Journal.DungeonsEmpty:SetPoint("CENTER", DungeonSelect, "CENTER", 0, 0)
    Journal.DungeonsEmpty:SetText("No dungeons match the current filters.")
    Journal.DungeonSelect = DungeonSelect
end

local function CreateEncounter(Journal)
    local Encounter = CreateFrame("Frame", nil, Journal)
    Encounter:SetSize(785, 425)
    Encounter:SetPoint("BOTTOMRIGHT", Journal.Inset, "BOTTOMRIGHT", -4, 2)
    Encounter:Hide()

    local Background = Encounter:CreateTexture(nil, "BACKGROUND")
    Background:SetAllPoints(Encounter)
    Background:SetTexture("Interface\\EncounterJournal\\UI-EJ-JournalBG")
    Background:SetTexCoord(0, 0.7666015625, 0, 0.830078125)

    local Header = Encounter:CreateTexture(nil, "BORDER")
    Header:SetSize(386, 39)
    Header:SetPoint("TOPLEFT", Encounter, "TOPLEFT", 0, -11)
    Header:SetTexture(JOURNAL_TEXTURES)
    Header:SetTexCoord(0, 0.755859375, 0.9599609375, 1)

    Journal.DungeonTitle = Private:CreateDungeonJournalText(Encounter, "GameFontNormalLarge")
    Journal.DungeonTitle:SetPoint("TOPLEFT", Encounter, "TOPLEFT", 28, -24)
    Journal.DungeonTitle:SetTextColor(0.902, 0.788, 0.671)
    Journal.DungeonLevels = Private:CreateDungeonJournalText(Encounter, "GameFontHighlightSmall")
    Journal.DungeonLevels:SetPoint("BOTTOMLEFT", Journal.DungeonTitle, "BOTTOMRIGHT", 8, 1)

    local BossView = CreateScrollBoxListLinearView(15, 0, 0, 20, 15)
    BossView:SetElementExtent(55)
    BossView:SetElementInitializer("Button", Private.InitDungeonJournalBossButton)
    Journal.BossList = CreateScrollList(Encounter, BossView)
    Journal.BossList:SetSize(338, 372)
    Journal.BossList:SetPoint("BOTTOMLEFT", Encounter, "BOTTOMLEFT", 25, 1)

    local LootView = CreateScrollBoxListLinearView(0, 0, 0, 0, 3)
    LootView:SetElementExtent(46)
    LootView:SetElementInitializer("Button", Private.InitDungeonJournalLootRow)
    Journal.LootList = CreateScrollList(Encounter, LootView)
    Journal.LootList:SetSize(330, 372)
    Journal.LootList:SetPoint("BOTTOMRIGHT", Encounter, "BOTTOMRIGHT", -20, 1)

    Journal.BossTitle = Private:CreateDungeonJournalText(Encounter, "GameFontNormalLarge")
    Journal.BossTitle:SetPoint("BOTTOMLEFT", Journal.LootList, "TOPLEFT", 4, 16)

    Journal.LootEmpty = Private:CreateDungeonJournalText(Encounter, "GameFontHighlight")
    Journal.LootEmpty:SetPoint("CENTER", Journal.LootList, "CENTER", 0, 0)
    Journal.LootEmpty:SetWidth(300)
    Journal.Encounter = Encounter
end

function Private:CreateDungeonJournal()
    local Journal = CreateFrame("Frame", "UnhaltedDungeonJournal", UIParent, "PortraitFrameTemplate")
    Journal:SetSize(800, 496)
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

    Journal.Inset = CreateFrame("Frame", nil, Journal, "InsetFrameTemplate")
    Journal.Inset:SetPoint("TOPLEFT", Journal, "TOPLEFT", 4, -60)
    Journal.Inset:SetPoint("BOTTOMRIGHT", Journal, "BOTTOMRIGHT", -6, 5)

    Journal.BackButton = CreateFrame("Button", nil, Journal, "UIPanelSquareButton")
    Journal.BackButton:SetSize(22, 22)
    Journal.BackButton:SetPoint("RIGHT", Journal.CloseButton, "LEFT", -2, 0)
    Journal.BackButton:SetFrameLevel(Journal.CloseButton:GetFrameLevel())
    SquareButton_SetIcon(Journal.BackButton, "LEFT")
    Journal.BackButton:SetScript("OnClick", BackButton_OnClick)
    Journal.BackButton:SetScript("OnEnter", BackButton_OnEnter)
    Journal.BackButton:SetScript("OnLeave", GameTooltip_Hide)
    Journal.BackButton:Hide()

    local DropdownWidth = (Journal:GetWidth() - 62 - 10 - 2 * 10) / 3
    Journal.SlotDropdown = CreateDropdown(Journal, DropdownWidth, SlotDropdown_SetupMenu)
    Journal.SlotDropdown:SetPoint("TOPLEFT", Journal, "TOPLEFT", 62, -29)
    Journal.LevelDropdown = CreateDropdown(Journal, DropdownWidth, LevelDropdown_SetupMenu)
    Journal.LevelDropdown:SetPoint("LEFT", Journal.SlotDropdown, "RIGHT", 10, 0)
    Journal.ClassDropdown = CreateDropdown(Journal, DropdownWidth, ClassDropdown_SetupMenu)
    Journal.ClassDropdown:SetPoint("LEFT", Journal.LevelDropdown, "RIGHT", 10, 0)

    CreateDungeonSelect(Journal)
    CreateEncounter(Journal)

    Journal:SetScript("OnShow", Journal_OnShow)
    Journal:SetScript("OnHide", Journal_OnHide)
    Journal:SetScript("OnEvent", Journal_OnEvent)
end
