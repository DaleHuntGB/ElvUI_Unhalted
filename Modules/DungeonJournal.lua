local Private = select(2, ...)

_G.BINDING_HEADER_UNHALTEDUI = "|cFF1784D1ElvUI|r: |cFF6080FFUnhalted|r"
_G.BINDING_NAME_UNHALTEDUI_DUNGEONJOURNAL = "Toggle Dungeon Journal"

local Armour = Enum.ItemArmorSubclass
local Weapon = Enum.ItemWeaponSubclass

local ClassArmour = {
    WARRIOR = { [Armour.Mail] = true, [Armour.Plate] = true, [Armour.Shield] = true },
    PALADIN = { [Armour.Mail] = true, [Armour.Plate] = true, [Armour.Shield] = true, [Armour.Libram] = true },
    HUNTER = { [Armour.Leather] = true, [Armour.Mail] = true },
    ROGUE = { [Armour.Leather] = true },
    PRIEST = { [Armour.Cloth] = true },
    SHAMAN = { [Armour.Leather] = true, [Armour.Mail] = true, [Armour.Shield] = true, [Armour.Totem] = true },
    MAGE = { [Armour.Cloth] = true },
    WARLOCK = { [Armour.Cloth] = true },
    DRUID = { [Armour.Leather] = true, [Armour.Idol] = true },
}

local ClassWeapons = {
    WARRIOR = { [Weapon.Axe1H] = true, [Weapon.Axe2H] = true, [Weapon.Bows] = true, [Weapon.Guns] = true, [Weapon.Mace1H] = true, [Weapon.Mace2H] = true, [Weapon.Polearm] = true, [Weapon.Sword1H] = true, [Weapon.Sword2H] = true, [Weapon.Staff] = true, [Weapon.Unarmed] = true, [Weapon.Dagger] = true, [Weapon.Thrown] = true, [Weapon.Crossbow] = true },
    PALADIN = { [Weapon.Axe1H] = true, [Weapon.Axe2H] = true, [Weapon.Mace1H] = true, [Weapon.Mace2H] = true, [Weapon.Polearm] = true, [Weapon.Sword1H] = true, [Weapon.Sword2H] = true },
    HUNTER = { [Weapon.Axe1H] = true, [Weapon.Axe2H] = true, [Weapon.Bows] = true, [Weapon.Guns] = true, [Weapon.Polearm] = true, [Weapon.Sword1H] = true, [Weapon.Sword2H] = true, [Weapon.Staff] = true, [Weapon.Unarmed] = true, [Weapon.Dagger] = true, [Weapon.Thrown] = true, [Weapon.Crossbow] = true },
    ROGUE = { [Weapon.Bows] = true, [Weapon.Guns] = true, [Weapon.Mace1H] = true, [Weapon.Sword1H] = true, [Weapon.Unarmed] = true, [Weapon.Dagger] = true, [Weapon.Thrown] = true, [Weapon.Crossbow] = true },
    PRIEST = { [Weapon.Mace1H] = true, [Weapon.Staff] = true, [Weapon.Dagger] = true, [Weapon.Wand] = true },
    SHAMAN = { [Weapon.Axe1H] = true, [Weapon.Axe2H] = true, [Weapon.Mace1H] = true, [Weapon.Mace2H] = true, [Weapon.Staff] = true, [Weapon.Unarmed] = true, [Weapon.Dagger] = true },
    MAGE = { [Weapon.Sword1H] = true, [Weapon.Staff] = true, [Weapon.Dagger] = true, [Weapon.Wand] = true },
    WARLOCK = { [Weapon.Sword1H] = true, [Weapon.Staff] = true, [Weapon.Dagger] = true, [Weapon.Wand] = true },
    DRUID = { [Weapon.Mace1H] = true, [Weapon.Mace2H] = true, [Weapon.Staff] = true, [Weapon.Unarmed] = true, [Weapon.Dagger] = true },
}

local NoHoldable = { WARRIOR = true, HUNTER = true, ROGUE = true }

local LootSlots = { "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger", "Trinket", "Main Hand", "Off Hand", "Ranged", "Other" }

local EquipLocSlots = {
    INVTYPE_HEAD = "Head", INVTYPE_NECK = "Neck", INVTYPE_SHOULDER = "Shoulder", INVTYPE_CLOAK = "Back",
    INVTYPE_CHEST = "Chest", INVTYPE_ROBE = "Chest", INVTYPE_WRIST = "Wrist", INVTYPE_HAND = "Hands",
    INVTYPE_WAIST = "Waist", INVTYPE_LEGS = "Legs", INVTYPE_FEET = "Feet", INVTYPE_FINGER = "Finger", INVTYPE_TRINKET = "Trinket",
    INVTYPE_WEAPON = "Main Hand", INVTYPE_2HWEAPON = "Main Hand", INVTYPE_WEAPONMAINHAND = "Main Hand",
    INVTYPE_WEAPONOFFHAND = "Off Hand", INVTYPE_SHIELD = "Off Hand", INVTYPE_HOLDABLE = "Off Hand",
    INVTYPE_RANGED = "Ranged", INVTYPE_RANGEDRIGHT = "Ranged", INVTYPE_THROWN = "Ranged", INVTYPE_RELIC = "Ranged",
}

