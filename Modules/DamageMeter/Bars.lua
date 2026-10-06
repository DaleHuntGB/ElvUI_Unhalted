local Private = select(2, ...)
local TestSessions = {}
local MeterTypeOptions = {}
for MeterType, Name in pairs(Private.MeterTypes) do
    MeterTypeOptions[#MeterTypeOptions + 1] = { MeterType = MeterType, SessionType = Enum.DamageMeterSessionType.Current, Name = Name }
    MeterTypeOptions[#MeterTypeOptions + 1] = { MeterType = MeterType, SessionType = Enum.DamageMeterSessionType.Overall, Name = Name .. " (Overall)" }
end
table.sort(MeterTypeOptions, function(A, B)
    if A.MeterType == B.MeterType then return A.SessionType ~= B.SessionType and A.SessionType == Enum.DamageMeterSessionType.Current end
    return A.MeterType < B.MeterType
end)
local EnvironmentalIcons = {
    DROWNING = "spell_shadow_demonbreath",
    FALLING = "ability_rogue_quickrecovery",
    FIRE = "spell_fire_fire",
    LAVA = "spell_fire_fire",
    SLIME = "inv_misc_slime_01",
    FATIGUE = "ability_creature_cursed_05",
}

local function GetDeathRecapSession(RecapID)
    if issecretvalue(RecapID) or not RecapID or RecapID == 0 then return end

    local Events = C_DeathRecap.GetRecapEvents(RecapID) or {}
    local MaxHealth = C_DeathRecap.GetRecapMaxHealth(RecapID)
    if issecretvalue(MaxHealth) or not MaxHealth or MaxHealth <= 0 then MaxHealth = nil end

    local Session = { combatSpells = {}, maxAmount = 0 }
    local DeathTime = Events[1] and Events[1].timestamp
    if issecretvalue(DeathTime) then DeathTime = nil end

    for IDX, Event in ipairs(Events) do
        local Spell = {
            spellID = Event.spellId,
            spellName = Event.spellName,
            totalAmount = Event.amount,
        }

        if not issecretvalue(Event.amount) then Spell.totalAmount = Event.amount or 0 Session.maxAmount = math.max(Session.maxAmount, Spell.totalAmount) end
        if DeathTime and not issecretvalue(Event.timestamp) and Event.timestamp then Spell.timeBeforeDeath = DeathTime - Event.timestamp end
        if MaxHealth and not issecretvalue(Event.currentHP) and Event.currentHP then Spell.healthPercent = Event.currentHP / MaxHealth * 100 end
        if not issecretvalue(Event.hideCaster) and not Event.hideCaster then Spell.sourceName = Event.sourceName end

        if not issecretvalue(Event.event) then
            if Event.event == "SWING_DAMAGE" then
                Spell.spellID = 88163
                Spell.spellName = ACTION_SWING
            elseif Event.event == "ENVIRONMENTAL_DAMAGE" then
                Spell.sourceName = nil
                local DamageType = Event.environmentalType
                if not issecretvalue(DamageType) and DamageType then
                    DamageType = string.upper(DamageType)
                    Spell.spellID = nil
                    Spell.spellName = _G["ACTION_ENVIRONMENTAL_DAMAGE_" .. DamageType]
                    Spell.texture = "Interface\\Icons\\" .. (EnvironmentalIcons[DamageType] or "ability_creature_cursed_05")
                end
            end
        end

        Session.combatSpells[IDX] = Spell
    end

    return Session
end

local function Bar_OnEnter(DMBar)
    DMBar.Highlight:Show()

    local DMFrame = DMBar:GetParent()
    local Anchor = DMFrame.TitleBar:IsShown() and DMFrame.TitleBar or DMFrame
    GameTooltip:SetOwner(Anchor, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOMRIGHT", Anchor, "TOPRIGHT", 0, 1)
    GameTooltip:ClearLines()
    if DMBar.MeterTypeOption then
        GameTooltip:AddLine(DMBar.MeterTypeOption.Name)
        GameTooltip:AddDoubleLine("Left-Click: ", "Select Meter Type", 0.6, 0.6, 0.6, 1, 1, 1)
        GameTooltip:AddDoubleLine("Right-Click: ", "Close Meter Types", 0.6, 0.6, 0.6, 1, 1, 1)
    else
        GameTooltip:AddDoubleLine("Left-Click: ", "Show Breakdown", 0.6, 0.6, 0.6, 1, 1, 1)
        GameTooltip:AddDoubleLine("Right-Click: ", "Select Meter Type", 0.6, 0.6, 0.6, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function Bar_OnLeave(DMBar)
    DMBar.Highlight:Hide()
    GameTooltip:Hide()
end

local function Bar_OnClick(DMBar, Button)
    if Button == "LeftButton" then
        local Option = DMBar.MeterTypeOption
        if Option then
            Private:SetDamageMeterType(DMBar:GetParent(), Option.MeterType, Option.SessionType)
            GameTooltip:Hide()
        else
            Private:Drilldown(DMBar)
        end
    elseif Button == "RightButton" then
        Private:ToggleDamageMeterTypes(DMBar:GetParent())
    end
end

function Private:ToggleDamageMeterTypes(DMFrame)
    GameTooltip:Hide()
    if DMFrame.MeterTypeMenuOffset then
        Private:SetDamageMeterType(DMFrame, DMFrame.DB.MeterType)
        return
    end

    local Popup = Private.DamageMeterDrilldown
    if Popup and Popup:GetParent() == DMFrame then Popup:Hide() end
    DMFrame.MeterTypeMenuOffset = 0
    Private:PopulateDamageMeterBars(DMFrame, DMFrame.DB)
end

function Private:Drilldown(DMBar)
    local DMFrame = DMBar:GetParent()
    local DB = DMFrame.DB
    local DataSource = DMBar.DataSource
    local Popup = Private.DamageMeterDrilldown

    if Popup then Popup:Hide() end
    if Private.DamageMeterTestMode or not DataSource or not C_DamageMeter.IsDamageMeterAvailable() then return end
    local SessionSource;

    if DB.MeterType == Enum.DamageMeterType.Deaths then
        SessionSource = GetDeathRecapSession(DataSource.deathRecapID)
    else
        if issecretvalue(DataSource.sourceGUID) or issecretvalue(DataSource.sourceCreatureID) then return end

        if DMFrame.EncounterSegment then
            SessionSource = C_DamageMeter.GetCombatSessionSourceFromID(DMFrame.EncounterSegment.sessionID, DB.MeterType, DataSource.sourceGUID, DataSource.sourceCreatureID)
        else
            SessionSource = C_DamageMeter.GetCombatSessionSourceFromType(DMFrame.SessionType, DB.MeterType, DataSource.sourceGUID, DataSource.sourceCreatureID)
        end
    end

    if not SessionSource then return end

    if not Popup then
        Popup = Private:CreateDrilldownPopup(nil, DB)

        Private.DamageMeterDrilldown = Popup

        Popup:SetFrameStrata("DIALOG")
        Popup:SetClampedToScreen(true)
        Popup:EnableMouse(true)
        Popup:EnableMouseWheel(true)

        Popup:SetScript("OnMouseDown", function(DMFramePopup, Button)
            if Button == "RightButton" then DMFramePopup:Hide() end
        end)
        Popup:SetScript("OnHide", function(DMFramePopup)
            DMFramePopup:Hide()
            local Parent = DMFramePopup:GetParent()
            Parent:EnableMouseWheel(true)
            DMFramePopup:SetScript("OnMouseWheel", nil)
            Private:PopulateDamageMeterBars(Parent, Parent.DB)
        end)

    else
        Private:LayoutDrilldownPopup(Popup, DB)
    end

    Popup:SetParent(DMFrame)
    Popup:ClearAllPoints()
    Popup:SetPoint("BOTTOMRIGHT", DMFrame, "BOTTOMRIGHT", 0, 0)

    local Spells = SessionSource.combatSpells
    Popup.Unavailable:SetShown(DB.MeterType == Enum.DamageMeterType.Deaths and #Spells == 0)
    local ClassColour = DataSource.classFilename ~= "" and C_ClassColor.GetClassColor(DataSource.classFilename)
    local Offset = 0

    local function PopulateSpells(_, Delta)
        Offset = math.max(0, math.min(math.max(0, #Spells - DB.Rows.Num), Offset - Delta))
        for IDX = 1, DB.Rows.Num do
            local Bar = Popup.Bars[IDX]
            local Spell = Spells[IDX + Offset]
            Bar:SetScript("OnEnter", nil)
            Bar:SetScript("OnLeave", nil)
            Bar:SetScript("OnMouseDown", nil)
            Bar:EnableMouse(false)
            if Spell then
                if DB.Rows.Name.ColourByClass and ClassColour then
                    Bar.Name:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Rows.Name.Colour[4])
                else
                    Bar.Name:SetTextColor(unpack(DB.Rows.Name.Colour))
                end

                if DB.Rows.Amount.ColourByClass and ClassColour then
                    Bar.Number:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Rows.Amount.Colour[4])
                else
                    Bar.Number:SetTextColor(unpack(DB.Rows.Amount.Colour))
                end

                Bar:SetMinMaxValues(0, (DB.MeterType == Enum.DamageMeterType.Deaths and SessionSource.maxAmount == 0) and 1 or SessionSource.maxAmount)
                Bar:SetValue((DB.MeterType == Enum.DamageMeterType.Deaths and SessionSource.maxAmount == 0) and 1 or Spell.totalAmount)
                if ClassColour then Bar:SetStatusBarColor(ClassColour.r, ClassColour.g, ClassColour.b) else Bar:SetStatusBarColor(0.6, 0.6, 0.6) end
                local SpellName, SpellTexture = Spell.spellName, Spell.texture
                if not issecretvalue(Spell.spellID) and Spell.spellID then
                    if not issecretvalue(SpellName) and not SpellName then SpellName = C_Spell.GetSpellName(Spell.spellID) end
                    SpellTexture = SpellTexture or C_Spell.GetSpellTexture(Spell.spellID)
                end
                if not issecretvalue(SpellName) and not SpellName then SpellName = UNKNOWN end

                if DB.MeterType == Enum.DamageMeterType.Deaths then
                    local SourceName = Spell.sourceName
                    if not issecretvalue(SourceName) and not SourceName then SourceName = "" end
                    local Seconds = Spell.timeBeforeDeath
                    local Time = Seconds and string.format("%02d:%02d - ", math.floor(Seconds / 60), math.floor(Seconds % 60)) or ""
                    Bar.Name:SetFormattedText("%s%s%s", Time, SpellName, C_StringUtil.WrapString(SourceName, " (", ")"))
                else
                    Bar.Name:SetText(SpellName)
                end
                Bar.Icon:SetTexture(SpellTexture or 135274)
                Bar.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

                local Amount = Private:AbbreviateValue(Spell.totalAmount)
                if DB.MeterType == Enum.DamageMeterType.Deaths and Spell.healthPercent then
                    Bar.Number:SetFormattedText("%s - %.0f%%", Amount, Spell.healthPercent)
                else
                    Bar.Number:SetText(Amount)
                end
            end
            Bar:SetShown(Spell ~= nil)
            Bar.Icon:SetShown(Spell ~= nil)
        end
    end

    PopulateSpells(nil, 0)
    Popup:SetScript("OnMouseWheel", PopulateSpells)
    for _, Bar in ipairs(DMFrame.Bars) do Bar:Hide() Bar.Icon:Hide() end
    GameTooltip:Hide()
    DMFrame:EnableMouseWheel(false)
    Popup:Show()
end

function Private:CreateDamageMeterBar(DMFrame)
    local DMBar = CreateFrame("StatusBar", nil, DMFrame)
    DMBar:EnableMouse(false)
    DMBar:SetMinMaxValues(0, 1)
    DMBar:SetValue(1)

    DMBar.Icon = DMFrame:CreateTexture(nil, "OVERLAY")
    DMBar.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    DMBar.Name = DMBar:CreateFontString(nil, "OVERLAY")
    DMBar.Name:SetJustifyH("LEFT")
    DMBar.Name:SetWordWrap(false)

    DMBar.Number = DMBar:CreateFontString(nil, "OVERLAY")
    DMBar.Number:SetJustifyH("RIGHT")
    DMBar.Number:SetWordWrap(false)

    return DMBar
end

function Private:ClampDamageMeterSize(DB)
    -- Keep at least one pixel for every row and its status bar.
    local MinHeight = 2 + DB.Rows.Num + (DB.Rows.Num - 1) * DB.Rows.Spacing
    DB.Size[2] = math.max(DB.Size[2], MinHeight)
    local RowHeight = (DB.Size[2] - 2 - (DB.Rows.Num - 1) * DB.Rows.Spacing) / DB.Rows.Num
    local MinWidth = math.ceil(RowHeight + 3)
    DB.Size[1] = math.max(DB.Size[1], MinWidth)
    return MinWidth, MinHeight
end

function Private:LayoutDamageMeterBars(DMFrame, DB)
    local rowHeight = (DB.Size[2] - 2 - (DB.Rows.Num - 1) * DB.Rows.Spacing) / DB.Rows.Num

    for IDX = 1, DB.Rows.Num do
        local DMBar = DMFrame.Bars and DMFrame.Bars[IDX] or nil

        if not DMBar then DMBar = Private:CreateDamageMeterBar(DMFrame) DMFrame.Bars = DMFrame.Bars or {} DMFrame.Bars[IDX] = DMBar end

        DMBar.Icon:ClearAllPoints()
        DMBar.Icon:SetPoint("TOPLEFT", DMFrame, "TOPLEFT", 1, -1 - (IDX - 1) * (rowHeight + DB.Rows.Spacing))
        DMBar.Icon:SetSize(rowHeight, rowHeight)
        DMBar.Icon:Show()

        DMBar:ClearAllPoints()
        DMBar:SetPoint("TOPLEFT", DMBar.Icon, "TOPRIGHT", 0, 0)
        DMBar:SetSize(DMFrame:GetWidth() - rowHeight - 2, rowHeight)
        DMBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", DB.Rows.Texture))

        DMBar:SetScript("OnEnter", Bar_OnEnter)
        DMBar:SetScript("OnLeave", Bar_OnLeave)
        DMBar:SetScript("OnMouseDown", Bar_OnClick)
        DMBar:EnableMouse(true)

        DMBar.TopBorder = DMBar.TopBorder or DMBar:CreateTexture(nil, "OVERLAY")
        DMBar.TopBorder:SetPoint("TOPLEFT", DMBar.Icon, "TOPLEFT", 0, 1)
        DMBar.TopBorder:SetPoint("TOPRIGHT", DMBar, "TOPRIGHT", 0, 1)
        DMBar.TopBorder:SetHeight(1)
        DMBar.TopBorder:SetColorTexture(0, 0, 0, 1)

        DMBar.BottomBorder = DMBar.BottomBorder or DMBar:CreateTexture(nil, "OVERLAY")
        DMBar.BottomBorder:SetPoint("BOTTOMLEFT", DMBar.Icon, "BOTTOMLEFT", 0, -1)
        DMBar.BottomBorder:SetPoint("BOTTOMRIGHT", DMBar, "BOTTOMRIGHT", 0, -1)
        DMBar.BottomBorder:SetHeight(1)
        DMBar.BottomBorder:SetColorTexture(0, 0, 0, 1)

        DMBar.Name:ClearAllPoints()
        DMBar.Name:SetPoint(DB.Rows.Name.Layout[1], DMBar, DB.Rows.Name.Layout[2], DB.Rows.Name.Layout[3], DB.Rows.Name.Layout[4])
        DMBar.Name:SetFont(Private.LSM:Fetch("font", DB.Rows.Name.Font), DB.Rows.Name.FontSize, DB.Rows.Name.FontFlag)
        DMBar.Name:SetTextColor(DB.Rows.Name.Colour[1], DB.Rows.Name.Colour[2], DB.Rows.Name.Colour[3], DB.Rows.Name.Colour[4])

        DMBar.Number:ClearAllPoints()
        DMBar.Number:SetPoint(DB.Rows.Amount.Layout[1], DMBar, DB.Rows.Amount.Layout[2], DB.Rows.Amount.Layout[3], DB.Rows.Amount.Layout[4])
        DMBar.Number:SetFont(Private.LSM:Fetch("font", DB.Rows.Amount.Font), DB.Rows.Amount.FontSize, DB.Rows.Amount.FontFlag)
        DMBar.Number:SetTextColor(DB.Rows.Amount.Colour[1], DB.Rows.Amount.Colour[2], DB.Rows.Amount.Colour[3], DB.Rows.Amount.Colour[4])

        if DB.Rows.Name.Layout[1] == "LEFT" and DB.Rows.Amount.Layout[1] == "RIGHT" then DMBar.Name:SetPoint("RIGHT", DMBar.Number, "LEFT", -3, 0) end

        DMBar.Highlight = DMBar.Highlight or DMBar:CreateTexture(nil, "OVERLAY")
        DMBar.Highlight:SetAllPoints(DMBar)
        DMBar.Highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
        DMBar.Highlight:SetColorTexture(1, 1, 1, 0.3)
        DMBar.Highlight:Hide()

        DMBar:Show()
    end

    for IDX = DB.Rows.Num + 1, #DMFrame.Bars do DMFrame.Bars[IDX]:Hide() DMFrame.Bars[IDX].Icon:Hide() end
end

local SingleMeterTypes = {
	[Enum.DamageMeterType.Absorbs] = true,
	[Enum.DamageMeterType.Interrupts] = true,
	[Enum.DamageMeterType.Dispels] = true,
	[Enum.DamageMeterType.DamageTaken] = true,
	[Enum.DamageMeterType.AvoidableDamageTaken] = true,
	[Enum.DamageMeterType.Deaths] = true,
	[Enum.DamageMeterType.EnemyDamageTaken] = true,
}

local PerSecondMeterTypes = {
	[Enum.DamageMeterType.Dps] = true,
	[Enum.DamageMeterType.Hps] = true,
}

local TestSources = {
    { name = UnitName("player"), classFilename = select(2, UnitClass("player")) },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_1, classFilename = "DEATHKNIGHT" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_2, classFilename = "MAGE" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_3, classFilename = "WARLOCK" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_7, classFilename = "HUNTER" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_6, classFilename = "DEMONHUNTER" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_4, classFilename = "SHAMAN" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_5, classFilename = "PALADIN" },
}

local function GetTestSession(Count)
    Count = math.max(Count, #TestSources)
    if TestSessions[Count] then return TestSessions[Count] end

    local Session = { combatSources = {}, maxAmount = 12400000 }
    local Amount = Session.maxAmount
    for IDX = 1, Count do
        local Source = TestSources[(IDX - 1) % #TestSources + 1]
        Session.combatSources[IDX] = {
            name = Source.name,
            classFilename = Source.classFilename,
            totalAmount = Amount,
            amountPerSecond = Amount / 300,
            deathRecapID = IDX,
            deathTimeSeconds = IDX * 10,
        }
        Amount = math.max(math.floor(Amount * 0.88), 1)
    end

    TestSessions[Count] = Session
    return Session
end

local function PopulateMeterTypeOptions(DMFrame, DB)
    DMFrame.MeterTypeMenuOffset = math.max(0, math.min(math.max(0, #MeterTypeOptions - DB.Rows.Num), DMFrame.MeterTypeMenuOffset))
    for IDX = 1, DB.Rows.Num do
        local Bar = DMFrame.Bars[IDX]
        local Option = MeterTypeOptions[IDX + DMFrame.MeterTypeMenuOffset]
        Bar.MeterTypeOption = Option
        Bar.DataSource = nil
        Bar.Icon:Hide()
        if Option then
            Bar:ClearAllPoints()
            Bar:SetPoint("TOPLEFT", DMFrame, "TOPLEFT", 1, -1 - (IDX - 1) * (Bar:GetHeight() + DB.Rows.Spacing))
            Bar:SetWidth(DMFrame:GetWidth() - 2)
            Bar.Name:ClearAllPoints()
            Bar.Name:SetPoint("LEFT", Bar, "LEFT", 3, 0)
            Bar.Name:SetPoint("RIGHT", Bar, "RIGHT", -3, 0)
            Bar.Name:SetText(Option.Name)
            Bar.Name:SetTextColor(unpack(DB.Rows.Name.Colour))
            Bar.Number:SetText("")
            Bar:SetMinMaxValues(0, 1)
            Bar:SetValue(1)
            if not DMFrame.EncounterSegment and DB.MeterType == Option.MeterType and DMFrame.SessionType == Option.SessionType then
                Bar:SetStatusBarColor(0.2, 0.4, 0.2)
            else
                Bar:SetStatusBarColor(0.2, 0.2, 0.2)
            end
        end
        Bar:SetShown(Option ~= nil)
    end
end

function Private:PopulateDamageMeterBars(DMFrame, DB)
    if DMFrame.MeterTypeMenuOffset then PopulateMeterTypeOptions(DMFrame, DB) return end
    local Popup = Private.DamageMeterDrilldown
    if Popup and Popup:IsShown() and Popup:GetParent() == DMFrame then return end
    local DMSession;

    if Private.DamageMeterTestMode then
        DMSession = GetTestSession(DB.Rows.Num)
    elseif C_DamageMeter.IsDamageMeterAvailable() then
        if DMFrame.EncounterSegment then
            DMSession = C_DamageMeter.GetCombatSessionFromID(DMFrame.EncounterSegment.sessionID, DB.MeterType)
        else
            DMSession = C_DamageMeter.GetCombatSessionFromType(DMFrame.SessionType, DB.MeterType)
        end
    end

    local DataSources = DMSession and DMSession.combatSources
    DMFrame.ScrollOffset = math.max(0, math.min(math.max(0, (DataSources and #DataSources or 0) - DB.Rows.Num), DMFrame.ScrollOffset))

    for IDX = 1, DB.Rows.Num do
        local DMBar = DMFrame.Bars[IDX]
        local DataSource = DataSources and DataSources[IDX + DMFrame.ScrollOffset]
        DMBar.MeterTypeOption = nil
        DMBar.DataSource = DataSource
        if DataSource then
            local ClassColour = DataSource.classFilename ~= "" and C_ClassColor.GetClassColor(DataSource.classFilename)
            if DB.Rows.Name.ColourByClass and ClassColour then
                DMBar.Name:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Rows.Name.Colour[4])
            else
                DMBar.Name:SetTextColor(DB.Rows.Name.Colour[1], DB.Rows.Name.Colour[2], DB.Rows.Name.Colour[3], DB.Rows.Name.Colour[4])
            end

            if DB.Rows.Amount.ColourByClass and ClassColour then
                DMBar.Number:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Rows.Amount.Colour[4])
            else
                DMBar.Number:SetTextColor(DB.Rows.Amount.Colour[1], DB.Rows.Amount.Colour[2], DB.Rows.Amount.Colour[3], DB.Rows.Amount.Colour[4])
            end

            if ClassColour then
                DMBar:SetStatusBarColor(ClassColour.r, ClassColour.g, ClassColour.b)
            else
                DMBar:SetStatusBarColor(0.6, 0.6, 0.6)
            end
            DMBar.Name:SetText(Private:StripRealm(DataSource.name, DataSource.classFilename))

            if DataSource.specIconID and DataSource.specIconID ~= 0 then
                DMBar.Icon:SetTexture(DataSource.specIconID)
                DMBar.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
            elseif DataSource.classFilename ~= "" then
                DMBar.Icon:SetAtlas(GetClassAtlas(DataSource.classFilename))
            else
                DMBar.Icon:SetTexture(135274)
            end

            if DB.MeterType == Enum.DamageMeterType.Deaths and DataSource.deathRecapID ~= 0 then
                DMBar:SetMinMaxValues(0, 1)
                DMBar:SetValue(1)
                if not issecretvalue(DataSource.deathTimeSeconds) and DataSource.deathTimeSeconds and DataSource.deathTimeSeconds >= 0 then
                    DMBar.Number:SetText(SecondsToClock(DataSource.deathTimeSeconds))
                else
                    DMBar.Number:SetText("")
                end
            else
                DMBar:SetMinMaxValues(0, DMSession.maxAmount)
                DMBar:SetValue(DataSource.totalAmount)
                if SingleMeterTypes[DB.MeterType] then
                    DMBar.Number:SetText(Private:AbbreviateValue(DataSource.totalAmount))
                elseif PerSecondMeterTypes[DB.MeterType] then
                    DMBar.Number:SetText(Private:AbbreviateValue(DataSource.amountPerSecond))
                else
                    DMBar.Number:SetFormattedText(DB.Rows.Amount.Format, Private:AbbreviateValue(DataSource.totalAmount), Private:AbbreviateValue(DataSource.amountPerSecond))
                end
            end

            DMBar:Show()
            DMBar.Icon:Show()
        else
            DMBar:Hide()
            DMBar.Icon:Hide()
        end
    end
end
