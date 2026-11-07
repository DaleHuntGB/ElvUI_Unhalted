local Private = select(2, ...)

local HIGHLIGHT_TEXTURE = "Interface\\QuestFrame\\UI-QuestTitleHighlight"
local MISSING_ICON = 134400

local function CreateRowHighlight(Row)
    Row:SetHighlightTexture(HIGHLIGHT_TEXTURE, "ADD")
    Row.Selected = Row:CreateTexture(nil, "BACKGROUND")
    Row.Selected:SetAllPoints(Row)
    Row.Selected:SetTexture(HIGHLIGHT_TEXTURE)
    Row.Selected:SetBlendMode("ADD")
    Row.Selected:SetVertexColor(1, 0.82, 0)
end

local function CreateRowText(Row, Template)
    local Text = Row:CreateFontString(nil, "OVERLAY", Template)
    Text:SetJustifyH("LEFT")
    Text:SetWordWrap(false)
    return Text
end

local function DungeonRow_OnClick(Row)
    Private.DungeonJournal:SelectDungeon(Row.Dungeon)
end

function Private.InitDungeonJournalDungeonRow(Row, Dungeon)
    if not Row.Name then
        CreateRowHighlight(Row)
        Row.Name = CreateRowText(Row, "GameFontNormal")
        Row.Name:SetPoint("TOPLEFT", Row, "TOPLEFT", 8, -6)
        Row.Name:SetPoint("RIGHT", Row, "RIGHT", -36, 0)
        Row.Info = CreateRowText(Row, "GameFontHighlightSmall")
        Row.Info:SetPoint("TOPLEFT", Row.Name, "BOTTOMLEFT", 0, -3)
        Row.Info:SetPoint("RIGHT", Row, "RIGHT", -8, 0)
        Row.New = Row:CreateFontString(nil, "OVERLAY", "GameFontGreenSmall")
        Row.New:SetPoint("TOPRIGHT", Row, "TOPRIGHT", -8, -7)
        Row.New:SetText("New")
        Row:SetScript("OnClick", DungeonRow_OnClick)
    end

    Row.Dungeon = Dungeon
    Row.Name:SetText(Dungeon.Name)
    Row.Info:SetFormattedText("Level %d-%d  |cFFAAAAAA%s|r", Dungeon.Levels[1], Dungeon.Levels[2], Dungeon.Zone)
    Row.New:SetShown(Dungeon.New == true)
    Row.Selected:SetShown(Private.DungeonJournal.Dungeon == Dungeon)
end

local function BossRow_OnClick(Row)
    Private.DungeonJournal:SelectBoss(Row.Boss)
end

function Private.InitDungeonJournalBossRow(Row, Boss)
    if not Row.Name then
        CreateRowHighlight(Row)
        Row.Name = CreateRowText(Row, "GameFontNormal")
        Row.Name:SetPoint("LEFT", Row, "LEFT", 8, 0)
        Row.Name:SetPoint("RIGHT", Row, "RIGHT", -8, 0)
        Row:SetScript("OnClick", BossRow_OnClick)
    end

    Row.Boss = Boss
    Row.Name:SetText(Boss.Rare and Boss.Name .. " |cFF808080(Rare)|r" or Boss.Name)
    Row.Selected:SetShown(Private.DungeonJournal.Boss == Boss)
end

local function GetSlotText(ItemType, ItemSubType, EquipLoc, ClassID, SubClassID)
    local Slot = EquipLoc and _G[EquipLoc]
    if not Slot or Slot == "" then return ItemType or "" end
    if ClassID == Enum.ItemClass.Armor and (SubClassID == Enum.ItemArmorSubclass.Generic or EquipLoc == "INVTYPE_CLOAK") then return Slot end
    return Slot .. ", " .. ItemSubType
end

function Private.UpdateDungeonJournalLootRow(Row)
    local Name, Link, Quality = C_Item.GetItemInfo(Row.ItemID)
    Row.Link = Link
    if Name then
        local R, G, B = C_Item.GetItemQualityColor(Quality)
        Row.Name:SetText(Name)
        Row.Name:SetTextColor(R, G, B)
        Row.IconBorder:SetVertexColor(R, G, B)
        Row.IconBorder:Show()
    else
        Row.Name:SetText(RETRIEVING_ITEM_INFO)
        Row.Name:SetTextColor(0.5, 0.5, 0.5)
        Row.IconBorder:Hide()
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
        Row:SetHighlightTexture(HIGHLIGHT_TEXTURE, "ADD")
        Row.Icon = Row:CreateTexture(nil, "ARTWORK")
        Row.Icon:SetSize(36, 36)
        Row.Icon:SetPoint("LEFT", Row, "LEFT", 6, 0)
        Row.IconBorder = Row:CreateTexture(nil, "OVERLAY")
        Row.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
        Row.IconBorder:SetAllPoints(Row.Icon)
        Row.Name = CreateRowText(Row, "GameFontNormal")
        Row.Name:SetPoint("TOPLEFT", Row.Icon, "TOPRIGHT", 8, -3)
        Row.Name:SetPoint("RIGHT", Row, "RIGHT", -8, 0)
        Row.Slot = CreateRowText(Row, "GameFontHighlightSmall")
        Row.Slot:SetPoint("BOTTOMLEFT", Row.Icon, "BOTTOMRIGHT", 8, 3)
        Row.Source = Row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        Row.Source:SetPoint("BOTTOMRIGHT", Row, "BOTTOMRIGHT", -8, 7)
        Row.Source:SetJustifyH("RIGHT")
        Row.Slot:SetPoint("RIGHT", Row.Source, "LEFT", -8, 0)
        Row:SetScript("OnEnter", LootRow_OnEnter)
        Row:SetScript("OnLeave", GameTooltip_Hide)
        Row:SetScript("OnClick", LootRow_OnClick)
    end

    local _, ItemType, ItemSubType, EquipLoc, Icon, ClassID, SubClassID = C_Item.GetItemInfoInstant(Loot.ItemID)
    Row.ItemID = Loot.ItemID
    Row.Icon:SetTexture(Icon or MISSING_ICON)
    Row.Slot:SetText(GetSlotText(ItemType, ItemSubType, EquipLoc, ClassID, SubClassID))
    Row.Source:SetText(Loot.Boss or "")
    Private.UpdateDungeonJournalLootRow(Row)
end
