local Private = select(2, ...)
local LIGHTEN_FACTOR = 2

function Private:CreateRow(DamageMeterFrame, RowCount, DamageMeterDB)
    local DB = DamageMeterDB
    local TextDB = DB.Text

    local function Row_OnEnter(Row)
        Row.Highlight:Show()
    end

    local function Row_OnLeave(Row)
        Row.Highlight:Hide()
    end

    local function Row_OnSizeChanged(Row, _, Height)
        Row.Icon:SetSize(Height, Height)
    end

    local function Row_OnMouseDown(_, Button)
        if IsShiftKeyDown() and Button == "LeftButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "LeftButton" then
            -- Implement
        elseif IsShiftKeyDown() and Button == "RightButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "RightButton" then
            -- Implement
        elseif IsShiftKeyDown() and Button == "MiddleButton" then
            -- Implement
        elseif not IsShiftKeyDown() and Button == "MiddleButton" then
            -- Implement
        end
    end

    local function Row_Clear(Row)
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
        if Row.Icon then
            Row.Icon:SetTexture(CombatSource.specIconID)
        end

        Row.StatusBar:SetStatusBarColor(BarColour.r, BarColour.g, BarColour.b, BarColour.a or 1)
        Row.StatusBar:SetMinMaxValues(0, MaxAmount)
        Row.StatusBar:SetValue(CombatSource.totalAmount)

        Row.Name_Text:SetText(CombatSource.name)
        if TextDB.Name_ColourByClass and ClassColour then
            Row.Name_Text:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b)
        else
            Row.Name_Text:SetTextColor(TextDB.Name_Colour[1], TextDB.Name_Colour[2], TextDB.Name_Colour[3])
        end

        if DB.MeterType == Enum.DamageMeterType.Dps or DB.MeterType == Enum.DamageMeterType.Hps then
            Row.Amount_Text:SetText(AbbreviateLargeNumbers(CombatSource.amountPerSecond))
        else
            Row.Amount_Text:SetText(AbbreviateLargeNumbers(CombatSource.totalAmount))
        end

        if TextDB.Amount_ColourByClass and ClassColour then
            Row.Amount_Text:SetTextColor(ClassColour.r, ClassColour.g, ClassColour.b)
        else
            Row.Amount_Text:SetTextColor(TextDB.Amount_Colour[1], TextDB.Amount_Colour[2], TextDB.Amount_Colour[3])
        end

        Row:Show()
    end

    local RowHeight = (DB.Size[2] - 2) / DB.Rows

    local Row = CreateFrame("Frame", nil, DamageMeterFrame, "BackdropTemplate")
    Row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = nil, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
    Row:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Row:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    Row:SetPoint("TOPLEFT", DamageMeterFrame, "TOPLEFT", 1, -1 - ((RowCount - 1) * RowHeight))
    Row:SetPoint("BOTTOMRIGHT", DamageMeterFrame, "BOTTOMRIGHT", -1, 1 + ((DB.Rows - RowCount) * RowHeight))

    Row.Icon = Row:CreateTexture(nil, "OVERLAY")
    Row.Icon:SetPoint("LEFT", Row, "LEFT", 0, 0)
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
    Row:SetScript("OnEnter", Row_OnEnter)
    Row:SetScript("OnLeave", Row_OnLeave)
    Row:SetScript("OnMouseDown", Row_OnMouseDown)
    Row:SetScript("OnSizeChanged", Row_OnSizeChanged)

    Row.Clear = Row_Clear
    Row.Update = Row_Update
    Row:Clear()

    return Row
end
