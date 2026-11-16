local Private = select(2, ...)
local BarHeight = 24
local SeparatorHeight = 18
local Spacing = 0
local Inset = 1
local TextPadding = 3
local MaxRowsPerSection = 10

local PetSectionMeterTypes = {
    [Enum.DamageMeterType.DamageDone] = true,
    [Enum.DamageMeterType.Dps] = true,
}

local SeenCreatures = {}

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

function Private:CreateDrilldown(Row)
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
                return Private:RefreshDeathRecap(Drilldown, SourceRow, CreateSpellRow)
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
