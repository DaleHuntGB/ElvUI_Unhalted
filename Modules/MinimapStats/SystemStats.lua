local Private = select(2, ...)

local function FetchStats()
    local DB = Private.DB.global.MinimapStats.SystemStats
    local Seperator = DB.Seperator
    local AccentColour = Private.E.AccentColour
    if DB.Format == "FPS_MS" then
        local FPS, MS = math.floor(GetFramerate()), select(3, GetNetStats())
        return string.format("%d|c%sFPS|r %s %d|c%sMS|r", FPS, AccentColour, Seperator, MS, AccentColour)
    elseif DB.Format == "MS" then
        local MS = select(3, GetNetStats())
        return string.format("%d|c%sMS|r", MS, AccentColour)
    elseif DB.Format == "FPS" then
        local FPS = math.floor(GetFramerate())
        return string.format("%d|c%sFPS|r", FPS, AccentColour)
    end
end

function Private:SetupSystemStats()
    local DB = Private.DB.global.MinimapStats.SystemStats

    Private.SystemStatsFrame = CreateFrame("Frame", nil, UIParent)
    Private.SystemStatsFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.SystemStatsFrame:SetFrameStrata("MEDIUM")

    Private.SystemStatsFrame.TimeSinceLastUpdate = 0

    Private.SystemStatsFrame.Text = Private.SystemStatsFrame:CreateFontString(nil, "OVERLAY")
    Private.SystemStatsFrame.Text:SetPoint(DB.Layout[1], Private.SystemStatsFrame, DB.Layout[1], 0, 0)
    Private.E:SetFont(Private.SystemStatsFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.SystemStatsFrame.Text:SetText(FetchStats())
    Private.SystemStatsFrame.Text:SetTextColor(DB.Colour[1], DB.Colour[2], DB.Colour[3])
    Private.SystemStatsFrame.Text:SetWordWrap(false)
    Private.SystemStatsFrame.Text:SetNonSpaceWrap(true)
    Private.SystemStatsFrame:SetWidth(Private.SystemStatsFrame.Text:GetUnboundedStringWidth())
    Private.SystemStatsFrame:SetHeight(Private.SystemStatsFrame.Text:GetStringHeight())

    if DB.Enable then
        Private.SystemStatsFrame:SetScript("OnUpdate", function(_, timeElapsed)
            Private.SystemStatsFrame.TimeSinceLastUpdate = (Private.SystemStatsFrame.TimeSinceLastUpdate or 0) + timeElapsed
            if Private.SystemStatsFrame.TimeSinceLastUpdate >= DB.UpdateInterval then
                Private.SystemStatsFrame.Text:SetText(FetchStats())
                Private.SystemStatsFrame:SetWidth(Private.SystemStatsFrame.Text:GetUnboundedStringWidth())
                Private.SystemStatsFrame:SetHeight(Private.SystemStatsFrame.Text:GetStringHeight())
                Private.SystemStatsFrame.TimeSinceLastUpdate = 0
            end
        end)
    end

    Private.SystemStatsFrame:SetShown(DB.Enable)
end

function Private:UpdateSystemStats()
    local DB = Private.DB.global.MinimapStats.SystemStats

    Private.E:SetFont(Private.SystemStatsFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.SystemStatsFrame.Text:SetText(FetchStats())
    Private.SystemStatsFrame.Text:SetWordWrap(false)
    Private.SystemStatsFrame.Text:SetNonSpaceWrap(true)
    Private.SystemStatsFrame.Text:SetTextColor(DB.Colour[1], DB.Colour[2], DB.Colour[3])

    if DB.Enable then
        Private.SystemStatsFrame:SetScript("OnUpdate", function(_, timeElapsed)
            Private.SystemStatsFrame.TimeSinceLastUpdate = (Private.SystemStatsFrame.TimeSinceLastUpdate or 0) + timeElapsed
            if Private.SystemStatsFrame.TimeSinceLastUpdate >= DB.UpdateInterval then
                Private.SystemStatsFrame.Text:SetText(FetchStats())
                Private.SystemStatsFrame:SetWidth(Private.SystemStatsFrame.Text:GetUnboundedStringWidth())
                Private.SystemStatsFrame:SetHeight(Private.SystemStatsFrame.Text:GetStringHeight())
                Private.SystemStatsFrame.TimeSinceLastUpdate = 0
            end
        end)
    else
        Private.SystemStatsFrame:SetScript("OnUpdate", nil)
    end

    Private.SystemStatsFrame:ClearAllPoints()
    Private.SystemStatsFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.SystemStatsFrame.Text:ClearAllPoints()
    Private.SystemStatsFrame.Text:SetPoint(DB.Layout[1], Private.SystemStatsFrame, DB.Layout[1], 0, 0)
    Private.SystemStatsFrame:SetWidth(Private.SystemStatsFrame.Text:GetUnboundedStringWidth())
    Private.SystemStatsFrame:SetHeight(Private.SystemStatsFrame.Text:GetStringHeight())
    Private.SystemStatsFrame:SetShown(DB.Enable)
end
