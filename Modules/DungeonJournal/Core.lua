local Private = select(2, ...)

_G.BINDING_HEADER_UNHALTEDUI = "|cFF6080FFUnhalted|r|cFF808080UI|r"
_G.BINDING_NAME_UNHALTEDUI_DUNGEONJOURNAL = "Toggle Dungeon Journal"

local ARMOUR = Enum.ItemArmorSubclass
local WEAPON = Enum.ItemWeaponSubclass

local CLASS_ARMOUR = {
    WARRIOR = { [ARMOUR.Mail] = true, [ARMOUR.Plate] = true, [ARMOUR.Shield] = true },
    PALADIN = { [ARMOUR.Mail] = true, [ARMOUR.Plate] = true, [ARMOUR.Shield] = true, [ARMOUR.Libram] = true },
    HUNTER = { [ARMOUR.Leather] = true, [ARMOUR.Mail] = true },
    ROGUE = { [ARMOUR.Leather] = true },
    PRIEST = { [ARMOUR.Cloth] = true },
    SHAMAN = { [ARMOUR.Leather] = true, [ARMOUR.Mail] = true, [ARMOUR.Shield] = true, [ARMOUR.Totem] = true },
    MAGE = { [ARMOUR.Cloth] = true },
    WARLOCK = { [ARMOUR.Cloth] = true },
    DRUID = { [ARMOUR.Leather] = true, [ARMOUR.Idol] = true },
}

local CLASS_WEAPONS = {
    WARRIOR = { [WEAPON.Axe1H] = true, [WEAPON.Axe2H] = true, [WEAPON.Bows] = true, [WEAPON.Guns] = true, [WEAPON.Mace1H] = true, [WEAPON.Mace2H] = true, [WEAPON.Polearm] = true, [WEAPON.Sword1H] = true, [WEAPON.Sword2H] = true, [WEAPON.Staff] = true, [WEAPON.Unarmed] = true, [WEAPON.Dagger] = true, [WEAPON.Thrown] = true, [WEAPON.Crossbow] = true },
    PALADIN = { [WEAPON.Axe1H] = true, [WEAPON.Axe2H] = true, [WEAPON.Mace1H] = true, [WEAPON.Mace2H] = true, [WEAPON.Polearm] = true, [WEAPON.Sword1H] = true, [WEAPON.Sword2H] = true },
    HUNTER = { [WEAPON.Axe1H] = true, [WEAPON.Axe2H] = true, [WEAPON.Bows] = true, [WEAPON.Guns] = true, [WEAPON.Polearm] = true, [WEAPON.Sword1H] = true, [WEAPON.Sword2H] = true, [WEAPON.Staff] = true, [WEAPON.Unarmed] = true, [WEAPON.Dagger] = true, [WEAPON.Thrown] = true, [WEAPON.Crossbow] = true },
    ROGUE = { [WEAPON.Bows] = true, [WEAPON.Guns] = true, [WEAPON.Mace1H] = true, [WEAPON.Sword1H] = true, [WEAPON.Unarmed] = true, [WEAPON.Dagger] = true, [WEAPON.Thrown] = true, [WEAPON.Crossbow] = true },
    PRIEST = { [WEAPON.Mace1H] = true, [WEAPON.Staff] = true, [WEAPON.Dagger] = true, [WEAPON.Wand] = true },
    SHAMAN = { [WEAPON.Axe1H] = true, [WEAPON.Axe2H] = true, [WEAPON.Mace1H] = true, [WEAPON.Mace2H] = true, [WEAPON.Staff] = true, [WEAPON.Unarmed] = true, [WEAPON.Dagger] = true },
    MAGE = { [WEAPON.Sword1H] = true, [WEAPON.Staff] = true, [WEAPON.Dagger] = true, [WEAPON.Wand] = true },
    WARLOCK = { [WEAPON.Sword1H] = true, [WEAPON.Staff] = true, [WEAPON.Dagger] = true, [WEAPON.Wand] = true },
    DRUID = { [WEAPON.Mace1H] = true, [WEAPON.Mace2H] = true, [WEAPON.Staff] = true, [WEAPON.Unarmed] = true, [WEAPON.Dagger] = true },
}

local NO_HOLDABLE = { WARRIOR = true, HUNTER = true, ROGUE = true }

local LOOT_SLOTS = { "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger", "Trinket", "Main Hand", "Off Hand", "Ranged", "Other" }

