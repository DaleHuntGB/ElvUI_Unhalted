local Private = select(2, ...)

local function FetchLocation()
    local DB = Private.DB.global.MinimapStats.Location
    local ReactionColour = CreateColor(Private:FetchReactionColour().r, Private:FetchReactionColour().g, Private:FetchReactionColour().b, 1):GenerateHexColor()
    if DB.ShowSubZone then
        return string.format("|c%s%s|r", ReactionColour, GetSubZoneText() ~= "" and GetSubZoneText() or GetZoneText())
    else
        return string.format("|c%s%s|r", ReactionColour, GetZoneText())
    end
end

function Private:SetupLocation()
    local DB = Private.DB.global.MinimapStats.Location

    Private.LocationFrame = CreateFrame("Frame", nil, UIParent)
    Private.LocationFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.LocationFrame:SetFrameStrata("MEDIUM")

    Private.LocationFrame.Text = Private.LocationFrame:CreateFontString(nil, "OVERLAY")
    Private.LocationFrame.Text:SetPoint(DB.Layout[1], Private.LocationFrame, DB.Layout[1], 0, 0)
    Private.E:SetFont(Private.LocationFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.LocationFrame.Text:SetText(FetchLocation())
    Private.LocationFrame.Text:SetWordWrap(false)
    Private.LocationFrame.Text:SetNonSpaceWrap(true)
    Private.LocationFrame:SetWidth(Private.LocationFrame.Text:GetUnboundedStringWidth())
    Private.LocationFrame:SetHeight(Private.LocationFrame.Text:GetStringHeight())

    if DB.Enable then
        Private.LocationFrame:RegisterEvent("ZONE_CHANGED")
        Private.LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        Private.LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        Private.LocationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.LocationFrame:SetScript("OnEvent", function(_, _)
            Private.LocationFrame.Text:SetText(FetchLocation())
            Private.LocationFrame:SetWidth(Private.LocationFrame.Text:GetUnboundedStringWidth())
            Private.LocationFrame:SetHeight(Private.LocationFrame.Text:GetStringHeight())
        end)
    end

    Private.LocationFrame:SetShown(DB.Enable)
end

function Private:UpdateLocation()
    local DB = Private.DB.global.MinimapStats.Location

    Private.E:SetFont(Private.LocationFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.LocationFrame.Text:SetText(FetchLocation())
    Private.LocationFrame.Text:SetWordWrap(false)
    Private.LocationFrame.Text:SetNonSpaceWrap(true)

    if DB.Enable then
        Private.LocationFrame:RegisterEvent("ZONE_CHANGED")
        Private.LocationFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        Private.LocationFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        Private.LocationFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.LocationFrame:SetScript("OnEvent", function(_, _)
            Private.LocationFrame.Text:SetText(FetchLocation())
            Private.LocationFrame:SetWidth(Private.LocationFrame.Text:GetUnboundedStringWidth())
            Private.LocationFrame:SetHeight(Private.LocationFrame.Text:GetStringHeight())
        end)
    else
        Private.LocationFrame:UnregisterEvent("ZONE_CHANGED")
        Private.LocationFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
        Private.LocationFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        Private.LocationFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Private.LocationFrame:SetScript("OnEvent", nil)
    end

    Private.LocationFrame:ClearAllPoints()
    Private.LocationFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.LocationFrame.Text:ClearAllPoints()
    Private.LocationFrame.Text:SetPoint(DB.Layout[1], Private.LocationFrame, DB.Layout[1], 0, 0)
    Private.LocationFrame:SetWidth(Private.LocationFrame.Text:GetUnboundedStringWidth())
    Private.LocationFrame:SetHeight(Private.LocationFrame.Text:GetStringHeight())
    Private.LocationFrame:SetShown(DB.Enable)
end
