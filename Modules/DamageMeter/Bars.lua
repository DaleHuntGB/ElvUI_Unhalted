local Private = select(2, ...)

local function Bar_OnEnter(DMBar)
    DMBar.Highlight:Show()
end

local function Bar_OnLeave(DMBar)
    DMBar.Highlight:Hide()
end

local function Bar_OnClick(DMBar, Button)
    if Button == "LeftButton" then
        Private:Drilldown(DMBar)
    end
end

function Private:Drilldown(DMBar)
    local DMFrame = DMBar:GetParent()
    local DB = DMFrame.DB
    local DataSource = DMBar.DataSource
    local Popup = Private.DamageMeterDrilldown

    if Popup then Popup:Hide() end
    if Private.DamageMeterTestMode or not DataSource or not C_DamageMeter.IsDamageMeterAvailable() then return end

    if DB.MeterType == Enum.DamageMeterType.Deaths then
        local RecapID = DataSource.deathRecapID
        if not issecretvalue(RecapID) and RecapID and RecapID ~= 0 then OpenDeathRecapUI(RecapID) end
        return
    end

    if issecretvalue(DataSource.sourceGUID) or issecretvalue(DataSource.sourceCreatureID) then return end

    local SessionSource;

    if DMFrame.EncounterSegment then
        SessionSource = C_DamageMeter.GetCombatSessionSourceFromID(DMFrame.EncounterSegment.sessionID, DB.MeterType, DataSource.sourceGUID, DataSource.sourceCreatureID)
    else
        SessionSource = C_DamageMeter.GetCombatSessionSourceFromType(DMFrame.SessionType, DB.MeterType, DataSource.sourceGUID, DataSource.sourceCreatureID)
    end

    if not SessionSource then return end

    if not Popup then
        Popup = Private:CreateDrilldownPopup(nil, DB)

        Private.DamageMeterDrilldown = Popup

        Popup:SetFrameStrata("DIALOG")
        Popup:SetClampedToScreen(true)
        Popup:EnableMouse(true)
        Popup:EnableMouseWheel(true)

        Popup.TitleBar:SetScript("OnEnter", nil)
        Popup.TitleBar:SetScript("OnLeave", nil)
        Popup.TitleBar:SetScript("OnMouseDown", nil)

        Popup.Close = CreateFrame("Button", nil, Popup.TitleBar)
        Popup.Close:SetPoint("RIGHT", Popup.TitleBar, "RIGHT", -1, 0)
        Popup.Close:SetScript("OnClick", function() Popup:Hide() end)
        Popup.Close:SetNormalTexture("Interface\\AddOns\\ElvUI_Unhalted\\Media\\DamageMeter\\Close.png")
        Popup.Close:SetHighlightTexture("Interface\\AddOns\\ElvUI_Unhalted\\Media\\DamageMeter\\Close_Highlight.png", "BLEND")
        Popup:SetScript("OnHide", function(DMFramePopup) DMFramePopup:SetScript("OnMouseWheel", nil) end)

    else
        Private:LayoutDrilldownPopup(Popup, DB)
    end

    Popup:SetParent(DMFrame)
    Popup:ClearAllPoints()
    Popup:SetPoint("BOTTOMRIGHT", DMFrame.TitleBar, "TOPRIGHT", 0, 1)

    Popup.TitleBar:Show()
    Popup.Title:SetText(DataSource.name)
    Popup.Title:SetWordWrap(false)
    Popup.Title:SetPoint("RIGHT", Popup.Close, "LEFT", -3, 0)
    Popup.Close:SetSize(DB.TitleBar.Height * 0.7, DB.TitleBar.Height * 0.7)

    local Spells = SessionSource.combatSpells
    local ClassColour = DataSource.classFilename ~= "" and C_ClassColor.GetClassColor(DataSource.classFilename)
    local Offset = 0

    local function PopulateSpells(_, Delta)
        Offset = math.max(0, math.min(math.max(0, #Spells - DB.Rows.Num), Offset - Delta))
        for IDX = 1, DB.Rows.Num do
            local Bar = Popup.Bars[IDX]
            local Spell = Spells[IDX + Offset]
            Bar:SetScript("OnMouseDown", nil)
            Bar:EnableMouse(false)
            if Spell then
                if DB.Name.ColourByClass and ClassColour then
                    Bar.Name:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Name.Colour[4])
                else
                    Bar.Name:SetTextColor(unpack(DB.Name.Colour))
                end

                if DB.Amount.ColourByClass and ClassColour then
                    Bar.Number:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Amount.Colour[4])
                else
                    Bar.Number:SetTextColor(unpack(DB.Amount.Colour))
                end

                Bar:SetMinMaxValues(0, SessionSource.maxAmount)
                Bar:SetValue(Spell.totalAmount)
                if ClassColour then
                    Bar:SetStatusBarColor(ClassColour.r, ClassColour.g, ClassColour.b)
                else
                    Bar:SetStatusBarColor(0.6, 0.6, 0.6)
                end
                if not issecretvalue(Spell.spellID) then
                    Bar.Name:SetText(C_Spell.GetSpellName(Spell.spellID) or UNKNOWN)
                    Bar.Icon:SetTexture(C_Spell.GetSpellTexture(Spell.spellID) or 135274)
                else
                    Bar.Name:SetText(UNKNOWN)
                    Bar.Icon:SetTexture(135274)
                end
                Bar.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
                Bar.Number:SetText(AbbreviateNumbers(Spell.totalAmount))
            end
            Bar:SetShown(Spell ~= nil)
            Bar.Icon:SetShown(Spell ~= nil)
        end
    end

    PopulateSpells(nil, 0)
    Popup:SetScript("OnMouseWheel", PopulateSpells)
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
        DMBar:SetSize(DB.Size[1] - rowHeight - 2, rowHeight)
        DMBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", DB.Rows.Texture))

        DMBar:SetScript("OnEnter", Bar_OnEnter)
        DMBar:SetScript("OnLeave", Bar_OnLeave)
        DMBar:SetScript("OnMouseDown", Bar_OnClick)

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
        DMBar.Name:SetPoint(DB.Name.Layout[1], DMBar, DB.Name.Layout[2], DB.Name.Layout[3], DB.Name.Layout[4])
        DMBar.Name:SetFont(Private.LSM:Fetch("font", DB.Name.Font[1]), DB.Name.Font[2], DB.Name.Font[3])
        DMBar.Name:SetTextColor(unpack(DB.Name.Colour))

        DMBar.Number:ClearAllPoints()
        DMBar.Number:SetPoint(DB.Amount.Layout[1], DMBar, DB.Amount.Layout[2], DB.Amount.Layout[3], DB.Amount.Layout[4])
        DMBar.Number:SetFont(Private.LSM:Fetch("font", DB.Amount.Font[1]), DB.Amount.Font[2], DB.Amount.Font[3])
        DMBar.Number:SetTextColor(unpack(DB.Amount.Colour))

        if DB.Name.Layout[1] == "LEFT" and DB.Amount.Layout[1] == "RIGHT" then DMBar.Name:SetPoint("RIGHT", DMBar.Number, "LEFT", -3, 0) end

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

-- The same sample names and classes used by Blizzard's Damage Meter in Edit Mode
-- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_DamageMeter/DamageMeterSessionWindow.lua#L76-L89
local TestSources = {
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_1, classFilename = "DEATHKNIGHT" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_2, classFilename = "MAGE" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_3, classFilename = "WARLOCK" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_7, classFilename = "HUNTER" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_6, classFilename = "DEMONHUNTER" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_4, classFilename = "SHAMAN" },
    { name = DAMAGE_METER_EDIT_MODE_SOURCE_5, classFilename = "PALADIN" },
}

