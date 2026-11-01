local Private = select(2, ...)
local BAR_HEIGHT = 24
local SPACING = 0
local INSET = 1
local TEXT_PADDING = 3

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
            Entry.Name_Text:SetPoint("RIGHT", Entry.Amount_Text, "LEFT", -TEXT_PADDING, TextDB.Name_YOffset - TextDB.Amount_YOffset)
            Entry.Name_Text:SetTextColor(unpack(TextDB.Name_Colour))
        end

        local function Drilldown_UpdateSettings(Drilldown, DB)
            for _, Entry in ipairs(Drilldown.Rows) do
                Entry:UpdateSettings(DB)
            end
        end

        local function CreateSpellRow(Drilldown, DB)
            local Entry = CreateFrame("Frame", nil, Drilldown)

            Entry.Icon = Entry:CreateTexture(nil, "OVERLAY")
            Entry.Icon:SetPoint("TOPLEFT", Entry, "TOPLEFT", 0, 0)
            Entry.Icon:SetSize(BAR_HEIGHT, BAR_HEIGHT)
            Entry.Icon:SetTexCoord(unpack(Private.E.TexCoords))

            Entry.StatusBar = CreateFrame("StatusBar", nil, Entry)
            Entry.StatusBar:SetPoint("TOPLEFT", Entry.Icon, "TOPRIGHT", SPACING, 0)
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

            if DB.MeterType == Enum.DamageMeterType.Deaths then
                return Private:RefreshDeathRecap(Drilldown, SourceRow, CreateSpellRow)
            end

            if issecretvalue(CombatSource.sourceGUID) or issecretvalue(CombatSource.sourceCreatureID) then Drilldown:Hide() return end
            if not CombatSource.sourceGUID and not CombatSource.sourceCreatureID then Drilldown:Hide() return end
            if not C_DamageMeter.IsDamageMeterAvailable() then Drilldown:Hide() return end

            local SessionSource;
            if DamageMeterFrame.SessionID then
                SessionSource = C_DamageMeter.GetCombatSessionSourceFromID(DamageMeterFrame.SessionID, DB.MeterType, CombatSource.sourceGUID, CombatSource.sourceCreatureID)
            else
                SessionSource = C_DamageMeter.GetCombatSessionSourceFromType(DB.SessionType, DB.MeterType, CombatSource.sourceGUID, CombatSource.sourceCreatureID)
            end
            local CombatSpells = SessionSource and SessionSource.combatSpells
            if not CombatSpells or #CombatSpells == 0 then Drilldown:Hide() return end

            local ClassColour = RAID_CLASS_COLORS[CombatSource.classFilename]
            local BarColour = ClassColour or Private.E.db.general.valuecolor
            local Width = 0
            local RowCount = math.min(#CombatSpells, 10)

            for i = 1, RowCount do
                local CombatSpell = CombatSpells[i]
                local Entry = Drilldown.Rows[i]
                if not Entry then
                    Entry = CreateSpellRow(Drilldown, DB)
                    Drilldown.Rows[i] = Entry
                end
                Entry:ClearAllPoints()
                Entry:SetPoint("TOPLEFT", Drilldown, "TOPLEFT", INSET, -INSET - ((i - 1) * (BAR_HEIGHT + SPACING)))
                Entry:SetPoint("BOTTOMRIGHT", Drilldown, "BOTTOMRIGHT", -INSET, INSET + ((RowCount - i) * (BAR_HEIGHT + SPACING)))
                Entry.StatusBar:SetMinMaxValues(0, SessionSource.maxAmount)
                Entry.StatusBar:SetValue(CombatSpell.totalAmount)
                Entry.StatusBar:SetStatusBarColor(BarColour.r, BarColour.g, BarColour.b, BarColour.a or 1)

                local SpellID = CombatSpell.spellID
                local UnitDetails = CombatSpell.combatSpellDetails
                local UnitName = UnitDetails and UnitDetails.unitName
                if DB.MeterType == Enum.DamageMeterType.EnemyDamageTaken and (issecretvalue(UnitName) or (UnitName and UnitName ~= "")) then
                    local SpecIconID = UnitDetails.specIconID
                    if SpecIconID and SpecIconID ~= 0 then
                        Entry.Icon:SetTexture(SpecIconID)
                    else
                        Entry.Icon:SetTexture(135274)
                    end
                    Entry.Name_Text:SetText(Private:StripRealm(UnitName, UnitDetails.unitClassFilename))
                elseif not issecretvalue(SpellID) and SpellID == 0 then
                    Entry.Icon:SetTexture("Interface\\Icons\\INV_Sword_04")
                    Entry.Name_Text:SetText(ACTION_SWING)
                else
                    local SpellName = C_Spell.GetSpellName(SpellID)
                    local SpellTexture = C_Spell.GetSpellTexture(SpellID)
                    if not issecretvalue(SpellName) and not SpellName then SpellName = UNKNOWN end
                    Entry.Icon:SetTexture(SpellTexture)
                    Entry.Name_Text:SetText(SpellName)
                end
                Entry.Amount_Text:SetText(Private:AbbreviateValue(CombatSpell.totalAmount))

                local NameWidth = Entry.Name_Text:GetUnboundedStringWidth()
                local AmountWidth = Entry.Amount_Text:GetUnboundedStringWidth()
                if issecretvalue(NameWidth) or issecretvalue(AmountWidth) then
                    Width = math.max(Width, DB.Size[1] - INSET * 2)
                else
                    Width = math.max(Width, BAR_HEIGHT + SPACING + TEXT_PADDING * 3 + NameWidth + AmountWidth)
                end
                Entry:Show()
            end
            for i = RowCount + 1, #Drilldown.Rows do
                Drilldown.Rows[i]:Hide()
            end

            Drilldown:SetSize(DB.Size[1], INSET * 2 + RowCount * BAR_HEIGHT + (RowCount - 1) * SPACING)

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
