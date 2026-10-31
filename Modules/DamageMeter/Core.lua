local Private = select(2, ...)

local function CreateWindow(DamageMeterDB, DamageMeterCount)
    local DB = DamageMeterDB
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text

    local function TitleBar_OnEnter(TitleBar)
        TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r * LIGHTEN_FACTOR, Private.E.BackgroundFadeColour.g * LIGHTEN_FACTOR, Private.E.BackgroundFadeColour.b * LIGHTEN_FACTOR, Private.E.BackgroundFadeColour.a)
    end

    local function TitleBar_OnLeave(TitleBar)
        TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    end

    local function TitleBar_OnMouseDown(_, Button)
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

    local Frame = CreateFrame("Frame", "DamageMeter_0"..DamageMeterCount, UIParent, "BackdropTemplate")
    Frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
    Frame:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Frame:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    Frame:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(DB.Size[1], DB.Size[2])

    Frame.TitleBar = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
    Frame.TitleBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
    Frame.TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Frame.TitleBar:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    Frame.TitleBar:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", TitleBarDB.XOffset, TitleBarDB.YOffset)
    Frame.TitleBar:SetSize(DB.Size[1], TitleBarDB.Height)

    Frame.TitleBar:EnableMouse(true)
    Frame.TitleBar:SetScript("OnEnter", TitleBar_OnEnter)
    Frame.TitleBar:SetScript("OnLeave", TitleBar_OnLeave)
    Frame.TitleBar:SetScript("OnMouseDown", TitleBar_OnMouseDown)

    Frame.TitleBar.Text = Frame.TitleBar:CreateFontString(nil, "OVERLAY")
    Frame.TitleBar.Text:SetPoint(TitleBarTextDB.Layout[1], Frame.TitleBar, TitleBarTextDB.Layout[2], TitleBarTextDB.Layout[3], TitleBarTextDB.Layout[4])
    Private.E:SetFont(Frame.TitleBar.Text, Private:FetchFont(Private.E.db.general.font), TitleBarTextDB.FontSize, Private.E.db.general.fontStyle)
    Frame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType])
    Frame.TitleBar.Text:SetTextColor(TitleBarTextDB.Colour[1], TitleBarTextDB.Colour[2], TitleBarTextDB.Colour[3])

    return Frame
end

local function UpdateWindow(DamageMeterFrame, DamageMeterDB)
    local DB = DamageMeterDB
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text
    local TextDB = DB.Text

    DamageMeterFrame:ClearAllPoints()
    DamageMeterFrame:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    DamageMeterFrame:SetSize(DB.Size[1], DB.Size[2])

    local RowHeight = DB.Size[2] / DB.Rows
    for i = 1, DB.Rows do
        local Row = DamageMeterFrame.Rows[i]
        if not Row then
            Row = CreateRow(DamageMeterFrame, i, DB)
            DamageMeterFrame.Rows[i] = Row
        end
        Row:ClearAllPoints()
        Row:SetPoint("TOPLEFT", DamageMeterFrame, "TOPLEFT", 0, -((i - 1) * RowHeight))
        Row:SetSize(DB.Size[1], RowHeight)
        Row:Show()
    end

    for i = DB.Rows + 1, #DamageMeterFrame.Rows do
        DamageMeterFrame.Rows[i]:Hide()
    end

    DamageMeterFrame.TitleBar:ClearAllPoints()
    DamageMeterFrame.TitleBar:SetPoint("BOTTOMLEFT", DamageMeterFrame, "TOPLEFT", TitleBarDB.XOffset, TitleBarDB.YOffset)
    DamageMeterFrame.TitleBar:SetSize(DB.Size[1], TitleBarDB.Height)

    DamageMeterFrame.TitleBar.Text:ClearAllPoints()
    DamageMeterFrame.TitleBar.Text:SetPoint(TitleBarTextDB.Layout[1], DamageMeterFrame.TitleBar, TitleBarTextDB.Layout[2], TitleBarTextDB.Layout[3], TitleBarTextDB.Layout[4])
    Private.E:SetFont(DamageMeterFrame.TitleBar.Text, Private:FetchFont(Private.E.db.general.font), TitleBarTextDB.FontSize, Private.E.db.general.fontStyle)
    DamageMeterFrame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType])
    DamageMeterFrame.TitleBar.Text:SetTextColor(TitleBarTextDB.Colour[1], TitleBarTextDB.Colour[2], TitleBarTextDB.Colour[3])

    return DamageMeterFrame
end

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
        if DB.Enable then
            local Frame = _G["DamageMeter_0"..i]
            if Frame then
                UpdateWindow(Frame, DB)
            end
        end
    end
end
