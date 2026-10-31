local Private = select(2, ...)
local LIGHTEN_FACTOR = 2

function Private:CreateWindow(DamageMeterDB, DamageMeterCount)
    local DB = DamageMeterDB
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text

    local function Window_OnMouseWheel(Frame, Delta)
        local CurrentOffset = Frame.ScrollFrame:GetVerticalScroll()
        local RowHeight = (DB.Size[2] - 2) / DB.Rows
        local Offset = math.max(0, math.min(Frame.ScrollRange, CurrentOffset - Delta * RowHeight))
        if Offset == CurrentOffset then return end
        if Frame.Drilldown then Frame.Drilldown:Hide() end
        Frame.ScrollFrame:SetVerticalScroll(Offset)
    end

    local function Window_RefreshData(Frame, ResetScroll)
        local CombatSession;
        if C_DamageMeter.IsDamageMeterAvailable() then
            CombatSession = C_DamageMeter.GetCombatSessionFromType(DB.SessionType, DB.MeterType)
        end

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

        for i = 1, SourceCount do
            local Row = Frame.Rows[i]
            if not Row then
                Row = Private:CreateRow(Frame, i, DB)
                Frame.Rows[i] = Row
            end
            Row:Update(CombatSources[i], CombatSession.maxAmount)
        end
        for i = SourceCount + 1, #Frame.Rows do
            Frame.Rows[i]:Clear()
        end
        Frame:ScrollRows(0)
    end

    local function Window_OnEvent(Frame, Event, MeterType, SessionID)
        if Event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
            if MeterType == DB.MeterType and SessionID == 0 then
                Frame:RefreshData()
            end
        elseif Event == "DAMAGE_METER_CURRENT_SESSION_UPDATED" then
            if DB.SessionType == Enum.DamageMeterSessionType.Current then
                Frame:RefreshData(true)
            end
        elseif Event == "DAMAGE_METER_RESET" then
            Frame:RefreshData(true)
        elseif Event == "PLAYER_REGEN_ENABLED" then
            Frame:RefreshData()
        end
    end

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

    Frame.ScrollRange = 0
    Frame.ScrollRows = Window_OnMouseWheel
    Frame:EnableMouseWheel(true)
    Frame:SetScript("OnMouseWheel", Window_OnMouseWheel)

    Frame.ScrollFrame = CreateFrame("ScrollFrame", nil, Frame)
    Frame.ScrollFrame:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
    Frame.ScrollFrame:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
    Frame.ScrollFrame:EnableMouseWheel(true)
    Frame.ScrollFrame:SetScript("OnMouseWheel", function(_, Delta) Frame:ScrollRows(Delta) end)
    Frame.ScrollChild = CreateFrame("Frame", nil, Frame.ScrollFrame)
    Frame.ScrollChild:SetSize(DB.Size[1] - 2, DB.Size[2] - 2)
    Frame.ScrollFrame:SetScrollChild(Frame.ScrollChild)

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

    Frame.Rows = {}

    for i = 1, DB.Rows do
        Frame.Rows[i] = Private:CreateRow(Frame, i, DB)
    end

    Frame.RefreshData = Window_RefreshData
    Frame:SetScript("OnEvent", Window_OnEvent)
    Frame:SetScript("OnShow", Window_RefreshData)
    Frame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    Frame:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
    Frame:RegisterEvent("DAMAGE_METER_RESET")
    Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    Frame:RefreshData()

    return Frame
end

function Private:UpdateWindow(DamageMeterFrame, DamageMeterDB)
    local DB = DamageMeterDB
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text

    DamageMeterFrame:ClearAllPoints()
    DamageMeterFrame:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    DamageMeterFrame:SetSize(DB.Size[1], DB.Size[2])

    local RowHeight = (DB.Size[2] - 2) / DB.Rows
    for i = 1, math.max(DB.Rows, #DamageMeterFrame.Rows) do
        local Row = DamageMeterFrame.Rows[i]
        if not Row then
            Row = Private:CreateRow(DamageMeterFrame, i, DB)
            DamageMeterFrame.Rows[i] = Row
        end
        Row:ClearAllPoints()
        Row:SetPoint("TOPLEFT", DamageMeterFrame.ScrollChild, "TOPLEFT", 0, -((i - 1) * RowHeight))
        Row:SetPoint("TOPRIGHT", DamageMeterFrame.ScrollChild, "TOPRIGHT", 0, -((i - 1) * RowHeight))
        Row:SetHeight(RowHeight)
        Row:Show()
    end

    DamageMeterFrame.TitleBar:ClearAllPoints()
    DamageMeterFrame.TitleBar:SetPoint("BOTTOMLEFT", DamageMeterFrame, "TOPLEFT", TitleBarDB.XOffset, TitleBarDB.YOffset)
    DamageMeterFrame.TitleBar:SetSize(DB.Size[1], TitleBarDB.Height)

    DamageMeterFrame.TitleBar.Text:ClearAllPoints()
    DamageMeterFrame.TitleBar.Text:SetPoint(TitleBarTextDB.Layout[1], DamageMeterFrame.TitleBar, TitleBarTextDB.Layout[2], TitleBarTextDB.Layout[3], TitleBarTextDB.Layout[4])
    Private.E:SetFont(DamageMeterFrame.TitleBar.Text, Private:FetchFont(Private.E.db.general.font), TitleBarTextDB.FontSize, Private.E.db.general.fontStyle)
    DamageMeterFrame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType])
    DamageMeterFrame.TitleBar.Text:SetTextColor(TitleBarTextDB.Colour[1], TitleBarTextDB.Colour[2], TitleBarTextDB.Colour[3])

    DamageMeterFrame:RefreshData()

    return DamageMeterFrame
end
