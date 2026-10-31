local Private = select(2, ...)
local BAR_HEIGHT = 24
local INSET = 1

local EnvironmentalIcons = {
    DROWNING = "spell_shadow_demonbreath",
    FALLING = "ability_rogue_quickrecovery",
    FIRE = "spell_fire_fire",
    LAVA = "spell_fire_fire",
    SLIME = "inv_misc_slime_01",
    FATIGUE = "ability_creature_cursed_05",
}

function Private:UpdateDeathRow(Row)
    local DeathTime = Row.CombatSource.deathTimeSeconds

    Row.StatusBar:SetMinMaxValues(0, 1)
    Row.StatusBar:SetValue(1)

    if not Row.DamageMeterFrame.SessionID and Row.DamageMeterDB.SessionType == Enum.DamageMeterSessionType.Overall then
        Row.Amount_Text:SetText("")
    elseif issecretvalue(DeathTime) then
        Row.Amount_Text:SetFormattedText("%.0fs", DeathTime)
    elseif DeathTime and DeathTime >= 0 then
        Row.Amount_Text:SetText(SecondsToClock(DeathTime))
    else
        Row.Amount_Text:SetText("")
    end
end

function Private:RefreshDeathRecap(Drilldown, Row, CreateEntry)
    local RecapID = Row.CombatSource.deathRecapID
    if issecretvalue(RecapID) or not RecapID or RecapID == 0 then Drilldown:Hide() return end

    local Events = C_DeathRecap.GetRecapEvents(RecapID)
    if not Events or #Events == 0 then Drilldown:Hide() return end

    local DB = Row.DamageMeterDB
    local MaxHealth = C_DeathRecap.GetRecapMaxHealth(RecapID)
    local HasMaxHealth = issecretvalue(MaxHealth) or (MaxHealth and MaxHealth > 0)
    local ClassColour = RAID_CLASS_COLORS[Row.CombatSource.classFilename]
    local BarColour = ClassColour or Private.E.db.general.valuecolor
    local RowCount = math.min(#Events, 10)

    for i = 1, RowCount do
        local Event = Events[i]
        local Entry = Drilldown.Rows[i]
        if not Entry then
            Entry = CreateEntry(Drilldown, DB)
            Drilldown.Rows[i] = Entry
        end
        Entry:ClearAllPoints()
        Entry:SetPoint("TOPLEFT", Drilldown, "TOPLEFT", INSET, -INSET - ((i - 1) * BAR_HEIGHT))
        Entry:SetPoint("BOTTOMRIGHT", Drilldown, "BOTTOMRIGHT", -INSET, INSET + ((RowCount - i) * BAR_HEIGHT))
        local Amount = Event.amount
        if not issecretvalue(Amount) and not Amount then Amount = 0 end
        if HasMaxHealth then
            Entry.StatusBar:SetMinMaxValues(0, MaxHealth)
            Entry.StatusBar:SetValue(Amount)
        else
            Entry.StatusBar:SetMinMaxValues(0, 1)
            Entry.StatusBar:SetValue(1)
        end
        Entry.StatusBar:SetStatusBarColor(BarColour.r, BarColour.g, BarColour.b, BarColour.a or 1)

        local SpellID = Event.spellId
        local SpellName = Event.spellName
        local SpellTexture
        if not issecretvalue(Event.event) then
            if Event.event == "SWING_DAMAGE" then
                SpellID = 88163
                SpellName = ACTION_SWING
            elseif Event.event == "ENVIRONMENTAL_DAMAGE" and not issecretvalue(Event.environmentalType) and Event.environmentalType then
                local EnvironmentalType = string.upper(Event.environmentalType)
                SpellName = _G["ACTION_ENVIRONMENTAL_DAMAGE_" .. EnvironmentalType] or UNKNOWN
                SpellTexture = "Interface\\Icons\\" .. (EnvironmentalIcons[EnvironmentalType] or "ability_creature_cursed_05")
            end
        end
        if issecretvalue(SpellID) or (SpellID and SpellID ~= 0) then
            if not SpellTexture then SpellTexture = C_Spell.GetSpellTexture(SpellID) end
            if not issecretvalue(SpellName) and not SpellName then SpellName = C_Spell.GetSpellName(SpellID) end
        end
        if not issecretvalue(SpellName) and not SpellName then SpellName = UNKNOWN end
        if not issecretvalue(SpellTexture) and not SpellTexture then SpellTexture = "Interface\\Icons\\INV_Misc_QuestionMark" end
        Entry.Icon:SetTexture(SpellTexture)
        Entry.Name_Text:SetText(SpellName)

        local Damage = Private:AbbreviateValue(Amount)
        local CurrentHealth = Event.currentHP
        if not issecretvalue(MaxHealth) and HasMaxHealth and not issecretvalue(CurrentHealth) and CurrentHealth then
            local HealthPercent = math.floor(math.max(0, math.min(100, CurrentHealth / MaxHealth * 100)))
            Entry.Amount_Text:SetFormattedText("%s (%d%%)", Damage, HealthPercent)
        else
            Entry.Amount_Text:SetFormattedText("%s (?%%)", Damage)
        end
        Entry:Show()
    end
    for i = RowCount + 1, #Drilldown.Rows do
        Drilldown.Rows[i]:Hide()
    end
    Drilldown:SetSize(DB.Size[1], INSET * 2 + RowCount * BAR_HEIGHT)

    return true
end
