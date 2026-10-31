local Private = select(2, ...)

function Private:CreateMythicPlusRow(Window, Index, DB)
    local function Row_UpdateSettings(Row, Settings)
        local TextDB = Settings.Text
        local Font = Private:FetchFont(Private.E.db.general.font)
        Row:ClearAllPoints()
        Row:SetPoint("TOPLEFT", Window, "TOPLEFT", 1, -1 - ((Index - 1) * Settings.RowHeight))
        Row:SetPoint("TOPRIGHT", Window, "TOPRIGHT", -1, -1 - ((Index - 1) * Settings.RowHeight))
        Row:SetHeight(Settings.RowHeight)
        Row.StatusBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", Settings.Texture))
        Private.E:SetFont(Row.Name_Text, Font, TextDB.Name_FontSize, Private.E.db.general.fontStyle)
        Private.E:SetFont(Row.Amount_Text, Font, TextDB.Amount_FontSize, Private.E.db.general.fontStyle)
        Row.Amount_Text:ClearAllPoints()
        Row.Amount_Text:SetPoint("RIGHT", Row.StatusBar, "RIGHT", TextDB.Amount_XOffset, TextDB.Amount_YOffset)
        Row.Amount_Text:SetTextColor(unpack(TextDB.Amount_Colour))
        Row.Name_Text:ClearAllPoints()
        Row.Name_Text:SetPoint("LEFT", Row.StatusBar, "LEFT", TextDB.Name_XOffset, TextDB.Name_YOffset)
        Row.Name_Text:SetPoint("RIGHT", Row.Amount_Text, "LEFT", -3, TextDB.Name_YOffset - TextDB.Amount_YOffset)
        Row.Name_Text:SetTextColor(unpack(TextDB.Name_Colour))
    end

    local Row = CreateFrame("Frame", nil, Window)
    Row.StatusBar = CreateFrame("StatusBar", nil, Row)
    Row.StatusBar:SetAllPoints(Row)
    Row.StatusBar:EnableMouse(false)
    Row.Background = Row.StatusBar:CreateTexture(nil, "BACKGROUND")
    Row.Background:SetAllPoints(Row.StatusBar)
    Row.Background:SetColorTexture(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Row.Name_Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
    Row.Name_Text:SetJustifyH("LEFT")
    Row.Name_Text:SetWordWrap(false)
    Row.Amount_Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
    Row.Amount_Text:SetJustifyH("RIGHT")
    Row.Amount_Text:SetWordWrap(false)
    Row.UpdateSettings = Row_UpdateSettings
    Row:UpdateSettings(DB)
    return Row
end
