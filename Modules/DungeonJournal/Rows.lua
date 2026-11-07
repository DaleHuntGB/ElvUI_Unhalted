local Private = select(2, ...)

local JOURNAL_TEXTURES = "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
local DEFAULT_DUNGEON_ART = "Interface\\EncounterJournal\\UI-EJ-DUNGEONBUTTON-Default"
local DEFAULT_PORTRAIT = "Interface\\EncounterJournal\\UI-EJ-BOSS-Default"
local MISSING_ICON = 134400

local DUNGEON_BUTTON_UP = { 0.00195313, 0.34179688, 0.42871094, 0.52246094 }
local DUNGEON_BUTTON_DOWN = { 0.00195313, 0.34179688, 0.33300781, 0.42675781 }
local DUNGEON_BUTTON_HIGHLIGHT = { 0.34570313, 0.68554688, 0.33300781, 0.42675781 }
local BOSS_BUTTON_UP = { 0.00195313, 0.63671875, 0.21386719, 0.26757813 }
local BOSS_BUTTON_DOWN = { 0.00195313, 0.63671875, 0.10253906, 0.15625000 }
local BOSS_BUTTON_HIGHLIGHT = { 0.00195313, 0.63671875, 0.15820313, 0.21191406 }

local function SetButtonArt(Button, Coords, Pushed, Highlight)
    Button:SetNormalTexture(JOURNAL_TEXTURES)
    Button:GetNormalTexture():SetTexCoord(Coords[1], Coords[2], Coords[3], Coords[4])
    Button:SetPushedTexture(JOURNAL_TEXTURES)
    Button:GetPushedTexture():SetTexCoord(Pushed[1], Pushed[2], Pushed[3], Pushed[4])
    Button:SetHighlightTexture(JOURNAL_TEXTURES)
    Button:GetHighlightTexture():SetTexCoord(Highlight[1], Highlight[2], Highlight[3], Highlight[4])
end

local function DungeonButton_OnClick(Button)
    Private.DungeonJournal:SelectDungeon(Button.Dungeon)
end

local function DungeonButton_OnEnter(Button)
    local Dungeon = Button.Dungeon
    GameTooltip:SetOwner(Button, "ANCHOR_RIGHT")
    GameTooltip:SetText(Dungeon.Name, 1, 1, 1)
    GameTooltip:AddLine(string.format("Level %d-%d", Dungeon.Levels[1], Dungeon.Levels[2]))
    GameTooltip:AddLine(Dungeon.Zone, 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

function Private.InitDungeonJournalDungeonButton(Button, Dungeon)
    if not Button.Name then
        Button.Art = Button:CreateTexture(nil, "BACKGROUND")
        Button.Art:SetAllPoints(Button)
        SetButtonArt(Button, DUNGEON_BUTTON_UP, DUNGEON_BUTTON_DOWN, DUNGEON_BUTTON_HIGHLIGHT)
        Button.Name = Private:CreateDungeonJournalText(Button, "QuestTitleFontBlackShadow")
        Button.Name:SetWidth(150)
        Button.Name:SetPoint("TOP", Button, "TOP", 0, -15)
        Button.Levels = Private:CreateDungeonJournalText(Button, "GameFontNormal")
        Button.Levels:SetPoint("BOTTOMLEFT", Button, "BOTTOMLEFT", 7, 7)
        Button.New = Private:CreateDungeonJournalText(Button, "GameFontGreen")
        Button.New:SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -7, 7)
        Button.New:SetText("New")
        Button:SetScript("OnClick", DungeonButton_OnClick)
        Button:SetScript("OnEnter", DungeonButton_OnEnter)
        Button:SetScript("OnLeave", GameTooltip_Hide)
    end

    Button.Dungeon = Dungeon
    if not (Dungeon.Button and Button.Art:SetTexture(Dungeon.Button)) then Button.Art:SetTexture(DEFAULT_DUNGEON_ART) end
    Button.Art:SetTexCoord(0, 0.68359375, 0, 0.7421875)
    Button.Name:SetText(Dungeon.Name)
    Button.Levels:SetFormattedText("%d-%d", Dungeon.Levels[1], Dungeon.Levels[2])
    Button.New:SetShown(Dungeon.New == true)
end

local function BossButton_OnClick(Button)
    Private.DungeonJournal:SelectBoss(Button.Boss)
end

function Private.UpdateDungeonJournalBossSelection(Button)
    if Button.Boss == Private.DungeonJournal.Boss then
        Button:LockHighlight()
    else
        Button:UnlockHighlight()
    end
end