local TestSessions = {}

-- Thank you Luckyone for this idea
-- https://github.com/Luckyone961/LuckyoneUI/blob/development/LuckyoneUI/Modules/DamageMeter/Session.lua#L126-L155
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

function Private:PopulateDamageMeterBars(DMFrame, DB)
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
        DMBar.DataSource = DataSource
        if DataSource then
            local ClassColour = DataSource.classFilename ~= "" and C_ClassColor.GetClassColor(DataSource.classFilename)
            if DB.Name.ColourByClass and ClassColour then
                DMBar.Name:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Name.Colour[4])
            else
                DMBar.Name:SetTextColor(unpack(DB.Name.Colour))
            end

            if DB.Amount.ColourByClass and ClassColour then
                DMBar.Number:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b, DB.Amount.Colour[4])
            else
                DMBar.Number:SetTextColor(unpack(DB.Amount.Colour))
            end

            if ClassColour then
                DMBar:SetStatusBarColor(ClassColour.r, ClassColour.g, ClassColour.b)
            else
                DMBar:SetStatusBarColor(0.6, 0.6, 0.6)
            end
            DMBar.Name:SetText(DataSource.name)

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
                    DMBar.Number:SetText(AbbreviateNumbers(DataSource.totalAmount))
                elseif PerSecondMeterTypes[DB.MeterType] then
                    DMBar.Number:SetText(AbbreviateNumbers(DataSource.amountPerSecond))
                else
                    DMBar.Number:SetFormattedText("%s • %s", AbbreviateNumbers(DataSource.totalAmount), AbbreviateNumbers(DataSource.amountPerSecond))
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
