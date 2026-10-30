local Private = select(2, ...)

local function FetchTime()
    local DB = Private.DB.global.MinimapStats.Time
    if DB.Format == "24H" then
        return date("%H:%M")
    else
        return date("%I:%M%p")
    end
end

function Private:SetupTime()
    local DB = Private.DB.global.MinimapStats.Time

    Private.TimeFrame = CreateFrame("Frame", nil, UIParent)
    Private.TimeFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.TimeFrame:SetFrameStrata("MEDIUM")

    Private.TimeFrame.TimeSinceLastUpdate = 0

    Private.TimeFrame.Text = Private.TimeFrame:CreateFontString(nil, "OVERLAY")
    Private.TimeFrame.Text:SetPoint(DB.Layout[1], Private.TimeFrame, DB.Layout[1], 0, 0)
    Private.E:SetFont(Private.TimeFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.TimeFrame.Text:SetText(FetchTime())
    Private.TimeFrame.Text:SetTextColor(DB.Colour[1], DB.Colour[2], DB.Colour[3])
    Private.TimeFrame.Text:SetWordWrap(false)
    Private.TimeFrame.Text:SetNonSpaceWrap(true)
    Private.TimeFrame:SetWidth(Private.TimeFrame.Text:GetUnboundedStringWidth())
    Private.TimeFrame:SetHeight(Private.TimeFrame.Text:GetStringHeight())

    if DB.Enable then
        Private.TimeFrame:SetScript("OnUpdate", function(_, timeElapsed)
            Private.TimeFrame.TimeSinceLastUpdate = (Private.TimeFrame.TimeSinceLastUpdate or 0) + timeElapsed
            if Private.TimeFrame.TimeSinceLastUpdate >= DB.UpdateInterval then
                Private.TimeFrame.Text:SetText(FetchTime())
                Private.TimeFrame:SetWidth(Private.TimeFrame.Text:GetUnboundedStringWidth())
                Private.TimeFrame:SetHeight(Private.TimeFrame.Text:GetStringHeight())
                Private.TimeFrame.TimeSinceLastUpdate = 0
            end
        end)
    end

    Private.TimeFrame:SetShown(DB.Enable)
end

function Private:UpdateTime()
    local DB = Private.DB.global.MinimapStats.Time

    Private.E:SetFont(Private.TimeFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.TimeFrame.Text:SetText(FetchTime())
    Private.TimeFrame.Text:SetTextColor(DB.Colour[1], DB.Colour[2], DB.Colour[3])
    Private.TimeFrame.Text:SetWordWrap(false)
    Private.TimeFrame.Text:SetNonSpaceWrap(true)

    if DB.Enable then
        Private.TimeFrame:SetScript("OnUpdate", function(_, timeElapsed)
            Private.TimeFrame.TimeSinceLastUpdate = (Private.TimeFrame.TimeSinceLastUpdate or 0) + timeElapsed
            if Private.TimeFrame.TimeSinceLastUpdate >= DB.UpdateInterval then
                Private.TimeFrame.Text:SetText(FetchTime())
                Private.TimeFrame:SetWidth(Private.TimeFrame.Text:GetUnboundedStringWidth())
                Private.TimeFrame:SetHeight(Private.TimeFrame.Text:GetStringHeight())
                Private.TimeFrame.TimeSinceLastUpdate = 0
            end
        end)
    else
        Private.TimeFrame:SetScript("OnUpdate", nil)
    end

    Private.TimeFrame:ClearAllPoints()
    Private.TimeFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.TimeFrame.Text:ClearAllPoints()
    Private.TimeFrame.Text:SetPoint(DB.Layout[1], Private.TimeFrame, DB.Layout[1], 0, 0)
    Private.TimeFrame:SetWidth(Private.TimeFrame.Text:GetUnboundedStringWidth())
    Private.TimeFrame:SetHeight(Private.TimeFrame.Text:GetStringHeight())
    Private.TimeFrame:SetShown(DB.Enable)
end
