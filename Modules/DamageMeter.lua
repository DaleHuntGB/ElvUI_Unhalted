local Private = select(2, ...)
local LightenFactor = 2
local BarHeight = 24
local SeparatorHeight = 18
local Spacing = 0
local Inset = 1
local TextPadding = 3
local MaxRowsPerSection = 10

local SingleMeterTypes = {
    [Enum.DamageMeterType.Absorbs] = true,
    [Enum.DamageMeterType.Interrupts] = true,
    [Enum.DamageMeterType.Dispels] = true,
    [Enum.DamageMeterType.DamageTaken] = true,
    [Enum.DamageMeterType.AvoidableDamageTaken] = true,
    [Enum.DamageMeterType.EnemyDamageTaken] = true,
}

local PerSecondMeterTypes = {
    [Enum.DamageMeterType.Dps] = true,
    [Enum.DamageMeterType.Hps] = true,
}

local PetSectionMeterTypes = {
    [Enum.DamageMeterType.DamageDone] = true,
    [Enum.DamageMeterType.Dps] = true,
}

local SeenCreatures = {}

local EnvironmentalIcons = {
    DROWNING = "spell_shadow_demonbreath",
    FALLING = "ability_rogue_quickrecovery",
    FIRE = "spell_fire_fire",
    LAVA = "spell_fire_fire",
    SLIME = "inv_misc_slime_01",
    FATIGUE = "ability_creature_cursed_05",
}

