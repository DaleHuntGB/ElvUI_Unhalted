local Private = select(2, ...)

Private.QuickActionPendingItems = {}
Private.QuickActionPendingSpells = {}
Private.QuickActionCatalog = {}

function Private:GetQuickActionInfo(Action)
    local Name, Icon, ActionType, Value
    if Action.Type == "Mount" then
        Name, Value, Icon = C_MountJournal.GetMountInfoByID(Action.ID)
        ActionType, Value = "mount", Action.ID
    elseif Action.Type == "Spell" then
        local Info = C_Spell.GetSpellInfo(Action.ID)
        if Info then Name, Icon = Info.name, Info.iconID end
        Name = Private.QuickActionSpellNames[Action.ID] or Name
        ActionType, Value = "spell", Action.ID
        if not Info and not Private.QuickActionPendingSpells[Action.ID] then
            Private.QuickActionPendingSpells[Action.ID] = true
            C_Spell.RequestLoadSpellData(Action.ID)
        end
    elseif Action.Type == "Toy" then
        Name, Icon = select(2, C_ToyBox.GetToyInfo(Action.ID))
        ActionType, Value = "toy", Action.ID
    elseif Action.Type == "Item" then
        Name = C_Item.GetItemNameByID(Action.ID)
        Icon = C_Item.GetItemIconByID(Action.ID)
        ActionType, Value = "item", "item:" .. Action.ID
    end
    if not Name and (Action.Type == "Toy" or Action.Type == "Item") and not Private.QuickActionPendingItems[Action.ID] then
        Private.QuickActionPendingItems[Action.ID] = true
        C_Item.RequestLoadItemDataByID(Action.ID)
    end
    return Name or (Action.Type .. " " .. Action.ID), Icon or 134400, ActionType, Value
end

function Private:CollectQuickActions(Category)
    if Private.QuickActionCatalog[Category] then return Private.QuickActionCatalog[Category] end
    if InCombatLockdown() then return {} end
    local Entries = {}
    local function AddAction(ID, Name, Icon)
        table.insert(Entries, { Type = Category, ID = ID, Name = Name, Icon = Icon })
    end
    if Category == "Mount" then
        for _, ID in ipairs(C_MountJournal.GetMountIDs()) do
            local Name, _, Icon, _, _, _, _, _, _, Hidden, Collected = C_MountJournal.GetMountInfoByID(ID)
            if Collected and not Hidden then AddAction(ID, Name, Icon) end
        end
    elseif Category == "Spell" then
        local Seen = {}
        local function AddSpell(ID, Name, Icon)
            if not ID or Seen[ID] then return end
            Seen[ID] = true
            AddAction(ID, Private.QuickActionSpellNames[ID] or Name, Icon)
        end
        for LineIndex = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local Line = C_SpellBook.GetSpellBookSkillLineInfo(LineIndex)
            if Line and not Line.isGuild and not Line.offSpecID then
                for Slot = Line.itemIndexOffset + 1, Line.itemIndexOffset + Line.numSpellBookItems do
                    local Info = C_SpellBook.GetSpellBookItemInfo(Slot, Enum.SpellBookSpellBank.Player)
                    if Info and not Info.isPassive and not Info.isOffSpec then
                        if Info.itemType == Enum.SpellBookItemType.Spell then
                            AddSpell(Info.actionID, Info.name, Info.iconID)
                        elseif Info.itemType == Enum.SpellBookItemType.Flyout then
                            local _, _, NumSlots, Known = GetFlyoutInfo(Info.actionID)
                            if Known then
                                for FlyoutSlot = 1, NumSlots do
                                    local SpellID, _, IsKnown = GetFlyoutSlotInfo(Info.actionID, FlyoutSlot)
                                    if IsKnown and not C_Spell.IsSpellPassive(SpellID) then
                                        local Spell = C_Spell.GetSpellInfo(SpellID)
                                        AddSpell(SpellID, Spell and Spell.name, Spell and Spell.iconID)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif Category == "Toy" then
        -- Preserve the user's Toy Box filters.
        for Index = 1, C_ToyBox.GetNumFilteredToys() do
            local ID = C_ToyBox.GetToyFromIndex(Index)
            if ID and PlayerHasToy(ID) then
                local Name, Icon = select(2, C_ToyBox.GetToyInfo(ID))
                AddAction(ID, Name, Icon)
            end
        end
    elseif Category == "Item" then
        local Seen = {}
        for Bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
            for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
                local ID = C_Container.GetContainerItemID(Bag, Slot)
                if ID and not Seen[ID] then
                    Seen[ID] = true
                    local _, _, _, _, Icon, ClassID = C_Item.GetItemInfoInstant(ID)
                    if ClassID == Enum.ItemClass.Consumable then AddAction(ID, C_Item.GetItemNameByID(ID), Icon) end
                end
            end
        end
    end

    table.sort(Entries, function(A, B)
        if A.Name == B.Name then return A.ID < B.ID end
        return (A.Name or "") < (B.Name or "")
    end)
    Private.QuickActionCatalog[Category] = Entries
    return Entries
end

function Private:AddQuickAction(Action)
    if InCombatLockdown() or not Private.DB.global.QuickAction.Enabled then return end
    local Items = Private.DB.global.QuickAction.Groups[1].Items
    for _, Existing in ipairs(Items) do
        if Existing.Type == Action.Type and Existing.ID == Action.ID then return end
    end
    table.insert(Items, { Type = Action.Type, ID = Action.ID })
    Private:UpdateQuickActions()
    Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
    return true
end