function Private.InitDungeonJournalBossButton(Button, Boss)
    if not Button.Name then
        SetButtonArt(Button, BOSS_BUTTON_UP, BOSS_BUTTON_DOWN, BOSS_BUTTON_HIGHLIGHT)
        Button.Portrait = Button:CreateTexture(nil, "OVERLAY")
        Button.Portrait:SetSize(128, 64)
        Button.Portrait:SetPoint("TOPLEFT", Button, "TOPLEFT", -4, 13)
        Button.Name = Private:CreateDungeonJournalText(Button, "GameFontNormalMed3")
        Button.Name:SetSize(160, 40)
        Button.Name:SetPoint("LEFT", Button, "LEFT", 105, -3)
        Button.Name:SetJustifyH("LEFT")
        Button.Name:SetTextColor(0.827, 0.659, 0.463)
        Button:SetScript("OnClick", BossButton_OnClick)
    end

    Button.Boss = Boss
    if not (Boss.Portrait and Button.Portrait:SetTexture(Boss.Portrait)) then Button.Portrait:SetTexture(DEFAULT_PORTRAIT) end
    Button.Name:SetText(Boss.Rare and Boss.Name .. "\n|cFF9D9D9D(Rare)|r" or Boss.Name)
    Private.UpdateDungeonJournalBossSelection(Button)
end

function Private.UpdateDungeonJournalLootRow(Row)
    local Name, Link, Quality = C_Item.GetItemInfo(Row.ItemID)
    Row.Link = Link
    if Name then
        local R, G, B = C_Item.GetItemQualityColor(Quality)
        Row.Name:SetText(Name)
        Row.Name:SetTextColor(R, G, B)
        Row.IconBorder:SetVertexColor(R, G, B)
    else
        Row.Name:SetText(RETRIEVING_ITEM_INFO)
        Row.Name:SetTextColor(0.6, 0.6, 0.6)
        Row.IconBorder:SetVertexColor(0.3, 0.3, 0.3)
        C_Item.RequestLoadItemDataByID(Row.ItemID)
    end
end

local function LootRow_OnEnter(Row)
    GameTooltip:SetOwner(Row, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(Row.ItemID)
    GameTooltip:Show()
end

local function LootRow_OnClick(Row)
    if Row.Link then HandleModifiedItemClick(Row.Link) end
end

function Private.InitDungeonJournalLootRow(Row, Loot)
    if not Row.Icon then
        Row.Background = Row:CreateTexture(nil, "BACKGROUND")
        Row.Background:SetAllPoints(Row)
        Row.Background:SetColorTexture(0, 0, 0, 0.25)
        Row.Highlight = Row:CreateTexture(nil, "HIGHLIGHT")
        Row.Highlight:SetAllPoints(Row)
        Row.Highlight:SetColorTexture(0.45, 0.3, 0.1, 0.15)
        Row.Icon = Row:CreateTexture(nil, "ARTWORK")
        Row.Icon:SetSize(38, 38)
        Row.Icon:SetPoint("LEFT", Row, "LEFT", 4, 0)
        Row.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        Row.IconBorder = Row:CreateTexture(nil, "BORDER")
        Row.IconBorder:SetPoint("TOPLEFT", Row.Icon, "TOPLEFT", -1, 1)
        Row.IconBorder:SetPoint("BOTTOMRIGHT", Row.Icon, "BOTTOMRIGHT", 1, -1)
        Row.IconBorder:SetColorTexture(1, 1, 1)
        Row.Name = Private:CreateDungeonJournalText(Row, "GameFontNormalMed3")
        Row.Name:SetPoint("TOPLEFT", Row.Icon, "TOPRIGHT", 8, -3)
        Row.Name:SetPoint("RIGHT", Row, "RIGHT", -8, 0)
        Row.Name:SetJustifyH("LEFT")
        Row.Name:SetWordWrap(false)
        Row.Source = Private:CreateDungeonJournalText(Row, "GameFontNormalSmall")
        Row.Source:SetPoint("BOTTOMRIGHT", Row, "BOTTOMRIGHT", -8, 7)
        Row.Source:SetJustifyH("RIGHT")
        Row.Source:SetTextColor(0.827, 0.659, 0.463)
        Row.Slot = Private:CreateDungeonJournalText(Row, "GameFontHighlightSmall")
        Row.Slot:SetPoint("BOTTOMLEFT", Row.Icon, "BOTTOMRIGHT", 8, 3)
        Row.Slot:SetPoint("RIGHT", Row.Source, "LEFT", -8, 0)
        Row.Slot:SetJustifyH("LEFT")
        Row.Slot:SetWordWrap(false)
        Row:SetScript("OnEnter", LootRow_OnEnter)
        Row:SetScript("OnLeave", GameTooltip_Hide)
        Row:SetScript("OnClick", LootRow_OnClick)
    end

    local _, ItemType, ItemSubType, EquipLoc, Icon, ClassID, SubClassID = C_Item.GetItemInfoInstant(Loot.ItemID)
    local Slot = EquipLoc and _G[EquipLoc]
    if not Slot or Slot == "" then
        Slot = ItemType or ""
    elseif ClassID ~= Enum.ItemClass.Armor or (SubClassID ~= Enum.ItemArmorSubclass.Generic and EquipLoc ~= "INVTYPE_CLOAK") then
        Slot = Slot .. ", " .. ItemSubType
    end
    Row.ItemID = Loot.ItemID
    Row.Icon:SetTexture(Icon or MISSING_ICON)
    Row.Slot:SetText(Slot)
    Row.Source:SetText(Loot.Boss or "")
    Private.UpdateDungeonJournalLootRow(Row)
end
