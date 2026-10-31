local Private = select(2, ...)
local LIGHTEN_FACTOR = 2

function Private:CreateWindow(DamageMeterDB, DamageMeterCount)
    local DB = DamageMeterDB
    local TitleBarDB = DB.TitleBar
    local TitleBarTextDB = TitleBarDB.Text

    local function Window_OnMouseDown(Frame, Button)
        if Button == "RightButton" then Private:CreateBookmarks(Frame) end
    end

    local function Window_OnMouseWheel(Frame, Delta)
        local CurrentOffset = Frame.ScrollFrame:GetVerticalScroll()
        local RowHeight = (DB.Size[2] - 2) / DB.Rows
        local Offset = math.max(0, math.min(Frame.ScrollRange, CurrentOffset - Delta * RowHeight))
        if Offset == CurrentOffset then return end
        if Frame.Drilldown then Frame.Drilldown:Hide() end
        Frame.ScrollFrame:SetVerticalScroll(Offset)
    end

    local function Window_RefreshData(Frame, ResetScroll)
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

        local CombatSession;

        if C_DamageMeter.IsDamageMeterAvailable() then
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
                if SessionFound then
                    CombatSession = C_DamageMeter.GetCombatSessionFromID(Frame.SessionID, DB.MeterType)
                else
                    Frame.SessionID = nil
                    Frame.SessionName = nil
                    ResetScroll = true
                end
            end
            if not Frame.SessionID then
                CombatSession = C_DamageMeter.GetCombatSessionFromType(DB.SessionType, DB.MeterType)
            end
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

        local SessionName = Frame.SessionID and Frame.SessionName or (DB.SessionType == Enum.DamageMeterSessionType.Current and "" or "Overall")
        Frame.TitleBar.Text:SetText(Private.MeterTypes[DB.MeterType] .. (SessionName ~= "" and " - " .. SessionName or ""))

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
            local SelectedSessionID = not Frame.ShowingCombatSessions and Frame.SessionID
            if MeterType == DB.MeterType and (SelectedSessionID == SessionID or (not SelectedSessionID and SessionID == 0)) then
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

    local function TitleBar_OnEnter(TitleBar)
        TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r * LIGHTEN_FACTOR, Private.E.BackgroundFadeColour.g * LIGHTEN_FACTOR, Private.E.BackgroundFadeColour.b * LIGHTEN_FACTOR, Private.E.BackgroundFadeColour.a)
        GameTooltip:SetOwner(TitleBar, "ANCHOR_NONE")
        GameTooltip:SetPoint("BOTTOMRIGHT", TitleBar, "TOPRIGHT", 0, 1)
        GameTooltip:AddDoubleLine("|cFFFFCC00Left Click|r", "Swap Sessions - Current or Overall", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("|cFFFFCC00Right Click|r", "Combat Sessions", 1, 1, 1, 1, 1, 1)
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
            -- Implement
        elseif not IsShiftKeyDown() and Button == "RightButton" then
            local Window = TitleBar:GetParent()
            Private:ShowCombatSessions(Window)
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

    if DB.ShowBackdrop then
        DamageMeterFrame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        DamageMeterFrame:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
        DamageMeterFrame:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    else
        DamageMeterFrame:SetBackdrop(nil)
    end

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

    DamageMeterFrame:RefreshData()

    return DamageMeterFrame
end