local MeterTypes = {}
for MeterType in pairs(Private.MeterTypes) do
    MeterTypes[#MeterTypes + 1] = MeterType
end
table.sort(MeterTypes)

-- [[ Death Recap ]]
local function UpdateDeathRow(Row)
    local DeathTime = Row.CombatSource.deathTimeSeconds

    Row.StatusBar:SetMinMaxValues(0, 1)
    Row.StatusBar:SetValue(1)

    if not Row.DamageMeterFrame.SessionID and Row.DamageMeterDB.SessionType == Enum.DamageMeterSessionType.Overall then
        Row.Amount_Text:SetText("")
    elseif Private:IsSecret(DeathTime) then
        Row.Amount_Text:SetFormattedText("%.0fs", DeathTime)
    elseif DeathTime and DeathTime >= 0 then
        Row.Amount_Text:SetText(SecondsToClock(DeathTime))
    else
        Row.Amount_Text:SetText("")
    end
end

local function RefreshDeathRecap(Drilldown, Row, CreateEntry)
    local RecapID = Row.CombatSource.deathRecapID
    if Private:IsSecret(RecapID) or not RecapID or RecapID == 0 then Drilldown:Hide() return end

    local Events = C_DeathRecap.GetRecapEvents(RecapID)
    if not Events or #Events == 0 then Drilldown:Hide() return end

    local DB = Row.DamageMeterDB
    local MaxHealth = C_DeathRecap.GetRecapMaxHealth(RecapID)
    local HasMaxHealth = Private:IsSecret(MaxHealth) or (MaxHealth and MaxHealth > 0)
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
        Entry:SetPoint("TOPLEFT", Drilldown, "TOPLEFT", Inset, -Inset - ((i - 1) * BarHeight))
        Entry:SetPoint("BOTTOMRIGHT", Drilldown, "BOTTOMRIGHT", -Inset, Inset + ((RowCount - i) * BarHeight))
        local Amount = Event.amount
        if not Private:IsSecret(Amount) and not Amount then Amount = 0 end
        if HasMaxHealth then
            Entry.StatusBar:SetMinMaxValues(0, MaxHealth)
            Entry.StatusBar:SetValue(Amount)
        else
            Entry.StatusBar:SetMinMaxValues(0, 1)
            Entry.StatusBar:SetValue(1)
        end
        Entry.StatusBar:SetStatusBarColor(BarColour.r, BarColour.g, BarColour.b, BarColour.a or 1)

        local EventType = not Private:IsSecret(Event.event) and Event.event
        local EnvironmentalType = EventType == "ENVIRONMENTAL_DAMAGE" and not Private:IsSecret(Event.environmentalType) and Event.environmentalType and string.upper(Event.environmentalType)
        local SpellID = EventType == "SWING_DAMAGE" and 88163 or Event.spellId
        local SpellName = EventType == "SWING_DAMAGE" and ACTION_SWING or EnvironmentalType and (_G["ACTION_ENVIRONMENTAL_DAMAGE_" .. EnvironmentalType] or UNKNOWN) or Event.spellName
        local hasSpellID = Private:IsSecret(SpellID) or (SpellID and SpellID ~= 0)
        local SpellTexture = EnvironmentalType and "Interface\\Icons\\" .. (EnvironmentalIcons[EnvironmentalType] or "ability_creature_cursed_05") or hasSpellID and C_Spell.GetSpellTexture(SpellID)
        if hasSpellID and not Private:IsSecret(SpellName) and not SpellName then SpellName = C_Spell.GetSpellName(SpellID) end
        if not Private:IsSecret(SpellName) and not SpellName then SpellName = UNKNOWN end
        if not Private:IsSecret(SpellTexture) and not SpellTexture then SpellTexture = 134400 end
        Entry.Icon:SetTexture(SpellTexture)
        Entry.Name_Text:SetText(SpellName)

        local Damage = Private:AbbreviateValue(Amount)
        local CurrentHealth = Event.currentHP
        if not Private:IsSecret(MaxHealth) and HasMaxHealth and not Private:IsSecret(CurrentHealth) and CurrentHealth then
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
    Drilldown:SetSize(DB.Size[1], Inset * 2 + RowCount * BarHeight)

    return true
end

-- [[ Drilldown ]]
local function GetCreatureName(CombatSpell)
    local CreatureName = CombatSpell.creatureName
    if Private:IsSecret(CreatureName) or CreatureName == "" then return end
    return CreatureName
end

local function AddSection(Layout, CombatSpells, CreatureName)
    local RowCount = 0
    for i = 1, #CombatSpells do
        local CombatSpell = CombatSpells[i]
        if GetCreatureName(CombatSpell) == CreatureName then
            Layout[#Layout + 1] = CombatSpell
            RowCount = RowCount + 1
            if RowCount == MaxRowsPerSection then return end
        end
    end
end

local function CreateDrilldown(Row)
    if not Row.CombatSource then return end

    local DamageMeterFrame = Row.DamageMeterFrame
    local Frame = DamageMeterFrame.Drilldown

    if not Frame then
        local function SpellRow_UpdateSettings(Entry, DB)
            local TextDB = DB.Text
            local Font = Private:FetchFont(Private.E.db.general.font)

            Entry.StatusBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", DB.Texture))
            Private.E:SetFont(Entry.Amount_Text, Font, TextDB.Amount_FontSize, Private.E.db.general.fontStyle)
            Entry.Amount_Text:ClearAllPoints()
            Entry.Amount_Text:SetPoint("RIGHT", Entry.StatusBar, "RIGHT", TextDB.Amount_XOffset, TextDB.Amount_YOffset)
            Entry.Amount_Text:SetTextColor(unpack(TextDB.Amount_Colour))

            Private.E:SetFont(Entry.Name_Text, Font, TextDB.Name_FontSize, Private.E.db.general.fontStyle)
            Entry.Name_Text:ClearAllPoints()
            Entry.Name_Text:SetPoint("LEFT", Entry.StatusBar, "LEFT", TextDB.Name_XOffset, TextDB.Name_YOffset)
            Entry.Name_Text:SetPoint("RIGHT", Entry.Amount_Text, "LEFT", -TextPadding, TextDB.Name_YOffset - TextDB.Amount_YOffset)
            Entry.Name_Text:SetTextColor(unpack(TextDB.Name_Colour))
        end

        local function Separator_UpdateSettings(Separator, DB)
            local TextDB = DB.Text

            Private.E:SetFont(Separator.Name_Text, Private:FetchFont(Private.E.db.general.font), TextDB.Name_FontSize, Private.E.db.general.fontStyle)
            Separator.Left_Line:SetColorTexture(unpack(TextDB.Name_Colour))
            Separator.Right_Line:SetColorTexture(unpack(TextDB.Name_Colour))
        end

        local function Drilldown_UpdateSettings(Drilldown, DB)
            for _, Entry in ipairs(Drilldown.Rows) do
                Entry:UpdateSettings(DB)
            end
            for _, Separator in ipairs(Drilldown.Separators) do
                Separator:UpdateSettings(DB)
            end
        end

        local function CreateSpellRow(Drilldown, DB)
            local Entry = CreateFrame("Frame", nil, Drilldown)
            Entry:SetHeight(BarHeight)

            Entry.Icon = Entry:CreateTexture(nil, "OVERLAY")
            Entry.Icon:SetPoint("TOPLEFT", Entry, "TOPLEFT", 0, 0)
            Entry.Icon:SetSize(BarHeight, BarHeight)
            Entry.Icon:SetTexCoord(unpack(Private.E.TexCoords))

            Entry.StatusBar = CreateFrame("StatusBar", nil, Entry)
            Entry.StatusBar:SetPoint("TOPLEFT", Entry.Icon, "TOPRIGHT", Spacing, 0)
            Entry.StatusBar:SetPoint("BOTTOMRIGHT", Entry, "BOTTOMRIGHT", 0, 0)
            Entry.StatusBar:EnableMouse(false)

            Entry.Background = Entry.StatusBar:CreateTexture(nil, "BACKGROUND")
            Entry.Background:SetAllPoints(Entry.StatusBar)
            Entry.Background:SetColorTexture(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)

            Entry.Amount_Text = Entry.StatusBar:CreateFontString(nil, "OVERLAY")
            Entry.Amount_Text:SetJustifyH("RIGHT")
            Entry.Amount_Text:SetWordWrap(false)

            Entry.Name_Text = Entry.StatusBar:CreateFontString(nil, "OVERLAY")
            Entry.Name_Text:SetJustifyH("LEFT")
            Entry.Name_Text:SetWordWrap(false)

            Entry.UpdateSettings = SpellRow_UpdateSettings
            Entry:UpdateSettings(DB)

            return Entry
        end

        local function Drilldown_RefreshData(Drilldown)
            local SourceRow = Drilldown.Row
            local CombatSource = SourceRow and SourceRow.CombatSource
            if not CombatSource then Drilldown:Hide() return end

            local DB = SourceRow.DamageMeterDB

            for _, Separator in ipairs(Drilldown.Separators) do
                Separator:Hide()
            end

            if DB.MeterType == Enum.DamageMeterType.Deaths then
                return RefreshDeathRecap(Drilldown, SourceRow, CreateSpellRow)
            end

            if Private:IsSecret(CombatSource.sourceGUID) or Private:IsSecret(CombatSource.sourceCreatureID) then Drilldown:Hide() return end
            if not CombatSource.sourceGUID and not CombatSource.sourceCreatureID then Drilldown:Hide() return end
            if not C_DamageMeter.IsDamageMeterAvailable() then Drilldown:Hide() return end

            local GetSessionSource = DamageMeterFrame.SessionID and C_DamageMeter.GetCombatSessionSourceFromID or C_DamageMeter.GetCombatSessionSourceFromType
            local SessionSource = GetSessionSource(DamageMeterFrame.SessionID or DB.SessionType, DB.MeterType, CombatSource.sourceGUID, CombatSource.sourceCreatureID)
            local CombatSpells = SessionSource and SessionSource.combatSpells
            if not CombatSpells or #CombatSpells == 0 then Drilldown:Hide() return end

            local ClassColour = RAID_CLASS_COLORS[CombatSource.classFilename]
            local BarColour = ClassColour or Private.E.db.general.valuecolor
            local Layout = Drilldown.Layout
            local RowCount = 0
            local SeparatorCount = 0
            local OffsetY = Inset

            wipe(Layout)
            if PetSectionMeterTypes[DB.MeterType] then
                AddSection(Layout, CombatSpells)
                wipe(SeenCreatures)
                for i = 1, #CombatSpells do
                    local CreatureName = GetCreatureName(CombatSpells[i])
                    if CreatureName and not SeenCreatures[CreatureName] then
                        SeenCreatures[CreatureName] = true
                        Layout[#Layout + 1] = CreatureName
                        AddSection(Layout, CombatSpells, CreatureName)
                    end
                end
            else
                for i = 1, math.min(#CombatSpells, MaxRowsPerSection) do
                    Layout[i] = CombatSpells[i]
                end
            end

            for i = 1, #Layout do
                local LayoutItem = Layout[i]
                if type(LayoutItem) == "string" then
                    SeparatorCount = SeparatorCount + 1
                    local Separator = Drilldown.Separators[SeparatorCount]
                    if not Separator then
                        Separator = CreateFrame("Frame", nil, Drilldown)
                        Separator:SetHeight(SeparatorHeight)

                        Separator.Name_Text = Separator:CreateFontString(nil, "OVERLAY")
                        Separator.Name_Text:SetPoint("CENTER", Separator, "CENTER", 0, 0)
                        Separator.Name_Text:SetJustifyH("CENTER")
                        Separator.Name_Text:SetWordWrap(false)

                        Separator.Left_Line = Separator:CreateTexture(nil, "OVERLAY")
                        Separator.Left_Line:SetHeight(1)
                        Separator.Left_Line:SetPoint("LEFT", Separator, "LEFT", TextPadding, 0)
                        Separator.Left_Line:SetPoint("RIGHT", Separator.Name_Text, "LEFT", -TextPadding, 0)

                        Separator.Right_Line = Separator:CreateTexture(nil, "OVERLAY")
                        Separator.Right_Line:SetHeight(1)
                        Separator.Right_Line:SetPoint("LEFT", Separator.Name_Text, "RIGHT", TextPadding, 0)
                        Separator.Right_Line:SetPoint("RIGHT", Separator, "RIGHT", -TextPadding, 0)

                        Separator.UpdateSettings = Separator_UpdateSettings
                        Separator:UpdateSettings(DB)
                        Drilldown.Separators[SeparatorCount] = Separator
                    end
                    Separator:ClearAllPoints()
                    Separator:SetPoint("TOPLEFT", Drilldown, "TOPLEFT", Inset, -OffsetY)
                    Separator:SetPoint("TOPRIGHT", Drilldown, "TOPRIGHT", -Inset, -OffsetY)
                    Separator.Name_Text:SetText(LayoutItem)
                    Separator.Name_Text:SetTextColor(BarColour.r, BarColour.g, BarColour.b)
                    Separator:Show()
                    OffsetY = OffsetY + SeparatorHeight + Spacing
                else
                    RowCount = RowCount + 1
                    local CombatSpell = LayoutItem
                    local Entry = Drilldown.Rows[RowCount]
                    if not Entry then
                        Entry = CreateSpellRow(Drilldown, DB)
                        Drilldown.Rows[RowCount] = Entry
                    end
                    Entry:ClearAllPoints()
                    Entry:SetPoint("TOPLEFT", Drilldown, "TOPLEFT", Inset, -OffsetY)
                    Entry:SetPoint("TOPRIGHT", Drilldown, "TOPRIGHT", -Inset, -OffsetY)
                    Entry.StatusBar:SetMinMaxValues(0, SessionSource.maxAmount)
                    Entry.StatusBar:SetValue(CombatSpell.totalAmount)
                    Entry.StatusBar:SetStatusBarColor(BarColour.r, BarColour.g, BarColour.b, BarColour.a or 1)

                    local SpellID = CombatSpell.spellID
                    local UnitDetails = CombatSpell.combatSpellDetails
                    local UnitName = UnitDetails and UnitDetails.unitName
                    if DB.MeterType == Enum.DamageMeterType.EnemyDamageTaken and (Private:IsSecret(UnitName) or (UnitName and UnitName ~= "")) then
                        local SpecIconID = UnitDetails.specIconID
                        if Private:IsSecret(SpecIconID) or SpecIconID then
                            Entry.Icon:SetTexture(SpecIconID)
                        else
                            Entry.Icon:SetTexture(135274)
                        end
                        Entry.Name_Text:SetText(Private:StripRealm(UnitName, UnitDetails.unitClassFilename))
                    elseif not Private:IsSecret(SpellID) and SpellID == 0 then
                        Entry.Icon:SetTexture("Interface\\Icons\\INV_Sword_04")
                        Entry.Name_Text:SetText(ACTION_SWING)
                    else
                        local SpellName = C_Spell.GetSpellName(SpellID)
                        local SpellTexture = C_Spell.GetSpellTexture(SpellID)
                        if not Private:IsSecret(SpellName) and not SpellName then SpellName = UNKNOWN end
                        Entry.Icon:SetTexture(SpellTexture)
                        Entry.Name_Text:SetText(SpellName)
                    end
                    Entry.Amount_Text:SetText(Private:AbbreviateValue(CombatSpell.totalAmount))
                    Entry:Show()
                    OffsetY = OffsetY + BarHeight + Spacing
                end
            end
            for i = RowCount + 1, #Drilldown.Rows do
                Drilldown.Rows[i]:Hide()
            end

            Drilldown:SetSize(DB.Size[1], OffsetY - Spacing + Inset)

            return true
        end

        Frame = CreateFrame("Frame", nil, DamageMeterFrame, "BackdropTemplate")
        Frame:Hide()
        Frame:SetFrameStrata("TOOLTIP")
        Frame:SetClampedToScreen(true)
        Frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        Frame:SetBackdropColor(Private.E.BackgroundColour.r, Private.E.BackgroundColour.g, Private.E.BackgroundColour.b, Private.E.BackgroundColour.a)
        Frame:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
        Frame:EnableMouse(false)
        Frame.Rows = {}
        Frame.Separators = {}
        Frame.Layout = {}
        Frame.UpdateSettings = Drilldown_UpdateSettings
        Frame.RefreshData = Drilldown_RefreshData

        DamageMeterFrame.Drilldown = Frame
    end

    Frame.Row = Row
    Row.Drilldown = Frame
    local FrameParent = DamageMeterFrame.TitleBar ~= nil and DamageMeterFrame.TitleBar or DamageMeterFrame
    Frame:ClearAllPoints()
    Frame:SetPoint("BOTTOMRIGHT", FrameParent, "TOPRIGHT", 0, 1)
    if Frame:RefreshData() then Frame:Show() end

    return Frame
end

-- [[ Bookmarks ]]
local function CreateBookmarks(Frame)
    local DamageMeterFrame = Frame.DamageMeterFrame or Frame
    if not DamageMeterFrame.DamageMeterDB then DamageMeterFrame = Frame:GetParent() end
    local DB = DamageMeterFrame.DamageMeterDB

    if DamageMeterFrame.ShowingBookmarks then
        DamageMeterFrame:HideBookmarks()
        return
    end
    if DamageMeterFrame.ShowingCombatSessions then DamageMeterFrame:HideCombatSessions() end

    if not DamageMeterFrame.Bookmarks then
        local function Bookmarks_Hide(Window, MeterType)
            if MeterType ~= nil then DB.MeterType = MeterType end
            Window.ShowingBookmarks = false
            for _, Bookmark in ipairs(Window.Bookmarks) do
                Bookmark.Highlight:Hide()
                Bookmark:Hide()
            end
            Window.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType])
            Window:RefreshData(MeterType ~= nil)
            if MeterType == nil then
                Window.ScrollFrame:SetVerticalScroll(math.min(Window.DamageScrollOffset or 0, Window.ScrollRange))
            end
            Window.DamageScrollOffset = nil
        end

        local function Bookmark_OnEnter(Bookmark)
            Bookmark.Highlight:Show()
        end

        local function Bookmark_OnLeave(Bookmark)
            Bookmark.Highlight:Hide()
        end

        local function Bookmark_OnMouseDown(Bookmark, Button)
            if Button == "LeftButton" then
                DamageMeterFrame:HideBookmarks(Bookmark.MeterType)
            elseif Button == "RightButton" then
                if IsShiftKeyDown() then
                    DamageMeterFrame:ShowCombatSessions()
                else
                    DamageMeterFrame:HideBookmarks()
                end
            end
        end

        local function Bookmark_OnMouseWheel(_, Delta)
            DamageMeterFrame:ScrollRows(Delta)
        end

        local function Bookmarks_Refresh(Window)
            for _, Row in ipairs(Window.Rows) do
                Row.Highlight:Hide()
                Row:Hide()
            end
            if Window.Drilldown then Window.Drilldown:Hide() end

            local Height = DB.Size[2] - 2
            local RowHeight = Height / DB.Rows
            Window.ScrollRange = math.max(0, #MeterTypes * RowHeight - Height)
            Window.ScrollChild:SetSize(DB.Size[1] - 2, Height + Window.ScrollRange)
            Window.TitleBar.Text:SetText("Meter Types")

            for i, MeterType in ipairs(MeterTypes) do
                local Bookmark = Window.Bookmarks[i]
                if not Bookmark then
                    Bookmark = CreateFrame("Frame", nil, Window.ScrollChild, "BackdropTemplate")
                    Bookmark:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = nil, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
                    Bookmark:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)

                    Bookmark.Highlight = Bookmark:CreateTexture(nil, "OVERLAY")
                    Bookmark.Highlight:SetAllPoints(Bookmark)
                    Bookmark.Highlight:SetColorTexture(1, 1, 1, 0.25)
                    Bookmark.Highlight:Hide()

                    Bookmark.Text = Bookmark:CreateFontString(nil, "OVERLAY")
                    Private.E:SetFont(Bookmark.Text, Private:FetchFont(Private.E.db.general.font), 12, Private.E.db.general.fontStyle)
                    Bookmark.Text:SetPoint("CENTER", Bookmark, "CENTER", 0, 0)
                    Bookmark.Text:SetJustifyH("CENTER")
                    Bookmark.Text:SetWordWrap(false)

                    Bookmark:EnableMouse(true)
                    Bookmark:EnableMouseWheel(true)
                    Bookmark:SetScript("OnEnter", Bookmark_OnEnter)
                    Bookmark:SetScript("OnLeave", Bookmark_OnLeave)
                    Bookmark:SetScript("OnMouseDown", Bookmark_OnMouseDown)
                    Bookmark:SetScript("OnMouseWheel", Bookmark_OnMouseWheel)
                    Window.Bookmarks[i] = Bookmark
                end

                Bookmark.MeterType = MeterType
                Bookmark:ClearAllPoints()
                Bookmark:SetPoint("TOPLEFT", Window.ScrollChild, "TOPLEFT", 0, -((i - 1) * RowHeight))
                Bookmark:SetPoint("TOPRIGHT", Window.ScrollChild, "TOPRIGHT", 0, -((i - 1) * RowHeight))
                Bookmark:SetHeight(RowHeight)
                Bookmark.Text:SetText(Private.MeterTypes[MeterType])
                local Colour = MeterType == DB.MeterType and Private.E.db.general.valuecolor or nil
                if Colour then
                    Bookmark.Text:SetTextColor(Colour.r, Colour.g, Colour.b)
                else
                    Bookmark.Text:SetTextColor(unpack(DB.Text.Name_Colour))
                end
                Bookmark:Show()
            end

            for i = #MeterTypes + 1, #Window.Bookmarks do Window.Bookmarks[i]:Hide() end
            Window:ScrollRows(0)
        end

        DamageMeterFrame.Bookmarks = {}
        DamageMeterFrame.RefreshBookmarks = Bookmarks_Refresh
        DamageMeterFrame.HideBookmarks = Bookmarks_Hide
    end

    DamageMeterFrame.DamageScrollOffset = DamageMeterFrame.ScrollFrame:GetVerticalScroll()
    DamageMeterFrame.ShowingBookmarks = true
    DamageMeterFrame.ScrollFrame:SetVerticalScroll(0)
    DamageMeterFrame:RefreshBookmarks()
end

-- [[ Combat Sessions ]]
local function ShowCombatSessions(Frame)
    local DamageMeterFrame = Frame.DamageMeterFrame or Frame
    if not DamageMeterFrame.DamageMeterDB then DamageMeterFrame = Frame:GetParent() end
    local DB = DamageMeterFrame.DamageMeterDB

    if DamageMeterFrame.ShowingCombatSessions then DamageMeterFrame:HideCombatSessions() return end
    if DamageMeterFrame.ShowingBookmarks then DamageMeterFrame:HideBookmarks() end

    if not DamageMeterFrame.CombatSessions then
        local function CombatSessions_Hide(Window, Session)
            if Session then
                Window.SessionID = Session.SessionID
                Window.SessionName = Session.SessionName
            end
            Window.ShowingCombatSessions = false
            for _, Entry in ipairs(Window.CombatSessions) do
                Entry.Highlight:Hide()
                Entry:Hide()
            end
            Window:RefreshData(Session ~= nil)
            if not Session then
                Window.ScrollFrame:SetVerticalScroll(math.min(Window.DamageScrollOffset or 0, Window.ScrollRange))
            end
            Window.DamageScrollOffset = nil
        end

        local function Session_OnEnter(Entry)
            Entry.Highlight:Show()
        end

        local function Session_OnLeave(Entry)
            Entry.Highlight:Hide()
        end

        local function Session_OnMouseDown(Entry, Button)
            if Button == "LeftButton" then
                DamageMeterFrame:HideCombatSessions(Entry)
            elseif Button == "RightButton" then
                if IsShiftKeyDown() then
                    DamageMeterFrame:HideCombatSessions()
                else
                    CreateBookmarks(DamageMeterFrame)
                end
            end
        end

        local function Session_OnMouseWheel(_, Delta)
            DamageMeterFrame:ScrollRows(Delta)
        end

        local function CombatSessions_Refresh(Window)
            local Sessions = C_DamageMeter.GetAvailableCombatSessions()
            for _, Row in ipairs(Window.Rows) do
                Row.Highlight:Hide()
                Row:Hide()
            end
            if Window.Drilldown then Window.Drilldown:Hide() end

            local Height = DB.Size[2] - 2
            local RowHeight = Height / DB.Rows
            Window.ScrollRange = math.max(0, #Sessions * RowHeight - Height)
            Window.ScrollChild:SetSize(DB.Size[1] - 2, Height + Window.ScrollRange)
            Window.TitleBar.Text:SetText("Combat Sessions")

            for i, Session in ipairs(Sessions) do
                local Entry = Window.CombatSessions[i]
                if not Entry then
                    Entry = CreateFrame("Frame", nil, Window.ScrollChild, "BackdropTemplate")
                    Entry:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = nil, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
                    Entry:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)

                    Entry.Highlight = Entry:CreateTexture(nil, "OVERLAY")
                    Entry.Highlight:SetAllPoints(Entry)
                    Entry.Highlight:SetColorTexture(1, 1, 1, 0.25)
                    Entry.Highlight:Hide()

                    Entry.Amount_Text = Entry:CreateFontString(nil, "OVERLAY")
                    Private.E:SetFont(Entry.Amount_Text, Private:FetchFont(Private.E.db.general.font), DB.Text.Amount_FontSize, Private.E.db.general.fontStyle)
                    Entry.Amount_Text:SetPoint("RIGHT", Entry, "RIGHT", DB.Text.Amount_XOffset, DB.Text.Amount_YOffset)
                    Entry.Amount_Text:SetJustifyH("RIGHT")
                    Entry.Amount_Text:SetWordWrap(false)

                    Entry.Name_Text = Entry:CreateFontString(nil, "OVERLAY")
                    Private.E:SetFont(Entry.Name_Text, Private:FetchFont(Private.E.db.general.font), DB.Text.Name_FontSize, Private.E.db.general.fontStyle)
                    Entry.Name_Text:SetPoint("LEFT", Entry, "LEFT", DB.Text.Name_XOffset, DB.Text.Name_YOffset)
                    Entry.Name_Text:SetPoint("RIGHT", Entry.Amount_Text, "LEFT", -3, DB.Text.Name_YOffset)
                    Entry.Name_Text:SetJustifyH("LEFT")
                    Entry.Name_Text:SetWordWrap(false)

                    Entry:EnableMouse(true)
                    Entry:EnableMouseWheel(true)
                    Entry:SetScript("OnEnter", Session_OnEnter)
                    Entry:SetScript("OnLeave", Session_OnLeave)
                    Entry:SetScript("OnMouseDown", Session_OnMouseDown)
                    Entry:SetScript("OnMouseWheel", Session_OnMouseWheel)
                    Window.CombatSessions[i] = Entry
                end

                local Name = Session.name
                if not Name or Name == "" then Name = DAMAGE_METER_COMBAT_NUMBER:format(Session.sessionID) end
                Entry.SessionID = Session.sessionID
                Entry.SessionName = Name
                Entry:ClearAllPoints()
                Entry:SetPoint("TOPLEFT", Window.ScrollChild, "TOPLEFT", 0, -((i - 1) * RowHeight))
                Entry:SetPoint("TOPRIGHT", Window.ScrollChild, "TOPRIGHT", 0, -((i - 1) * RowHeight))
                Entry:SetHeight(RowHeight)
                Entry.Name_Text:SetText(Name)
                Entry.Amount_Text:SetText(Session.durationSeconds and SecondsToClock(Session.durationSeconds) or "")
                if Window.SessionID == Session.sessionID then
                    local Colour = Private.E.db.general.valuecolor
                    Entry.Name_Text:SetTextColor(Colour.r, Colour.g, Colour.b)
                    Entry.Amount_Text:SetTextColor(Colour.r, Colour.g, Colour.b)
                else
                    Entry.Name_Text:SetTextColor(unpack(DB.Text.Name_Colour))
                    Entry.Amount_Text:SetTextColor(unpack(DB.Text.Amount_Colour))
                end
                Entry:Show()
            end

            for i = #Sessions + 1, #Window.CombatSessions do Window.CombatSessions[i]:Hide() end
            Window:ScrollRows(0)
        end

        DamageMeterFrame.CombatSessions = {}
        DamageMeterFrame.RefreshCombatSessions = CombatSessions_Refresh
        DamageMeterFrame.HideCombatSessions = CombatSessions_Hide
    end

    DamageMeterFrame.DamageScrollOffset = DamageMeterFrame.ScrollFrame:GetVerticalScroll()
    DamageMeterFrame.ShowingCombatSessions = true
    DamageMeterFrame.ScrollFrame:SetVerticalScroll(0)
    DamageMeterFrame:RefreshCombatSessions()
end

-- [[ Rows ]]
local function CreateRow(DamageMeterFrame, RowCount, DamageMeterDB)
    local DB = DamageMeterDB
    local TextDB = DB.Text

    local function Row_OnEnter(Row)
        Row.Highlight:Show()
        CreateDrilldown(Row)
    end

    local function Row_OnLeave(Row)
        Row.Highlight:Hide()
        if Row.Drilldown and Row.Drilldown.Row == Row then Row.Drilldown:Hide() end
    end

    local function Row_OnSizeChanged(Row, _, Height)
        Row.Icon:SetSize(Height, Height)
    end

    local function Row_OnMouseWheel(_, Delta)
        DamageMeterFrame:ScrollRows(Delta)
    end

    local function Row_OnMouseDown(_, Button)
        if IsShiftKeyDown() and Button == "LeftButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "LeftButton" then
            -- Implement
        elseif IsShiftKeyDown() and Button == "RightButton" then
            ShowCombatSessions(DamageMeterFrame)
        elseif not IsShiftKeyDown() and Button == "RightButton" then
            CreateBookmarks(DamageMeterFrame)
        elseif IsShiftKeyDown() and Button == "MiddleButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "MiddleButton" then
            -- Implement
        end
    end

    local function Row_Clear(Row)
        if Row.Drilldown and Row.Drilldown.Row == Row then Row.Drilldown:Hide() end
        Row.CombatSource = nil
        Row.StatusBar:SetMinMaxValues(0, 1)
        Row.StatusBar:SetValue(0)
        Row.Name_Text:SetText("")
        Row.Amount_Text:SetText("")
        Row:Hide()
    end

    local function Row_Update(Row, CombatSource, MaxAmount)
        if not CombatSource then Row:Clear() return end

        Row.CombatSource = CombatSource

        local ClassColour = RAID_CLASS_COLORS[CombatSource.classFilename]
        local BarColour = ClassColour or Private.E.db.general.valuecolor
        local SpecIconID = CombatSource.specIconID

        if Row.Icon then
            if Private:IsSecret(SpecIconID) or (SpecIconID and SpecIconID ~= 0) then
                Row.Icon:SetTexture(SpecIconID)
            elseif ClassColour then
                Row.Icon:SetTexture("Interface\\Icons\\ClassIcon_" .. CombatSource.classFilename)
            else
                Row.Icon:SetTexture(135274)
            end
        end

        Row.StatusBar:SetStatusBarColor(BarColour.r, BarColour.g, BarColour.b, BarColour.a or 1)

        Row.Name_Text:SetText(Private:StripRealm(CombatSource.name, CombatSource.classFilename))

        if TextDB.Name_ColourByClass and ClassColour then
            Row.Name_Text:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b)
        else
            Row.Name_Text:SetTextColor(TextDB.Name_Colour[1], TextDB.Name_Colour[2], TextDB.Name_Colour[3])
        end

        if DB.MeterType == Enum.DamageMeterType.Deaths then
            UpdateDeathRow(Row)
        else
            Row.StatusBar:SetMinMaxValues(0, MaxAmount)
            Row.StatusBar:SetValue(CombatSource.totalAmount)

            if SingleMeterTypes[DB.MeterType] then
                Row.Amount_Text:SetText(Private:AbbreviateValue(CombatSource.totalAmount))
            elseif PerSecondMeterTypes[DB.MeterType] then
                Row.Amount_Text:SetText(Private:AbbreviateValue(CombatSource.amountPerSecond))
            else
                Row.Amount_Text:SetFormattedText(DB.Text.Amount_Format, Private:AbbreviateValue(CombatSource.totalAmount), Private:AbbreviateValue(CombatSource.amountPerSecond))
            end
        end

        if TextDB.Amount_ColourByClass and ClassColour then
            Row.Amount_Text:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b)
        else
            Row.Amount_Text:SetTextColor(TextDB.Amount_Colour[1], TextDB.Amount_Colour[2], TextDB.Amount_Colour[3])
        end

        Row:Show()
        if Row.Drilldown and Row.Drilldown.Row == Row and Row.Drilldown:IsShown() then Row.Drilldown:RefreshData() end
    end

    local RowHeight = (DB.Size[2] - 2) / DB.Rows

    local Row = CreateFrame("Frame", nil, DamageMeterFrame.ScrollChild, "BackdropTemplate")
    Row.DamageMeterDB = DB
    Row.DamageMeterFrame = DamageMeterFrame
    Row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = nil, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
    Row:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Row:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    Row:SetPoint("TOPLEFT", DamageMeterFrame.ScrollChild, "TOPLEFT", 0, -((RowCount - 1) * RowHeight))
    Row:SetPoint("TOPRIGHT", DamageMeterFrame.ScrollChild, "TOPRIGHT", 0, -((RowCount - 1) * RowHeight))
    Row:SetHeight(RowHeight)

    Row.Icon = Row:CreateTexture(nil, "OVERLAY")
    Row.Icon:SetPoint("LEFT", Row, "LEFT", 0, 0)
    Row.Icon:SetTexCoord(unpack(Private.E.TexCoords))
    Row.Icon:SetSize(RowHeight, RowHeight)

    Row.StatusBar = CreateFrame("StatusBar", nil, Row)
    Row.StatusBar:SetPoint("TOPLEFT", Row.Icon, "TOPRIGHT", 0, 0)
    Row.StatusBar:SetPoint("BOTTOMRIGHT", Row, "BOTTOMRIGHT", 0, 0)
    Row.StatusBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", DB.Texture))
    Row.StatusBar:SetStatusBarColor(Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b, Private.E.db.general.valuecolor.a)
    Row.StatusBar:SetMinMaxValues(0, 1)
    Row.StatusBar:SetValue(0)
    Row.StatusBar:EnableMouse(false)

    Row.Highlight = Row.StatusBar:CreateTexture(nil, "OVERLAY")
    Row.Highlight:SetAllPoints(Row.StatusBar)
    Row.Highlight:SetColorTexture(1, 1, 1, 0.25)
    Row.Highlight:Hide()

    Row.Name_Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
    Private.E:SetFont(Row.Name_Text, Private:FetchFont(Private.E.db.general.font), TextDB.Name_FontSize, Private.E.db.general.fontStyle)
    Row.Name_Text:SetTextColor(TextDB.Name_Colour[1], TextDB.Name_Colour[2], TextDB.Name_Colour[3])
    Row.Name_Text:SetPoint("LEFT", Row.StatusBar, "LEFT", TextDB.Name_XOffset, TextDB.Name_YOffset)
    Row.Name_Text:SetJustifyH("LEFT")

    Row.Amount_Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
    Private.E:SetFont(Row.Amount_Text, Private:FetchFont(Private.E.db.general.font), TextDB.Amount_FontSize, Private.E.db.general.fontStyle)
    Row.Amount_Text:SetTextColor(TextDB.Amount_Colour[1], TextDB.Amount_Colour[2], TextDB.Amount_Colour[3])
    Row.Amount_Text:SetPoint("RIGHT", Row.StatusBar, "RIGHT", TextDB.Amount_XOffset, TextDB.Amount_YOffset)
    Row.Amount_Text:SetJustifyH("RIGHT")

    Row:EnableMouse(true)
    Row:EnableMouseWheel(true)
    Row:SetScript("OnEnter", Row_OnEnter)
    Row:SetScript("OnLeave", Row_OnLeave)
    Row:SetScript("OnMouseDown", Row_OnMouseDown)
    Row:SetScript("OnSizeChanged", Row_OnSizeChanged)
    Row:SetScript("OnMouseWheel", Row_OnMouseWheel)

    Row.Clear = Row_Clear
    Row.Update = Row_Update
    Row:Clear()

    return Row
