local Private = select(2, ...)

function Private:ShowCombatSessions(Frame)
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
                    Private:CreateBookmarks(DamageMeterFrame)
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
