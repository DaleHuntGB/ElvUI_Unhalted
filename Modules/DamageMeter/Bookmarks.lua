local Private = select(2, ...)

function Private:CreateBookmarks(Frame)
    local DamageMeterFrame = Frame.DamageMeterFrame or Frame
    if not DamageMeterFrame.DamageMeterDB then DamageMeterFrame = Frame:GetParent() end
    local DB = DamageMeterFrame.DamageMeterDB

    if DamageMeterFrame.ShowingBookmarks then
        DamageMeterFrame:HideBookmarks()
        return
    end

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
                DamageMeterFrame:HideBookmarks()
            end
        end

        local function Bookmark_OnMouseWheel(_, Delta)
            DamageMeterFrame:ScrollRows(Delta)
        end

        local function Bookmarks_Refresh(Window)
            local MeterTypes = {}
            for MeterType in pairs(Private.MeterTypes) do
                MeterTypes[#MeterTypes + 1] = MeterType
            end
            table.sort(MeterTypes)

            for _, Row in ipairs(Window.Rows) do
                Row.Highlight:Hide()
                Row:Hide()
            end
            if Window.Drilldown then Window.Drilldown:Hide() end

            local Height = DB.Size[2] - 2
            local RowHeight = Height / DB.Rows
            Window.ScrollRange = math.max(0, #MeterTypes * RowHeight - Height)
            Window.ScrollChild:SetSize(DB.Size[1] - 2, Height + Window.ScrollRange)
            Window.TitleBar.Text:SetText("Bookmarks")

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