end

-- [[ Events ]]
local DamageMeterEventFrames = {}
local DamageMeterEventFrame = CreateFrame("Frame")

local function DamageMeter_OnEvent(_, Event, MeterType, SessionID)
    if Event == "CHALLENGE_MODE_START" then C_DamageMeter.ResetAllCombatSessions() return end

    for Frame in pairs(DamageMeterEventFrames) do
        local DB = Frame.DamageMeterDB
        if Event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
            local SelectedSessionID = not Frame.ShowingCombatSessions and Frame.SessionID
            if not Frame.ShowingBookmarks and MeterType == DB.MeterType and (SelectedSessionID == SessionID or (not SelectedSessionID and SessionID == 0)) then
                Frame:RefreshData()
            end
        elseif Event == "DAMAGE_METER_CURRENT_SESSION_UPDATED" then
            if not Frame.SessionID and DB.SessionType == Enum.DamageMeterSessionType.Current then
                Frame:RefreshData(true)
            elseif Frame.ShowingCombatSessions or Frame.SessionID then
                Frame:RefreshData()
            end
        elseif Event == "DAMAGE_METER_RESET" then
            Frame.SessionID = nil
            Frame.SessionName = nil
            Frame:RefreshData(true)
        elseif Event == "PLAYER_REGEN_ENABLED" then
            Frame:RefreshData()
        end
    end