local DungeonButtonUp = { 0.00195313, 0.34179688, 0.42871094, 0.52246094 }
local DungeonButtonDown = { 0.00195313, 0.34179688, 0.33300781, 0.42675781 }
local DungeonButtonHighlight = { 0.34570313, 0.68554688, 0.33300781, 0.42675781 }
local BossButtonUp = { 0.00195313, 0.63671875, 0.21386719, 0.26757813 }
local BossButtonDown = { 0.00195313, 0.63671875, 0.10253906, 0.15625000 }
local BossButtonHighlight = { 0.00195313, 0.63671875, 0.15820313, 0.21191406 }
local DungeonCard = { 0, 0.68359375, 0, 0.7421875 }
local DungeonThumbnail = { 0.18359375, 0.5, 0.13671875, 0.60546875 }
local LoadingScreenCard = { 0.1534, 0.8466, 0.1603, 0.8397 }
local LoadingScreenThumbnail = { 0.2421, 0.7579, 0.1603, 0.8397 }
local AllBosses = { Name = "All Bosses", All = true }
local AllRecipes = { Name = "Recipes & Patterns", All = true, Recipes = true }
local LevelBrackets = { { 10, 19 }, { 20, 29 }, { 30, 39 }, { 40, 49 }, { 50, 60 } }
local QuestieDB = Private:GetQuestieDB()
local JournalSources, ItemSources = {}, {}

-- [[ Filters ]]
local function IsLootShown(ItemID, ClassFile, Slot)
    local _, _, _, EquipLoc, _, ClassID, SubClassID = C_Item.GetItemInfoInstant(ItemID)
    if Slot and (EquipLocSlots[EquipLoc] or "Other") ~= Slot then return false end
    if not ClassFile or not ClassArmour[ClassFile] then return true end
    if ClassID == Enum.ItemClass.Weapon then return ClassWeapons[ClassFile][SubClassID] == true end
    if ClassID ~= Enum.ItemClass.Armor or EquipLoc == "INVTYPE_CLOAK" then return true end
    if EquipLoc == "INVTYPE_HOLDABLE" then return not NoHoldable[ClassFile] end
    return SubClassID == Armour.Generic or ClassArmour[ClassFile][SubClassID] == true
end

local function IsRecipe(ItemID)
    return select(6, C_Item.GetItemInfoInstant(ItemID)) == Enum.ItemClass.Recipe
end

