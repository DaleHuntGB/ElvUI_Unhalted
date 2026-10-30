local Private = select(2, ...)

local GarrisonInstanceIDs = {
    [1152] = true,
    [1153] = true,
    [1154] = true,
    [1158] = true,
    [1159] = true,
    [1160] = true,
}

local function HideInstanceDifficulty()
    local InstanceDifficultyIndicator = MinimapCluster.InstanceDifficulty
    local InstanceIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Instance or _G["MiniMapInstanceDifficulty"]
    local GuildIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.Guild or _G["GuildInstanceDifficulty"]
    local ChallengeIndicator = InstanceDifficultyIndicator and InstanceDifficultyIndicator.ChallengeMode or _G["MiniMapChallengeMode"]
    if InstanceDifficultyIndicator then InstanceDifficultyIndicator:SetAlpha(0) end
    if InstanceIndicator then InstanceIndicator:SetAlpha(0) end
    if GuildIndicator then GuildIndicator:SetAlpha(0) end
    if ChallengeIndicator then ChallengeIndicator:SetAlpha(0) end
end

local function FetchDelveTierDifficulty(WidgetID)
    if not WidgetID then return "" end
    local WidgetInfo = C_UIWidgetManager.GetScenarioHeaderDelvesWidgetVisualizationInfo(WidgetID)

    if WidgetInfo and WidgetInfo.tierText then return string.format("%s", WidgetInfo.tierText) end

    return ""
end

local function FetchInstanceDifficulty()
    local AccentColour = Private.E.AccentColour
    local _, _, DiffID, _, MaxPlayers, _, _, InstanceID, CurrentPlayers = GetInstanceInfo()
    local KeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo()
    local PlayerInGarrison = GarrisonInstanceIDs[InstanceID]
    local InstanceDifficulty = ""

    if DiffID == 0 or PlayerInGarrison then
        InstanceDifficulty = ""
    elseif DiffID == 1 or DiffID == 3 or DiffID == 4 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "N" .. "|r"
    elseif DiffID == 2 or DiffID == 5 or DiffID == 6 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "H" .. "|r"
    elseif DiffID == 16 or DiffID == 23 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "M" .. "|r"
    elseif DiffID == 8 then
        InstanceDifficulty = "|c" .. AccentColour .. "M" .. "|r" .. KeystoneLevel
    elseif DiffID == 9 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "N" .. "|r"
    elseif DiffID == 7 or DiffID == 17 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "LFR" .. "|r"
    elseif DiffID == 14 then
        InstanceDifficulty = CurrentPlayers .. "|c" .. AccentColour .. "N" .. "|r"
    elseif DiffID == 15 then
        InstanceDifficulty = CurrentPlayers .. "|c" .. AccentColour .. "H" .. "|r"
    elseif DiffID == 18 or DiffID == 19 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "EVT" .. "|r"
    elseif DiffID == 24 or DiffID == 33 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "TW" .. "|r"
    elseif DiffID == 11 or DiffID == 39 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "S+" .. "|r"
    elseif DiffID == 12 or DiffID == 38 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "S" .. "|r"
    elseif DiffID == 205 then
        InstanceDifficulty = MaxPlayers .. "|c" .. AccentColour .. "F" .. "|r"
    elseif DiffID == 208 then
        InstanceDifficulty = "|c" .. AccentColour .. "T" .. "|r" .. FetchDelveTierDifficulty(6183)
    elseif DiffID == 233 then
        InstanceDifficulty = CurrentPlayers .. "|c" .. AccentColour .. "M" .. "|r"
    end

    return InstanceDifficulty
end

function Private:SetupInstanceDifficulty()
    local DB = Private.DB.global.MinimapStats.InstanceDifficulty

    Private.InstanceDifficultyFrame = CreateFrame("Frame", nil, UIParent)
    Private.InstanceDifficultyFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.InstanceDifficultyFrame:SetFrameStrata("MEDIUM")

    Private.InstanceDifficultyFrame.Text = Private.InstanceDifficultyFrame:CreateFontString(nil, "OVERLAY")
    Private.InstanceDifficultyFrame.Text:SetPoint(DB.Layout[1], Private.InstanceDifficultyFrame, DB.Layout[1], 0, 0)
    Private.E:SetFont(Private.InstanceDifficultyFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.InstanceDifficultyFrame.Text:SetText(FetchInstanceDifficulty())
    Private.InstanceDifficultyFrame.Text:SetWordWrap(false)
    Private.InstanceDifficultyFrame.Text:SetNonSpaceWrap(true)
    Private.InstanceDifficultyFrame:SetWidth(Private.InstanceDifficultyFrame.Text:GetUnboundedStringWidth())
    Private.InstanceDifficultyFrame:SetHeight(Private.InstanceDifficultyFrame.Text:GetStringHeight())

    if DB.Enable then
        Private.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
        Private.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        Private.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        Private.InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Private.InstanceDifficultyFrame:SetScript("OnEvent", function(_, _)
            Private.InstanceDifficultyFrame.Text:SetText(FetchInstanceDifficulty())
            Private.InstanceDifficultyFrame:SetWidth(Private.InstanceDifficultyFrame.Text:GetUnboundedStringWidth())
            Private.InstanceDifficultyFrame:SetHeight(Private.InstanceDifficultyFrame.Text:GetStringHeight())
        end)
        HideInstanceDifficulty()
    end

    Private.InstanceDifficultyFrame:SetShown(DB.Enable)
end

function Private:UpdateInstanceDifficulty()
    local DB = Private.DB.global.MinimapStats.InstanceDifficulty

    Private.E:SetFont(Private.InstanceDifficultyFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.FontSize, Private.E.db.general.fontStyle)
    Private.InstanceDifficultyFrame.Text:SetText(FetchInstanceDifficulty())
    Private.InstanceDifficultyFrame.Text:SetWordWrap(false)
    Private.InstanceDifficultyFrame.Text:SetNonSpaceWrap(true)

    if DB.Enable then
        Private.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED")
        Private.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
        Private.InstanceDifficultyFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        Private.InstanceDifficultyFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.InstanceDifficultyFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Private.InstanceDifficultyFrame:SetScript("OnEvent", function(_, _)
            Private.InstanceDifficultyFrame.Text:SetText(FetchInstanceDifficulty())
            Private.InstanceDifficultyFrame:SetWidth(Private.InstanceDifficultyFrame.Text:GetUnboundedStringWidth())
            Private.InstanceDifficultyFrame:SetHeight(Private.InstanceDifficultyFrame.Text:GetStringHeight())
        end)
    else
        Private.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED")
        Private.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_INDOORS")
        Private.InstanceDifficultyFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        Private.InstanceDifficultyFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Private.InstanceDifficultyFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        Private.InstanceDifficultyFrame:SetScript("OnEvent", nil)
    end

    Private.InstanceDifficultyFrame:ClearAllPoints()
    Private.InstanceDifficultyFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.InstanceDifficultyFrame.Text:ClearAllPoints()
    Private.InstanceDifficultyFrame.Text:SetPoint(DB.Layout[1], Private.InstanceDifficultyFrame, DB.Layout[1], 0, 0)
    Private.InstanceDifficultyFrame:SetWidth(Private.InstanceDifficultyFrame.Text:GetUnboundedStringWidth())
    Private.InstanceDifficultyFrame:SetHeight(Private.InstanceDifficultyFrame.Text:GetStringHeight())
    Private.InstanceDifficultyFrame:SetShown(DB.Enable)
end