end

DamageMeterEventFrame:SetScript("OnEvent", DamageMeter_OnEvent)

local function UpdateDamageMeterEvents(Frame)
    if Frame.DamageMeterDB.Enable then
        if not next(DamageMeterEventFrames) then
            DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
            DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
            DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_RESET")
            DamageMeterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            DamageMeterEventFrame:RegisterEvent("CHALLENGE_MODE_START")
        end
        DamageMeterEventFrames[Frame] = true
    else
        DamageMeterEventFrames[Frame] = nil
        if not next(DamageMeterEventFrames) then
            DamageMeterEventFrame:UnregisterAllEvents()
        end
    end
end

-- [[ Window ]]
local function CreateWindow(DamageMeterDB, DamageMeterCount)
    local DB = DamageMeterDB
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text

    local function Window_OnMouseDown(Frame, Button)
        if Button == "RightButton" then
            if IsShiftKeyDown() then
                ShowCombatSessions(Frame)
            else
                CreateBookmarks(Frame)
            end
        end
    end

    local function Window_OnMouseWheel(Frame, Delta)
        local CurrentOffset = Frame.ScrollFrame:GetVerticalScroll()
        local RowHeight = (DB.Size[2] - 2) / DB.Rows
        local Offset = math.max(0, math.min(Frame.ScrollRange, CurrentOffset - Delta * RowHeight))
        if Offset == CurrentOffset then return end
        Frame.ScrollFrame:SetVerticalScroll(Offset)
    end

    local function Window_RefreshRows(Frame)
        if not DB.Enable or not Frame:IsVisible() or Frame.ShowingCombatSessions or Frame.ShowingBookmarks then return end

        local CombatSession = Frame.CombatSession
        local CombatSources = CombatSession and CombatSession.combatSources
        local SourceCount = CombatSources and #CombatSources or 0
        local Height = DB.Size[2] - 2
        local RowHeight = Height / DB.Rows
        local Offset = Frame.ScrollFrame:GetVerticalScroll()
        local FirstSource = math.floor(Offset / RowHeight) + 1
        local LastSource = math.min(SourceCount, math.ceil((Offset + Height) / RowHeight))
        local RowCount = math.max(0, LastSource - FirstSource + 1)

        for i = 1, RowCount do
            local SourceIndex = FirstSource + i - 1
            local Row = Frame.Rows[i]
            if not Row then
                Row = CreateRow(Frame, i, DB)
                Frame.Rows[i] = Row
            end
            if Row.SourceIndex ~= SourceIndex then
                if Row.Drilldown and Row.Drilldown.Row == Row then Row.Drilldown:Hide() end
                Row.Highlight:Hide()
                Row:ClearAllPoints()
                Row:SetPoint("TOPLEFT", Frame.ScrollChild, "TOPLEFT", 0, -((SourceIndex - 1) * RowHeight))
                Row:SetPoint("TOPRIGHT", Frame.ScrollChild, "TOPRIGHT", 0, -((SourceIndex - 1) * RowHeight))
                Row.SourceIndex = SourceIndex
            end
            Row:Update(CombatSources[SourceIndex], CombatSession.maxAmount)
        end
        for i = RowCount + 1, #Frame.Rows do
            Frame.Rows[i]:Clear()
        end
    end

    local function Window_OnVerticalScroll(ScrollFrame)
        local Frame = ScrollFrame:GetParent()
        if Frame.Drilldown then Frame.Drilldown:Hide() end
        Frame:RefreshRows()
    end

    local function Window_RefreshData(Frame, ResetScroll)
        if not DB.Enable then return end
        if Frame.ShowingCombatSessions then
            if ResetScroll then Frame.DamageScrollOffset = 0 end
            Frame:RefreshCombatSessions()
            return
        end
        if Frame.ShowingBookmarks then
            if ResetScroll then Frame.DamageScrollOffset = 0 end
            Frame:RefreshBookmarks()
            return
        end

        local isAvailable = C_DamageMeter.IsDamageMeterAvailable()
        if isAvailable then
            if Frame.SessionID then
                local SessionFound = false
                for _, Session in ipairs(C_DamageMeter.GetAvailableCombatSessions()) do
                    if Session.sessionID == Frame.SessionID then
                        Frame.SessionName = Session.name
                        if not Frame.SessionName or Frame.SessionName == "" then
                            Frame.SessionName = DAMAGE_METER_COMBAT_NUMBER:format(Session.sessionID)
                        end
                        SessionFound = true
                        break
                    end
                end
                if not SessionFound then
                    Frame.SessionID = nil
                    Frame.SessionName = nil
                    ResetScroll = true
                end
            end
        end

        local GetCombatSession = Frame.SessionID and C_DamageMeter.GetCombatSessionFromID or C_DamageMeter.GetCombatSessionFromType
        local CombatSession = isAvailable and GetCombatSession(Frame.SessionID or DB.SessionType, DB.MeterType)
        Frame.CombatSession = CombatSession

        local CombatSources = CombatSession and CombatSession.combatSources
        local SourceCount = CombatSources and #CombatSources or 0
        local Height = DB.Size[2] - 2
        local RowHeight = Height / DB.Rows
        Frame.ScrollRange = math.max(0, SourceCount * RowHeight - Height)
        Frame.ScrollChild:SetSize(DB.Size[1] - 2, Height + Frame.ScrollRange)
        if ResetScroll then
            if Frame.Drilldown then Frame.Drilldown:Hide() end
            Frame.ScrollFrame:SetVerticalScroll(0)
        end

        local SessionName = Frame.SessionID and Frame.SessionName or (DB.SessionType == Enum.DamageMeterSessionType.Current and "" or "Overall")
        Frame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType] .. (SessionName ~= "" and " - " .. SessionName or ""))

        Frame:ScrollRows(0)
        Frame:RefreshRows()
    end

    local function Window_UpdateEnabled(Frame)
        UpdateDamageMeterEvents(Frame)
        if DB.Enable then
            if Frame:IsShown() then
                Frame:RefreshData()
            else
                Frame:Show()
            end
        else
            Frame.CombatSession = nil
            if Frame.Drilldown then Frame.Drilldown:Hide() end
            if Frame.ShowingBookmarks then Frame:HideBookmarks() end
            if Frame.ShowingCombatSessions then Frame:HideCombatSessions() end
            Frame:Hide()
        end
    end

    local function TitleBar_OnEnter(TitleBar)
        TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r * LightenFactor, Private.E.BackgroundFadeColour.g * LightenFactor, Private.E.BackgroundFadeColour.b * LightenFactor, Private.E.BackgroundFadeColour.a)
        GameTooltip:SetOwner(TitleBar, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOMRIGHT", TitleBar, "TOPRIGHT", 0, 1)
        GameTooltip:AddDoubleLine("|cFFFFCC00Left Click|r", "Swap Sessions - Current or Overall", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("|cFFFFCC00Right Click|r", "Meter Types", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("|cFFFFCC00Shift + Right Click|r", "Combat Sessions", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("|cFFFFCC00Middle Click|r", "Reset Damage Meters", 1, 1, 1, 1, 1, 1)
        GameTooltip:Show()
    end

    local function TitleBar_OnLeave(TitleBar)
        TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
        GameTooltip:Hide()
    end

    local function TitleBar_OnMouseDown(TitleBar, Button)
        if IsShiftKeyDown() and Button == "LeftButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "LeftButton" then
            local Window = TitleBar:GetParent()
            if Window.SessionID then
                DB.SessionType = Enum.DamageMeterSessionType.Current
            elseif DB.SessionType == Enum.DamageMeterSessionType.Current then
                DB.SessionType = Enum.DamageMeterSessionType.Overall
            else
                DB.SessionType = Enum.DamageMeterSessionType.Current
            end
            Window.SessionID = nil
            Window.SessionName = nil
            if Window.ShowingCombatSessions then
                Window.DamageScrollOffset = 0
                Window:HideCombatSessions()
            elseif Window.ShowingBookmarks then
                Window.DamageScrollOffset = 0
                Window:HideBookmarks()
            else
                Window:RefreshData(true)
            end
        elseif IsShiftKeyDown() and Button == "RightButton" then
            Window_OnMouseDown(TitleBar:GetParent(), Button)
        elseif not IsShiftKeyDown() and Button == "RightButton" then
            Window_OnMouseDown(TitleBar:GetParent(), Button)
        elseif IsShiftKeyDown() and Button == "MiddleButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "MiddleButton" then
            local Window = TitleBar:GetParent()
            Window.SessionID = nil
            Window.SessionName = nil
            C_DamageMeter.ResetAllCombatSessions()
            if Window.ShowingCombatSessions then
                Window:HideCombatSessions()
            elseif Window.ShowingBookmarks then
                Window:HideBookmarks()
            end
        end
    end

    local Frame = CreateFrame("Frame", "DamageMeter_0" .. DamageMeterCount, UIParent, "BackdropTemplate")
    Frame.DamageMeterDB = DB
    Frame:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(DB.Size[1], DB.Size[2])

    if DB.ShowBackdrop then
        Frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        Frame:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
        Frame:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    else
        Frame:SetBackdrop(nil)
    end

    Frame.ScrollRange = 0
    Frame.ScrollRows = Window_OnMouseWheel
    Frame:EnableMouse(true)
    Frame:EnableMouseWheel(true)
    Frame:SetScript("OnMouseDown", Window_OnMouseDown)
    Frame:SetScript("OnMouseWheel", Window_OnMouseWheel)

    Frame.ScrollFrame = CreateFrame("ScrollFrame", nil, Frame)
    Frame.ScrollFrame:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
    Frame.ScrollFrame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
    Frame.ScrollFrame:EnableMouse(true)
    Frame.ScrollFrame:EnableMouseWheel(true)
    Frame.ScrollFrame:SetScript("OnMouseDown", function(_, Button) Window_OnMouseDown(Frame, Button) end)
    Frame.ScrollFrame:SetScript("OnMouseWheel", function(_, Delta) Frame:ScrollRows(Delta) end)
    Frame.ScrollChild = CreateFrame("Frame", nil, Frame.ScrollFrame)
    Frame.ScrollChild:SetSize(DB.Size[1] - 2, DB.Size[2] - 2)
    Frame.ScrollFrame:SetScrollChild(Frame.ScrollChild)

    Frame.TitleBar = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
    Frame.TitleBar:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", TitleBarDB.XOffset, TitleBarDB.YOffset)
    Frame.TitleBar:SetSize(DB.Size[1], TitleBarDB.Height)

    if TitleBarDB.ShowBackdrop then
        Frame.TitleBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        Frame.TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
        Frame.TitleBar:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    else
        Frame.TitleBar:SetBackdrop(nil)
    end

    Frame.TitleBar:EnableMouse(true)
    Frame.TitleBar:SetScript("OnEnter", TitleBar_OnEnter)
    Frame.TitleBar:SetScript("OnLeave", TitleBar_OnLeave)
    Frame.TitleBar:SetScript("OnMouseDown", TitleBar_OnMouseDown)

    Frame.TitleBar.Text = Frame.TitleBar:CreateFontString(nil, "OVERLAY")
    Frame.TitleBar.Text:SetPoint(TitleBarTextDB.Layout[1], Frame.TitleBar, TitleBarTextDB.Layout[2], TitleBarTextDB.Layout[3], TitleBarTextDB.Layout[4])
    Private.E:SetFont(Frame.TitleBar.Text, Private:FetchFont(Private.E.db.general.font), TitleBarTextDB.FontSize, Private.E.db.general.fontStyle)
    Frame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType])
    Frame.TitleBar.Text:SetTextColor(TitleBarTextDB.Colour[1], TitleBarTextDB.Colour[2], TitleBarTextDB.Colour[3])
    Frame.TitleBar:SetShown(TitleBarDB.Enable)
    Frame.TitleBar.Text:SetShown(TitleBarTextDB.Enable)

    Frame.Rows = {}

    for i = 1, DB.Rows do
        Frame.Rows[i] = CreateRow(Frame, i, DB)
    end

    Frame.RefreshData = Window_RefreshData
    Frame.RefreshRows = Window_RefreshRows
    Frame.UpdateEnabled = Window_UpdateEnabled
    Frame.ShowCombatSessions = ShowCombatSessions
    Frame:SetScript("OnShow", Window_RefreshData)
    Frame.ScrollFrame:SetScript("OnVerticalScroll", Window_OnVerticalScroll)
    Frame:UpdateEnabled()

    return Frame
end

function Private:UpdateWindow(DamageMeterFrame, DamageMeterDB)
    local DB = DamageMeterDB
    local TextDB = DB.Text
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text

    if not DB.Enable then
        DamageMeterFrame:UpdateEnabled()
        return DamageMeterFrame
    end

    DamageMeterFrame:ClearAllPoints()
    DamageMeterFrame:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    DamageMeterFrame:SetSize(DB.Size[1], DB.Size[2])

    if DB.ShowBackdrop then
        DamageMeterFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        DamageMeterFrame:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
        DamageMeterFrame:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    else
        DamageMeterFrame:SetBackdrop(nil)
    end

    local RowHeight = (DB.Size[2] - 2) / DB.Rows
    local Texture = Private.LSM:Fetch("statusbar", DB.Texture)
    local Font = Private:FetchFont(Private.E.db.general.font)
    for i = 1, math.max(DB.Rows, #DamageMeterFrame.Rows) do
        local Row = DamageMeterFrame.Rows[i]
        if not Row then
            Row = CreateRow(DamageMeterFrame, i, DB)
            DamageMeterFrame.Rows[i] = Row
        end
        local SourceIndex = Row.SourceIndex or i
        Row:ClearAllPoints()
        Row:SetPoint("TOPLEFT", DamageMeterFrame.ScrollChild, "TOPLEFT", 0, -((SourceIndex - 1) * RowHeight))
        Row:SetPoint("TOPRIGHT", DamageMeterFrame.ScrollChild, "TOPRIGHT", 0, -((SourceIndex - 1) * RowHeight))
        Row:SetHeight(RowHeight)

        Row.StatusBar:SetStatusBarTexture(Texture)
        Private.E:SetFont(Row.Name_Text, Font, TextDB.Name_FontSize, Private.E.db.general.fontStyle)
        Row.Name_Text:ClearAllPoints()
        Row.Name_Text:SetPoint("LEFT", Row.StatusBar, "LEFT", TextDB.Name_XOffset, TextDB.Name_YOffset)
        Private.E:SetFont(Row.Amount_Text, Font, TextDB.Amount_FontSize, Private.E.db.general.fontStyle)
        Row.Amount_Text:ClearAllPoints()
        Row.Amount_Text:SetPoint("RIGHT", Row.StatusBar, "RIGHT", TextDB.Amount_XOffset, TextDB.Amount_YOffset)
        Row:Show()
    end

    DamageMeterFrame.TitleBar:ClearAllPoints()
    DamageMeterFrame.TitleBar:SetPoint("BOTTOMLEFT", DamageMeterFrame, "TOPLEFT", TitleBarDB.XOffset, TitleBarDB.YOffset)
    DamageMeterFrame.TitleBar:SetSize(DB.Size[1], TitleBarDB.Height)

    if TitleBarDB.ShowBackdrop then
        DamageMeterFrame.TitleBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        DamageMeterFrame.TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
        DamageMeterFrame.TitleBar:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    else
        DamageMeterFrame.TitleBar:SetBackdrop(nil)
    end

    DamageMeterFrame.TitleBar.Text:ClearAllPoints()
    DamageMeterFrame.TitleBar.Text:SetPoint(TitleBarTextDB.Layout[1], DamageMeterFrame.TitleBar, TitleBarTextDB.Layout[2], TitleBarTextDB.Layout[3], TitleBarTextDB.Layout[4])
    Private.E:SetFont(DamageMeterFrame.TitleBar.Text, Private:FetchFont(Private.E.db.general.font), TitleBarTextDB.FontSize, Private.E.db.general.fontStyle)
    DamageMeterFrame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType])
    DamageMeterFrame.TitleBar.Text:SetTextColor(TitleBarTextDB.Colour[1], TitleBarTextDB.Colour[2], TitleBarTextDB.Colour[3])
    DamageMeterFrame.TitleBar:SetShown(TitleBarDB.Enable)
    DamageMeterFrame.TitleBar.Text:SetShown(TitleBarTextDB.Enable)

    if DamageMeterFrame.Drilldown then DamageMeterFrame.Drilldown:UpdateSettings(DB) end
    DamageMeterFrame:UpdateEnabled()

    return DamageMeterFrame
end

-- [[ Setup ]]
function Private:SetupDamageMeters()
    for i in pairs(Private.DB.global.DamageMeter) do
        local DB = Private.DB.global.DamageMeter[i]
        if DB.Enable then
            CreateWindow(DB, i)
        end
    end
end

function Private:UpdateDamageMeters()
    for i in pairs(Private.DB.global.DamageMeter) do
        local DB = Private.DB.global.DamageMeter[i]
        local Frame = _G["DamageMeter_0"..i]
        if Frame then
            Private:UpdateWindow(Frame, DB)
        elseif DB.Enable then
            CreateWindow(DB, i)
        end
    end
end