local function GetDungeonJournalBosses(Dungeon, ClassFile, Slot)
    if not Slot then return Dungeon.Bosses end

    local Bosses = {}
    for _, Boss in ipairs(Dungeon.Bosses) do
        for _, ItemID in ipairs(Boss.Loot) do
            if not IsRecipe(ItemID) and IsLootShown(ItemID, ClassFile, Slot) then
                Bosses[#Bosses + 1] = Boss
                break
            end
        end
    end
    return Bosses
end

local function HasDungeonJournalRecipes(Dungeon, ClassFile, Slot)
    for _, Boss in ipairs(Dungeon.Bosses) do
        for _, ItemID in ipairs(Boss.Loot) do
            if IsRecipe(ItemID) and IsLootShown(ItemID, ClassFile, Slot) then return true end
        end
    end
    return false
end

local function GetDungeonJournalDungeons(ShowRaids, Bracket, ClassFile, Slot)
    local Dungeons = {}
    for _, Dungeon in ipairs(Private.DungeonJournalData) do
        if (Dungeon.Raid == true) == ShowRaids then
            local InBracket = ShowRaids or not Bracket or (Dungeon.Levels[1] <= Bracket[2] and Dungeon.Levels[2] >= Bracket[1])
            local HasLoot = not Slot or #GetDungeonJournalBosses(Dungeon, ClassFile, Slot) > 0 or HasDungeonJournalRecipes(Dungeon, ClassFile, Slot)
            if InBracket and HasLoot then Dungeons[#Dungeons + 1] = Dungeon end
        end
    end
    return Dungeons
end

local function GetDungeonJournalLoot(Dungeon, Boss, ClassFile, Slot)
    local Loot, Seen, Total = {}, {}, 0
    local Bosses = Boss.All and Dungeon.Bosses or { Boss }
    local Recipes = Boss.Recipes == true

    for _, Source in ipairs(Bosses) do
        for _, ItemID in ipairs(Source.Loot) do
            local Entry = Seen[ItemID]
            if Entry then
                if Boss.All and Entry.Boss ~= Source.Name then Entry.Boss = "Multiple Bosses" end
            elseif IsRecipe(ItemID) == Recipes then
                Total = Total + 1
                Entry = { ItemID = ItemID, Boss = Boss.All and Source.Name or nil }
                Seen[ItemID] = Entry
                if IsLootShown(ItemID, ClassFile, Slot) then Loot[#Loot + 1] = Entry end
            end
        end
    end

    return Loot, Total
end

-- [[ Portraits ]]
local function ParkPortrait(Journal, Texture)
    if Texture.Button then Texture:RemoveMaskTexture(Texture.Button.ArtMask) end
    Texture.Button = nil
    Texture:SetParent(Journal.PortraitHolder)
    Texture:ClearAllPoints()
    Texture:SetAllPoints(Journal.PortraitHolder)
end

local function UpdateBossPortrait(Button)
    local Texture = Private.DungeonJournal.Portraits[Button.Boss]
    local isReady = Texture ~= nil and Texture.ReadyAt <= GetTime()
    if isReady and Texture.Button ~= Button then
        if Texture.Button then ParkPortrait(Private.DungeonJournal, Texture) end
        Texture:SetParent(Button)
        Texture:ClearAllPoints()
        Texture:SetPoint("TOP", Button, "TOPLEFT", 35, -7)
        Texture:SetSize(58, 43)
        Texture:SetTexCoord(0, 1, 0, 43 / 58)
        Texture:AddMaskTexture(Button.ArtMask)
        Texture.Button = Button
    end
    Button.Portrait:SetShown(not Button.Boss.All and not isReady)
end

local function RefreshBossPortraits()
    local Journal = Private.DungeonJournal
    if Journal:IsShown() then Journal.BossList:ForEachFrame(UpdateBossPortrait) end
end

local function ResetBossButton(Button)
    local Texture = Private.DungeonJournal.Portraits[Button.Boss]
    if Texture and Texture.Button == Button then ParkPortrait(Private.DungeonJournal, Texture) end
end

local function ReleaseBossPortraits(Journal)
    for _, Texture in pairs(Journal.Portraits) do
        ParkPortrait(Journal, Texture)
        Texture:SetTexture(nil)
        Journal.SparePortraits[#Journal.SparePortraits + 1] = Texture
    end
    wipe(Journal.Portraits)
    Journal.PortraitDungeon = nil
end

local function RenderBossPortraits(Journal)
    if Journal.PortraitDungeon ~= Journal.Dungeon then ReleaseBossPortraits(Journal) end
    Journal.PortraitDungeon = Journal.Dungeon

    local ReadyAt, isRendering = GetTime() + 3, false
    for _, Boss in ipairs(Journal.Dungeon.Bosses) do
        if Boss.DisplayID and not Journal.Portraits[Boss] then
            local Texture = table.remove(Journal.SparePortraits) or Journal.PortraitHolder:CreateTexture(nil, "OVERLAY")
            Texture:SetAllPoints(Journal.PortraitHolder)
            SetPortraitTextureFromCreatureDisplayID(Texture, Boss.DisplayID)
            Texture.ReadyAt = ReadyAt
            Journal.Portraits[Boss] = Texture
            isRendering = true
        end
    end
    Journal.BossList:ForEachFrame(UpdateBossPortrait)
    if isRendering then C_Timer.After(3, RefreshBossPortraits) end
end

-- [[ Rows ]]
local function CreateDungeonJournalText(Parent, Template, OnParchment)
    local Text = Parent:CreateFontString(nil, "OVERLAY", Template)
    local Path, Size = Text:GetFont()
    Text:SetFont(Path, Size, OnParchment and "SLUG" or "OUTLINE, SLUG")
    Text:SetShadowOffset(0, 0)
    if OnParchment then Text:SetTextColor(0.25, 0.1484375, 0.02) end
    return Text
end

local function SetButtonArt(Button, Coords, Pushed, Highlight)
    Button:SetNormalTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    Button:GetNormalTexture():SetTexCoord(Coords[1], Coords[2], Coords[3], Coords[4])
    Button:SetPushedTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    Button:GetPushedTexture():SetTexCoord(Pushed[1], Pushed[2], Pushed[3], Pushed[4])
    Button:SetHighlightTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    Button:GetHighlightTexture():SetTexCoord(Highlight[1], Highlight[2], Highlight[3], Highlight[4])
end

local function SetDungeonArt(Texture, Dungeon, Coords, LoadingScreenCoords)
    if Dungeon.LoadingScreen and Texture:SetTexture(Dungeon.LoadingScreen) then
        Texture:SetTexCoord(LoadingScreenCoords[1], LoadingScreenCoords[2], LoadingScreenCoords[3], LoadingScreenCoords[4])
        return
    end
    if not (Dungeon.Button and Texture:SetTexture(Dungeon.Button)) then Texture:SetTexture("Interface\\EncounterJournal\\UI-EJ-DUNGEONBUTTON-Default") end
    Texture:SetTexCoord(Coords[1], Coords[2], Coords[3], Coords[4])
end

local function FormatDungeonJournalLevels(Dungeon, LevelFormat)
    if Dungeon.Raid then return string.format("%d Players", Dungeon.Size) end
    return string.format(LevelFormat, Dungeon.Levels[1], Dungeon.Levels[2])
end

local function DungeonButton_OnEnter(Button)
    local Dungeon = Button.Dungeon
    GameTooltip:SetOwner(Button, "ANCHOR_RIGHT")
    GameTooltip:SetText(Dungeon.Name, 1, 1, 1)
    GameTooltip:AddLine(FormatDungeonJournalLevels(Dungeon, "Level %d-%d"))
    GameTooltip:AddLine(Dungeon.Zone, 0.8, 0.8, 0.8)
    GameTooltip:Show()
end

local function InitDungeonJournalDungeonButton(Button, Dungeon)
    if not Button.Name then
        Button.Art = Button:CreateTexture(nil, "BACKGROUND")
        Button.Art:SetAllPoints(Button)
        SetButtonArt(Button, DungeonButtonUp, DungeonButtonDown, DungeonButtonHighlight)
        Button.Name = CreateDungeonJournalText(Button, "QuestTitleFontBlackShadow")
        Button.Name:SetWidth(150)
        Button.Name:SetPoint("TOP", Button, "TOP", 0, -15)
        Button.Levels = CreateDungeonJournalText(Button, "GameFontNormal")
        Button.Levels:SetPoint("BOTTOMLEFT", Button, "BOTTOMLEFT", 7, 7)
        Button.New = CreateDungeonJournalText(Button, "GameFontGreen")
        Button.New:SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -7, 7)
        Button.New:SetText("New")
        Button:SetScript("OnClick", function() Private.DungeonJournal:SelectDungeon(Button.Dungeon) end)
        Button:SetScript("OnEnter", DungeonButton_OnEnter)
        Button:SetScript("OnLeave", GameTooltip_Hide)
    end

    Button.Dungeon = Dungeon
    SetDungeonArt(Button.Art, Dungeon, DungeonCard, LoadingScreenCard)
    Button.Name:SetText(Dungeon.Name)
    Button.Levels:SetText(FormatDungeonJournalLevels(Dungeon, "%d-%d"))
    Button.New:SetShown(Dungeon.New == true)
end

local function BossButton_OnClick(Button)
    Private.DungeonJournal:SelectBoss(Button.Boss)
end

local function UpdateDungeonJournalBossSelection(Button)
    if Button.Boss == Private.DungeonJournal.Boss then
        Button:LockHighlight()
    else
        Button:UnlockHighlight()
    end
end

local function InitDungeonJournalBossButton(Button, Boss)
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
        DungeonArtMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        Button.DungeonArt:AddMaskTexture(DungeonArtMask)
        Button.ArtMask = DungeonArtMask
        Button.Name = CreateDungeonJournalText(Button, "GameFontNormalMed3")
        Button.Name:SetWidth(160)
        Button.Name:SetPoint("LEFT", Button, "LEFT", 105, -3)
        Button.Name:SetJustifyH("LEFT")
        Button.Name:SetTextColor(0.827, 0.659, 0.463)
        Button:SetScript("OnClick", BossButton_OnClick)
    end

    Button.Boss = Boss
    Button.DungeonArt:SetShown(Boss.All == true)
    if Boss.Recipes then
        Button.DungeonArt:SetTexture("Interface\\Icons\\INV_Scroll_03")
        Button.DungeonArt:SetTexCoord(0.08, 0.92, 0.1886, 0.8114)
    elseif Boss.All then
        SetDungeonArt(Button.DungeonArt, Private.DungeonJournal.Dungeon, DungeonThumbnail, LoadingScreenThumbnail)
    elseif not (Boss.Portrait and Button.Portrait:SetTexture(Boss.Portrait)) then
        Button.Portrait:SetTexture("Interface\\EncounterJournal\\UI-EJ-BOSS-Default")
    end
    UpdateBossPortrait(Button)
    Button.Name:SetText(Boss.Rare and Boss.Name .. "\n|cFF9D9D9D(" .. (Boss.RareLabel or "Rare") .. ")|r" or Boss.Name)
    UpdateDungeonJournalBossSelection(Button)
end

local function UpdateDungeonJournalLootRow(Row)
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

local function InitDungeonJournalLootRow(Row, Loot)
    if not Row.Icon then
        Row.Icon = Row:CreateTexture(nil, "BACKGROUND")
        Row.Icon:SetSize(42, 42)
        Row.Icon:SetPoint("TOPLEFT", Row, "TOPLEFT", 2, -2)
        Row.Frame = Row:CreateTexture(nil, "BORDER")
        Row.Frame:SetSize(321, 45)
        Row.Frame:SetPoint("LEFT", Row, "LEFT", 0, 0)
        Row.Frame:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
        Row.Frame:SetTexCoord(0.00195313, 0.62890625, 0.61816406, 0.66210938)
        Row.IconBorder = Row:CreateTexture(nil, "OVERLAY", nil, 1)
        Row.IconBorder:SetAllPoints(Row.Icon)
        Row.IconBorder:SetTexture("Interface\\Common\\WhiteIconFrame")
        Row.Name = CreateDungeonJournalText(Row, "GameFontNormalMed3", true)
        Row.Name:SetWidth(250)
        Row.Name:SetPoint("TOPLEFT", Row.Icon, "TOPRIGHT", 7, -7)
        Row.Name:SetJustifyH("LEFT")
        Row.Name:SetWordWrap(false)
        Row.Source = CreateDungeonJournalText(Row, "GameFontBlack", true)
        Row.Source:SetPoint("BOTTOMRIGHT", Row, "BOTTOMRIGHT", -8, 7)
        Row.Source:SetJustifyH("RIGHT")
        Row.Slot = CreateDungeonJournalText(Row, "GameFontBlack", true)
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
    Row.Icon:SetTexture(Icon or 134400)
    Row.Slot:SetText(Slot)
    Row.Source:SetText(Loot.Boss or "")
    UpdateDungeonJournalLootRow(Row)
end

-- [[ Window ]]
local function RefreshReceivedLootRow(Row)
    if Row.ItemID == Private.DungeonJournal.ReceivedItemID then UpdateDungeonJournalLootRow(Row) end
end

local function Journal_RefreshLoot(Journal)
    local Loot, Total = GetDungeonJournalLoot(Journal.Dungeon, Journal.Boss, Journal.ClassFilter, Journal.SlotFilter)
    Journal.LootList:SetDataProvider(CreateDataProvider(Loot))
    Journal.BossTitle:SetText(Journal.Boss.Name)

    local InstanceType = Journal.Dungeon.Raid and "raid" or "dungeon"
    if #Journal.Dungeon.Bosses == 0 then
        Journal.LootEmpty:SetFormattedText("The bosses for this %s haven't been published yet.", InstanceType)
    elseif Total == 0 then
        Journal.LootEmpty:SetFormattedText("The loot for this %s hasn't been published yet.", Journal.Boss.All and InstanceType or "boss")
    else
        Journal.LootEmpty:SetText("No loot matches the current filters.")
    end
    Journal.LootEmpty:SetShown(#Loot == 0)
end

local function Journal_RefreshBosses(Journal)
    local Bosses = GetDungeonJournalBosses(Journal.Dungeon, Journal.ClassFilter, Journal.SlotFilter)
    local HasRecipes = HasDungeonJournalRecipes(Journal.Dungeon, Journal.ClassFilter, Journal.SlotFilter)

    local Provider = CreateDataProvider()
    if #Bosses > 0 or HasRecipes then
        Provider:Insert(AllBosses)
        if HasRecipes then Provider:Insert(AllRecipes) end
        Provider:InsertTable(Bosses)
    end
    if not Provider:FindIndex(Journal.Boss) then Journal.Boss = AllBosses end
    Journal.BossList:SetDataProvider(Provider)
    Journal_RefreshLoot(Journal)
end

local function Journal_ShowDungeons(Journal)
    Journal.Dungeon = nil
    Journal.Encounter:Hide()
    Journal.BackButton:Hide()
    Journal.DungeonSelect:Show()
end

local function Journal_Refresh(Journal)
    local Dungeons = GetDungeonJournalDungeons(Journal.ShowRaids, Journal.LevelFilter, Journal.ClassFilter, Journal.SlotFilter)
    Journal.DungeonGrid:SetDataProvider(CreateDataProvider(Dungeons))
    Journal.DungeonsEmpty:SetText(Journal.ShowRaids and "No raids match the current filters." or "No dungeons match the current filters.")
    Journal.DungeonsEmpty:SetShown(#Dungeons == 0)

    if tContains(Dungeons, Journal.Dungeon) then
        Journal_RefreshBosses(Journal)
    else
        Journal_ShowDungeons(Journal)
    end
end

local function Journal_SetTab(Journal, ShowRaids)
    Journal.ShowRaids = ShowRaids
    PanelTemplates_SetTab(Journal, (ShowRaids and Journal.RaidsTab or Journal.DungeonsTab):GetID())
    Journal.LevelDropdown:SetEnabled(not ShowRaids)
    Journal_Refresh(Journal)
end

local function Journal_SelectDungeon(Journal, Dungeon)
    if (Dungeon.Raid == true) ~= Journal.ShowRaids then Journal_SetTab(Journal, Dungeon.Raid == true) end
    Journal.Dungeon = Dungeon
    Journal.Boss = AllBosses
    Journal.DungeonTitle:SetText(Dungeon.Name)
    Journal.DungeonLevels:SetText(FormatDungeonJournalLevels(Dungeon, "Level %d-%d"))
    Journal.DungeonSelect:Hide()
    Journal.Encounter:Show()
    Journal.BackButton:Show()
    Journal_RefreshBosses(Journal)
    RenderBossPortraits(Journal)
end

local function Journal_SelectBoss(Journal, Boss)
    Journal.Boss = Boss
    Journal.BossList:ForEachFrame(UpdateDungeonJournalBossSelection)
    Journal_RefreshLoot(Journal)
end

local function Journal_OnShow(Journal)
    Journal:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)

    local InstanceName, InstanceType = GetInstanceInfo()
    if InstanceType == "party" or InstanceType == "raid" then
        for _, Dungeon in ipairs(Private.DungeonJournalData) do
            if Dungeon.Name == InstanceName and Dungeon ~= Journal.Dungeon then Journal_SelectDungeon(Journal, Dungeon) end
        end
    end
    if Journal.Dungeon then RenderBossPortraits(Journal) end
end

local function Journal_OnHide(Journal)
    Journal:UnregisterEvent("ITEM_DATA_LOAD_RESULT")
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    ReleaseBossPortraits(Journal)
end

local function Journal_OnEvent(Journal, _, ItemID, Success)
    if not Success or not Journal.Dungeon then return end
    Journal.ReceivedItemID = ItemID
    Journal.LootList:ForEachFrame(RefreshReceivedLootRow)
end

local function BackButton_OnClick()
    Journal_ShowDungeons(Private.DungeonJournal)
end

local function BackButton_OnEnter(Button)
    GameTooltip:SetOwner(Button, "ANCHOR_RIGHT")
    GameTooltip:SetText(BACK)
    GameTooltip:Show()
end

local function Tab_OnClick(Tab)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    Journal_SetTab(Private.DungeonJournal, Tab == Private.DungeonJournal.RaidsTab)
end

local function CreateJournalTab(Journal, ID, Text)
    local Tab = CreateFrame("Button", nil, Journal, "PanelTabButtonTemplate")
    Tab:SetID(ID)
    Tab:SetText(Text)
    Tab:SetScript("OnClick", Tab_OnClick)
    return Tab
end

local function Filter_IsSelected(Option)
    return Private.DungeonJournal[Option.Key] == Option.Value
end

local function Filter_SetSelected(Option)
    Private.DungeonJournal[Option.Key] = Option.Value
    Journal_Refresh(Private.DungeonJournal)
end

local function CreateFilterDropdown(Journal, Width, Options)
    local Dropdown = CreateFrame("DropdownButton", nil, Journal, "WowStyle1DropdownTemplate")
    Dropdown:SetWidth(Width)
    Dropdown:SetupMenu(function(_, RootDescription)
        for _, Option in ipairs(Options) do
            RootDescription:CreateRadio(Option.Text, Filter_IsSelected, Filter_SetSelected, Option)
        end
    end)
    return Dropdown
end

local function CreateScrollList(Parent, View)
    local ScrollBox = CreateFrame("Frame", nil, Parent, "WowScrollBoxList")
    ScrollBox:Init(View)
    return ScrollBox
end

-- [[ Item Sources ]]
local function GetItemSources(ItemID)
    local ItemClassID = select(6, C_Item.GetItemInfoInstant(ItemID))
    if ItemClassID ~= Enum.ItemClass.Weapon and ItemClassID ~= Enum.ItemClass.Armor and ItemClassID ~= Enum.ItemClass.Recipe then return false end

    local Lines = {}
    for _, Line in ipairs(JournalSources[ItemID] or {}) do Lines[#Lines + 1] = Line end
    if not QuestieDB or not QuestieDB.Item.Exists(ItemID) then return Lines[1] and Lines or false end

    local Item, Npc, Quest = QuestieDB.Item, QuestieDB.Npc, QuestieDB.Quest
    local _, _, RaceID = UnitRace("player")
    local _, _, ClassID = UnitClass("player")
    local RaceBit, ClassBit = QuestieDB.Enum.raceMaskById[RaceID], 2 ^ (ClassID - 1)
    local Faction = UnitFactionGroup("player") == "Horde" and "H" or "A"
    local Drops, Quests, Vendors = {}, {}, {}

    local DropNpcs = not JournalSources[ItemID] and Item.npcDrops(ItemID) or {}
    if #DropNpcs > 50 then
        Lines[#Lines + 1] = "|c" .. Private.E.AccentColour .. "Source:|r World Drop"
    elseif DropNpcs[1] then
        local Rates, DropRates = {}, Private:GetQuestieItem(ItemID)[1]
        for Index = 1, #DropRates, 2 do Rates[DropRates[Index]] = DropRates[Index + 1] end
        for _, NpcID in ipairs(DropNpcs) do
            if Npc.Exists(NpcID) then Drops[#Drops + 1] = { Npc.name(NpcID), Npc.zoneID(NpcID), Rates[NpcID] or 0 } end
        end
    end
    for _, QuestID in ipairs(Item.questRewards(ItemID) or {}) do
        local Races, Classes = Quest.requiredRaces(QuestID), Quest.requiredClasses(QuestID)
        if not Private.HiddenQuests[QuestID] and Quest.Exists(QuestID) and (Races == 0 or Races % (RaceBit * 2) >= RaceBit) and (Classes == 0 or Classes % (ClassBit * 2) >= ClassBit) then
            Quests[#Quests + 1] = { Quest.name(QuestID), Quest.zoneOrSort(QuestID), 0 }
        end
    end
    for _, NpcID in ipairs(Item.vendors(ItemID) or {}) do
        if (Npc.friendlyToFaction(NpcID) or ""):find(Faction, 1, true) then Vendors[#Vendors + 1] = { Npc.name(NpcID), Npc.zoneID(NpcID), 0 } end
    end

    local CurrentZone = GetRealZoneText()
    for _, Kind in ipairs({ { Drops }, { Quests, "Quest" }, { Vendors, "Vendor" } }) do
        local Sources, BestIndex, BestScore = Kind[1], 0, -1
        for Index, Source in ipairs(Sources) do
            local Score = Source[2] > 0 and C_Map.GetAreaInfo(Source[2]) == CurrentZone and Source[3] + 1000 or Source[3]
            if Score > BestScore then BestIndex, BestScore = Index, Score end
        end
        local Best = Sources[BestIndex]
        if Best then
            local Zone = Best[2] > 0 and C_Map.GetAreaInfo(Best[2])
            local Note = #Sources > 1 and (Kind[2] and Kind[2] .. ", +" or "+") .. (#Sources - 1) .. " more" or Kind[2]
            Lines[#Lines + 1] = "|c" .. Private.E.AccentColour .. "Source:|r " .. Best[1] .. (Zone and " - " .. Zone or "") .. (Note and " (" .. Note .. ")" or "")
        end
    end

    return Lines[1] and Lines or false
end

local function ItemTooltip_PostCall(Tooltip, Data)
    if Tooltip ~= GameTooltip and Tooltip ~= ItemRefTooltip then return end
    local ItemID = Data.id
    if Private:IsSecret(ItemID) or not ItemID then return end

    local Lines = ItemSources[ItemID]
    if Lines == nil then
        Lines = GetItemSources(ItemID)
        ItemSources[ItemID] = Lines
    end
    if not Lines then return end
    for _, Line in ipairs(Lines) do
        Tooltip:AddLine(Line, 1, 1, 1)
    end
end

-- [[ Setup ]]
function Private:SetupDungeonJournal()
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
    Journal.ClassFilter = select(2, UnitClass("player"))
    local Level = UnitLevel("player")
    for _, Bracket in ipairs(LevelBrackets) do
        if not Journal.LevelFilter and Level <= Bracket[2] then Journal.LevelFilter = Bracket end
    end
    Private.DungeonJournal = Journal

    Journal.Portraits, Journal.SparePortraits = {}, {}
    Journal.PortraitHolder = CreateFrame("Frame", nil, UIParent)
    Journal.PortraitHolder:SetSize(64, 64)
    Journal.PortraitHolder:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", 10000, 0)

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

    local SlotOptions = { { Key = "SlotFilter", Text = "All Slots" } }
    for _, Slot in ipairs(LootSlots) do
        SlotOptions[#SlotOptions + 1] = { Key = "SlotFilter", Text = Slot, Value = Slot }
    end
    local LevelOptions = { { Key = "LevelFilter", Text = "All Levels" } }
    for _, Bracket in ipairs(LevelBrackets) do
        LevelOptions[#LevelOptions + 1] = { Key = "LevelFilter", Text = string.format("Level %d-%d", Bracket[1], Bracket[2]), Value = Bracket }
    end
    local ClassOptions = { { Key = "ClassFilter", Text = ALL_CLASSES } }
    for ClassID = 1, GetNumClasses() do
        local ClassName, ClassFile = GetClassInfo(ClassID)
        if ClassFile and ClassArmour[ClassFile] then
            ClassOptions[#ClassOptions + 1] = { Key = "ClassFilter", Text = RAID_CLASS_COLORS[ClassFile]:WrapTextInColorCode(ClassName), Value = ClassFile }
        end
    end

    local DropdownWidth = (Journal:GetWidth() - 62 - 10 - 2 * 10) / 3
    Journal.SlotDropdown = CreateFilterDropdown(Journal, DropdownWidth, SlotOptions)
    Journal.SlotDropdown:SetPoint("TOPLEFT", Journal, "TOPLEFT", 62, -29)
    Journal.LevelDropdown = CreateFilterDropdown(Journal, DropdownWidth, LevelOptions)
    Journal.LevelDropdown:SetPoint("LEFT", Journal.SlotDropdown, "RIGHT", 10, 0)
    Journal.ClassDropdown = CreateFilterDropdown(Journal, DropdownWidth, ClassOptions)
    Journal.ClassDropdown:SetPoint("LEFT", Journal.LevelDropdown, "RIGHT", 10, 0)

    Journal.DungeonsTab = CreateJournalTab(Journal, 1, "Dungeons")
    Journal.DungeonsTab:SetPoint("TOPLEFT", Journal, "BOTTOMLEFT", 11, 2)
    Journal.RaidsTab = CreateJournalTab(Journal, 2, "Raids")
    Journal.Tabs = { Journal.DungeonsTab, Journal.RaidsTab }
    PanelTemplates_SetNumTabs(Journal, #Journal.Tabs)

    local DungeonSelect = CreateFrame("Frame", nil, Journal)
    DungeonSelect:SetPoint("TOPLEFT", Journal.Inset, "TOPLEFT", 0, -2)
    DungeonSelect:SetPoint("BOTTOMRIGHT", Journal.Inset, "BOTTOMRIGHT", -3, 0)
    Journal.DungeonSelect = DungeonSelect

    local Parchment = C_Texture.GetAtlasInfo("spellbook-Page-Right-C60")
    local Background = DungeonSelect:CreateTexture(nil, "BACKGROUND")
    Background:SetAllPoints(DungeonSelect)
    Background:SetTexture(Parchment.file)
    Background:SetTexCoord(Parchment.leftTexCoord, Parchment.rightTexCoord, Parchment.topTexCoord + (Parchment.bottomTexCoord - Parchment.topTexCoord) * 46 / 682, Parchment.bottomTexCoord)

    local DungeonView = CreateScrollBoxListGridView(4, 5, 0, 0, 0, 15, 15)
    DungeonView:SetElementInitializer("Button", InitDungeonJournalDungeonButton)
    DungeonView:SetElementSizeCalculator(function() return 174, 96 end)
    Journal.DungeonGrid = CreateScrollList(DungeonSelect, DungeonView)
    Journal.DungeonGrid:SetPoint("TOPLEFT", DungeonSelect, "TOPLEFT", 18, -14)
    Journal.DungeonGrid:SetPoint("BOTTOMRIGHT", DungeonSelect, "BOTTOMRIGHT", -26, 6)

    Journal.DungeonsEmpty = CreateDungeonJournalText(DungeonSelect, "GameFontHighlightLarge", true)
    Journal.DungeonsEmpty:SetPoint("CENTER", DungeonSelect, "CENTER", 0, 0)

    local Encounter = CreateFrame("Frame", nil, Journal)
    Encounter:SetSize(785, 425)
    Encounter:SetPoint("BOTTOMRIGHT", Journal.Inset, "BOTTOMRIGHT", -4, 2)
    Encounter:Hide()
    Journal.Encounter = Encounter

    local EncounterBackground = Encounter:CreateTexture(nil, "BACKGROUND")
    EncounterBackground:SetAllPoints(Encounter)
    EncounterBackground:SetTexture("Interface\\EncounterJournal\\UI-EJ-JournalBG")
    EncounterBackground:SetTexCoord(0, 0.7666015625, 0, 0.830078125)

    local Header = Encounter:CreateTexture(nil, "BORDER")
    Header:SetSize(386, 39)
    Header:SetPoint("TOPLEFT", Encounter, "TOPLEFT", 0, -11)
    Header:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    Header:SetTexCoord(0, 0.755859375, 0.9599609375, 1)

    Journal.DungeonTitle = CreateDungeonJournalText(Encounter, "GameFontNormalLarge")
    Journal.DungeonTitle:SetPoint("TOPLEFT", Encounter, "TOPLEFT", 28, -24)
    Journal.DungeonTitle:SetTextColor(0.902, 0.788, 0.671)
    Journal.DungeonLevels = CreateDungeonJournalText(Encounter, "GameFontHighlightSmall")
    Journal.DungeonLevels:SetPoint("BOTTOMLEFT", Journal.DungeonTitle, "BOTTOMRIGHT", 8, 1)

    local BossView = CreateScrollBoxListLinearView(15, 0, 0, 20, 15)
    BossView:SetElementExtent(55)
    BossView:SetElementInitializer("Button", InitDungeonJournalBossButton)
    BossView:SetElementResetter(ResetBossButton)
    Journal.BossList = CreateScrollList(Encounter, BossView)
    Journal.BossList:SetSize(338, 372)
    Journal.BossList:SetPoint("BOTTOMLEFT", Encounter, "BOTTOMLEFT", 25, 1)

    local LootView = CreateScrollBoxListLinearView(0, 0, 0, 0, 3)
    LootView:SetElementExtent(45)
    LootView:SetElementInitializer("Button", InitDungeonJournalLootRow)
    Journal.LootList = CreateScrollList(Encounter, LootView)
    Journal.LootList:SetSize(330, 372)
    Journal.LootList:SetPoint("BOTTOMRIGHT", Encounter, "BOTTOMRIGHT", -20, 1)

    Journal.BossTitle = CreateDungeonJournalText(Encounter, "GameFontNormalLarge", true)
    Journal.BossTitle:SetPoint("BOTTOMLEFT", Journal.LootList, "TOPLEFT", 4, 16)

    Journal.LootEmpty = CreateDungeonJournalText(Encounter, "GameFontHighlight", true)
    Journal.LootEmpty:SetPoint("CENTER", Journal.LootList, "CENTER", 0, 0)
    Journal.LootEmpty:SetWidth(300)

    Journal_SetTab(Journal, false)

    Journal:SetScript("OnShow", Journal_OnShow)
    Journal:SetScript("OnHide", Journal_OnHide)
    Journal:SetScript("OnEvent", Journal_OnEvent)

    for _, Dungeon in ipairs(Private.DungeonJournalData) do
        local DungeonSources = {}
        for _, Boss in ipairs(Dungeon.Bosses) do
            for _, ItemID in ipairs(Boss.Loot) do
                local Source = DungeonSources[ItemID]
                DungeonSources[ItemID] = Source and Source ~= Boss.Name and "Multiple Bosses" or Boss.Name
            end
        end
        for ItemID, Source in pairs(DungeonSources) do
            JournalSources[ItemID] = JournalSources[ItemID] or {}
            table.insert(JournalSources[ItemID], "|c" .. Private.E.AccentColour .. "Source:|r " .. Source .. " - " .. Dungeon.Name)
        end
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, ItemTooltip_PostCall)

    if QuestieDB then
        local ZoneWatcher = CreateFrame("Frame")
        ZoneWatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        ZoneWatcher:SetScript("OnEvent", function() wipe(ItemSources) end)
    end
end