local EQUIP_LOC_SLOTS = {
    INVTYPE_HEAD = "Head", INVTYPE_NECK = "Neck", INVTYPE_SHOULDER = "Shoulder", INVTYPE_CLOAK = "Back",
    INVTYPE_CHEST = "Chest", INVTYPE_ROBE = "Chest", INVTYPE_WRIST = "Wrist", INVTYPE_HAND = "Hands",
    INVTYPE_WAIST = "Waist", INVTYPE_LEGS = "Legs", INVTYPE_FEET = "Feet", INVTYPE_FINGER = "Finger", INVTYPE_TRINKET = "Trinket",
    INVTYPE_WEAPON = "Main Hand", INVTYPE_2HWEAPON = "Main Hand", INVTYPE_WEAPONMAINHAND = "Main Hand",
    INVTYPE_WEAPONOFFHAND = "Off Hand", INVTYPE_SHIELD = "Off Hand", INVTYPE_HOLDABLE = "Off Hand",
    INVTYPE_RANGED = "Ranged", INVTYPE_RANGEDRIGHT = "Ranged", INVTYPE_THROWN = "Ranged", INVTYPE_RELIC = "Ranged",
}

Private.DungeonJournalClasses = CLASS_ARMOUR
Private.DungeonJournalSlots = LOOT_SLOTS

local function IsLootShown(ItemID, ClassFile, Slot)
    local _, _, _, EquipLoc, _, ClassID, SubClassID = C_Item.GetItemInfoInstant(ItemID)
    if Slot and (EQUIP_LOC_SLOTS[EquipLoc] or "Other") ~= Slot then return false end
    if not ClassFile or not CLASS_ARMOUR[ClassFile] then return true end
    if ClassID == Enum.ItemClass.Weapon then return CLASS_WEAPONS[ClassFile][SubClassID] == true end
    if ClassID ~= Enum.ItemClass.Armor or EquipLoc == "INVTYPE_CLOAK" then return true end
    if EquipLoc == "INVTYPE_HOLDABLE" then return not NO_HOLDABLE[ClassFile] end
    return SubClassID == ARMOUR.Generic or CLASS_ARMOUR[ClassFile][SubClassID] == true
end

function Private:GetDungeonJournalBosses(Dungeon, ClassFile, Slot)
    if not Slot then return Dungeon.Bosses end

    local Bosses = {}
    for _, Boss in ipairs(Dungeon.Bosses) do
        for _, ItemID in ipairs(Boss.Loot) do
            if IsLootShown(ItemID, ClassFile, Slot) then
                Bosses[#Bosses + 1] = Boss
                break
            end
        end
    end
    return Bosses
end

function Private:GetDungeonJournalDungeons(Bracket, ClassFile, Slot)
    local Dungeons = {}
    for _, Dungeon in ipairs(Private.DungeonJournalData) do
        local InBracket = not Bracket or (Dungeon.Levels[1] <= Bracket[2] and Dungeon.Levels[2] >= Bracket[1])
        if InBracket and (not Slot or #Private:GetDungeonJournalBosses(Dungeon, ClassFile, Slot) > 0) then Dungeons[#Dungeons + 1] = Dungeon end
    end
    return Dungeons
end

function Private:GetDungeonJournalLoot(Dungeon, Boss, ClassFile, Slot)
    local Loot, Seen, Total = {}, {}, 0
    local Bosses = Boss.All and Dungeon.Bosses or { Boss }

    for _, Source in ipairs(Bosses) do
        for _, ItemID in ipairs(Source.Loot) do
            local Entry = Seen[ItemID]
            if Entry then
                if Boss.All and Entry.Boss ~= Source.Name then Entry.Boss = "Multiple Bosses" end
            else
                Total = Total + 1
                Entry = { ItemID = ItemID, Boss = Boss.All and Source.Name or nil }
                Seen[ItemID] = Entry
                if IsLootShown(ItemID, ClassFile, Slot) then Loot[#Loot + 1] = Entry end
            end
        end
    end

    return Loot, Total
end

function Private:CreateDungeonJournalText(Parent, Template)
    local Text = Parent:CreateFontString(nil, "OVERLAY", Template)
    local Path, Size = Text:GetFont()
    Text:SetFont(Path, Size, "OUTLINE, SLUG")
    Text:SetShadowOffset(0, 0)
    return Text
end

function Private:SetupDungeonJournal()
    if not Private.isForever then return end
    Private:CreateDungeonJournal()
end
