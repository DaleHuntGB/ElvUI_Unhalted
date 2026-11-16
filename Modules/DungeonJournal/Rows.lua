local Private = select(2, ...)

local JournalTextures = "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
local DefaultDungeonArt = "Interface\\EncounterJournal\\UI-EJ-DUNGEONBUTTON-Default"
local DefaultPortrait = "Interface\\EncounterJournal\\UI-EJ-BOSS-Default"
local PortraitMask = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local IconBorder = "Interface\\Common\\WhiteIconFrame"
local MissingIcon = 134400

local DungeonButtonUp = { 0.00195313, 0.34179688, 0.42871094, 0.52246094 }
local DungeonButtonDown = { 0.00195313, 0.34179688, 0.33300781, 0.42675781 }
local DungeonButtonHighlight = { 0.34570313, 0.68554688, 0.33300781, 0.42675781 }
local BossButtonUp = { 0.00195313, 0.63671875, 0.21386719, 0.26757813 }
local BossButtonDown = { 0.00195313, 0.63671875, 0.10253906, 0.15625000 }
local BossButtonHighlight = { 0.00195313, 0.63671875, 0.15820313, 0.21191406 }
local LootRowFrame = { 0.00195313, 0.62890625, 0.61816406, 0.66210938 }
local DungeonCard = { 0, 0.68359375, 0, 0.7421875 }
local DungeonThumbnail = { 0.18359375, 0.5, 0.13671875, 0.60546875 }
local LoadingScreenCard = { 0.1534, 0.8466, 0.1603, 0.8397 }
local LoadingScreenThumbnail = { 0.2421, 0.7579, 0.1603, 0.8397 }

local function SetButtonArt(Button, Coords, Pushed, Highlight)
    Button:SetNormalTexture(JournalTextures)
    Button:GetNormalTexture():SetTexCoord(Coords[1], Coords[2], Coords[3], Coords[4])
    Button:SetPushedTexture(JournalTextures)
    Button:GetPushedTexture():SetTexCoord(Pushed[1], Pushed[2], Pushed[3], Pushed[4])
    Button:SetHighlightTexture(JournalTextures)
    Button:GetHighlightTexture():SetTexCoord(Highlight[1], Highlight[2], Highlight[3], Highlight[4])
end

