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

Private.DungeonJournalClasses = ClassArmour
Private.DungeonJournalSlots = LootSlots

local function IsLootShown(ItemID, ClassFile, Slot)
    local _, _, _, EquipLoc, _, ClassID, SubClassID = C_Item.GetItemInfoInstant(ItemID)
    if Slot and (EquipLocSlots[EquipLoc] or "Other") ~= Slot then return false end
    if not ClassFile or not ClassArmour[ClassFile] then return true end
    if ClassID == Enum.ItemClass.Weapon then return ClassWeapons[ClassFile][SubClassID] == true end
    if ClassID ~= Enum.ItemClass.Armor or EquipLoc == "INVTYPE_CLOAK" then return true end
    if EquipLoc == "INVTYPE_HOLDABLE" then return not NoHoldable[ClassFile] end
    return SubClassID == Armour.Generic or ClassArmour[ClassFile][SubClassID] == true
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

function Private:CreateDungeonJournalText(Parent, Template, OnParchment)
    local Text = Parent:CreateFontString(nil, "OVERLAY", Template)
    local Path, Size = Text:GetFont()
    Text:SetFont(Path, Size, OnParchment and "SLUG" or "OUTLINE, SLUG")
    Text:SetShadowOffset(0, 0)
    if OnParchment then Text:SetTextColor(0.25, 0.1484375, 0.02) end
    return Text
end