local function SetDungeonArt(Texture, Dungeon, Coords, LoadingScreenCoords)
    if Dungeon.LoadingScreen and Texture:SetTexture(Dungeon.LoadingScreen) then
        Texture:SetTexCoord(LoadingScreenCoords[1], LoadingScreenCoords[2], LoadingScreenCoords[3], LoadingScreenCoords[4])
        return
    end
    if not (Dungeon.Button and Texture:SetTexture(Dungeon.Button)) then Texture:SetTexture(DefaultDungeonArt) end
    Texture:SetTexCoord(Coords[1], Coords[2], Coords[3], Coords[4])
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
        SetButtonArt(Button, DungeonButtonUp, DungeonButtonDown, DungeonButtonHighlight)
        Button.Name = Private:CreateDungeonJournalText(Button, "QuestTitleFontBlackShadow")
        Button.Name:SetWidth(150)
        Button.Name:SetPoint("TOP", Button, "TOP", 0, -15)
        Button.Levels = Private:CreateDungeonJournalText(Button, "GameFontNormal")
        Button.Levels:SetPoint("BOTTOMLEFT", Button, "BOTTOMLEFT", 7, 7)
        Button.New = Private:CreateDungeonJournalText(Button, "GameFontGreen")
        Button.New:SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -7, 7)
        Button.New:SetText("New")
        Button:SetScript("OnClick", function() Private.DungeonJournal:SelectDungeon(Button.Dungeon) end)
        Button:SetScript("OnEnter", DungeonButton_OnEnter)
        Button:SetScript("OnLeave", GameTooltip_Hide)
    end

    Button.Dungeon = Dungeon
    SetDungeonArt(Button.Art, Dungeon, DungeonCard, LoadingScreenCard)
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
        SetButtonArt(Button, BossButtonUp, BossButtonDown, BossButtonHighlight)
        Button.Portrait = Button:CreateTexture(nil, "OVERLAY")
        Button.Portrait:SetSize(128, 64)
        Button.Portrait:SetPoint("TOPLEFT", Button, "TOPLEFT", -4, 13)
        Button.DungeonArt = Button:CreateTexture(nil, "OVERLAY")
        Button.DungeonArt:SetSize(58, 43)
        Button.DungeonArt:SetPoint("TOP", Button, "TOPLEFT", 35, -7)
        local DungeonArtMask = Button:CreateMaskTexture()
        DungeonArtMask:SetSize(58, 58)
        DungeonArtMask:SetPoint("TOP", Button.DungeonArt, "TOP")
        DungeonArtMask:SetTexture(PortraitMask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        Button.DungeonArt:AddMaskTexture(DungeonArtMask)
        Button.Name = Private:CreateDungeonJournalText(Button, "GameFontNormalMed3")
        Button.Name:SetSize(160, 40)
        Button.Name:SetPoint("LEFT", Button, "LEFT", 105, -3)
        Button.Name:SetJustifyH("LEFT")
        Button.Name:SetTextColor(0.827, 0.659, 0.463)
        Button:SetScript("OnClick", BossButton_OnClick)
    end

    Button.Boss = Boss
    Button.Portrait:SetShown(not Boss.All)
    Button.DungeonArt:SetShown(Boss.All == true)
    if Boss.All then
        SetDungeonArt(Button.DungeonArt, Private.DungeonJournal.Dungeon, DungeonThumbnail, LoadingScreenThumbnail)
    elseif not (Boss.Portrait and Button.Portrait:SetTexture(Boss.Portrait)) then
        Button.Portrait:SetTexture(DefaultPortrait)
    end
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
        Row.Icon = Row:CreateTexture(nil, "BACKGROUND")
        Row.Icon:SetSize(42, 42)
        Row.Icon:SetPoint("TOPLEFT", Row, "TOPLEFT", 2, -2)
        Row.Frame = Row:CreateTexture(nil, "BORDER")
        Row.Frame:SetSize(321, 45)
        Row.Frame:SetPoint("LEFT", Row, "LEFT", 0, 0)
        Row.Frame:SetTexture(JournalTextures)
        Row.Frame:SetTexCoord(LootRowFrame[1], LootRowFrame[2], LootRowFrame[3], LootRowFrame[4])
        Row.IconBorder = Row:CreateTexture(nil, "OVERLAY", nil, 1)
        Row.IconBorder:SetAllPoints(Row.Icon)
        Row.IconBorder:SetTexture(IconBorder)
        Row.Name = Private:CreateDungeonJournalText(Row, "GameFontNormalMed3", true)
        Row.Name:SetWidth(250)
        Row.Name:SetPoint("TOPLEFT", Row.Icon, "TOPRIGHT", 7, -7)
        Row.Name:SetJustifyH("LEFT")
        Row.Name:SetWordWrap(false)
        Row.Source = Private:CreateDungeonJournalText(Row, "GameFontBlack", true)
        Row.Source:SetPoint("BOTTOMRIGHT", Row, "BOTTOMRIGHT", -8, 7)
        Row.Source:SetJustifyH("RIGHT")
        Row.Slot = Private:CreateDungeonJournalText(Row, "GameFontBlack", true)
        Row.Slot:SetPoint("BOTTOMLEFT", Row.Icon, "BOTTOMRIGHT", 7, 5)
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
    Row.Icon:SetTexture(Icon or MissingIcon)
    Row.Slot:SetText(Slot)
    Row.Source:SetText(Loot.Boss or "")
    Private.UpdateDungeonJournalLootRow(Row)
end
