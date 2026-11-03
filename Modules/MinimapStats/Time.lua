local Private = select(2, ...)

local function FetchTime()
    local DB = Private.DB.global.MinimapStats.Time
    if DB.Format == "24H" then
        return date("%H:%M")
    else
        return date("%I:%M%p")
    end
end

local function Time_OnEnter()
    local AccentColour = Private.E.AccentColour
    local RaidLockouts = {}
    local DungeonLockouts = {}

    GameTooltip:SetOwner(_G["Minimap"], "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 1, -2)

    RequestRaidInfo()

    for i = 1, GetNumSavedInstances() do
        local Name, _, Reset, _, IsLocked, _, _, IsRaid, _, DifficultyName, MaxEncounters, CurrentProgress, _, _ = GetSavedInstanceInfo(i)
        local Days = math.floor(Reset / 86400)
        local Hours = math.floor((Reset % 86400) / 3600)
        local Mins = math.floor((Reset % 3600) / 60)
        local ResetFormatted = Days > 0 and string.format("%dd %dh %dm", Days, Hours, Mins) or string.format("%dh %dm", Hours, Mins)
        local LockoutString = string.format("%s: %d/%d %s [|c%s%s|r]", Name, CurrentProgress, MaxEncounters, DifficultyName, AccentColour, ResetFormatted)
        if IsLocked then
            if IsRaid then
                table.insert(RaidLockouts, LockoutString)
            else
                table.insert(DungeonLockouts, LockoutString)
            end
        end
    end
    if (#DungeonLockouts > 0 or #RaidLockouts > 0) then GameTooltip:AddLine(" ", 1, 1, 1) end
    if #DungeonLockouts > 0 then
        GameTooltip:AddLine("|c" .. AccentColour .. "Dungeon|r |cFFFFFFFFLockouts|r", 1, 1, 1)
        for _, Lockout in pairs(DungeonLockouts) do
            local DungeonTitle, DungeonLockout, DungeonReset = Lockout:match("([^:]+): (.+) %[(.+)%]")
            local DungeonLockout = DungeonLockout:gsub("Normal", "N"):gsub("Heroic", "H"):gsub("Mythic", "M")
            local DungeonDisplayString = "|c" .. AccentColour .. DungeonTitle .. "|r: " .. DungeonLockout
            GameTooltip:AddDoubleLine(DungeonDisplayString, DungeonReset, 1, 1, 1, 1, 1, 1)
        end
    end
    if #RaidLockouts > 0 then
        if #DungeonLockouts > 0 then
            GameTooltip:AddLine(" ", 1, 1, 1)
        end
        GameTooltip:AddLine("|c" .. AccentColour .. "Raid|r |cFFFFFFFFLockouts|r", 1, 1, 1)
        for _, Lockout in pairs(RaidLockouts) do
            local RaidTitle, RaidLockout, RaidReset = Lockout:match("([^:]+): (.+) %[(.+)%]")
            local RaidLockout = RaidLockout:gsub("Normal", "|c" .. AccentColour .. "N|r"):gsub("Heroic", "|c" .. AccentColour .. "H|r"):gsub("Mythic", "|c" .. AccentColour .. "M|r"):gsub("Looking For Raid", "|c" .. AccentColour .. "LFR|r"):gsub("25 Player", "|c" .. AccentColour .. "25M|r"):gsub("10 Player", "|c" .. AccentColour .. "10M|r")
            local RaidDisplayString = "|c" .. AccentColour .. RaidTitle .. "|r: " .. RaidLockout
            GameTooltip:AddDoubleLine(RaidDisplayString, RaidReset, 1, 1, 1, 1, 1, 1)
        end
    end

    GameTooltip:Show()
end

local function Time_OnLeave()
    GameTooltip:Hide()
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
        Private.TimeFrame:SetScript("OnEnter", Time_OnEnter)
        Private.TimeFrame:SetScript("OnLeave", Time_OnLeave)
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
        Private.TimeFrame:SetScript("OnEnter", Time_OnEnter)
        Private.TimeFrame:SetScript("OnLeave", Time_OnLeave)
    else
        Private.TimeFrame:SetScript("OnUpdate", nil)
        Private.TimeFrame:SetScript("OnEnter", nil)
        Private.TimeFrame:SetScript("OnLeave", nil)
    end

    Private.TimeFrame:ClearAllPoints()
    Private.TimeFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.TimeFrame.Text:ClearAllPoints()
    Private.TimeFrame.Text:SetPoint(DB.Layout[1], Private.TimeFrame, DB.Layout[1], 0, 0)
    Private.TimeFrame:SetWidth(Private.TimeFrame.Text:GetUnboundedStringWidth())
    Private.TimeFrame:SetHeight(Private.TimeFrame.Text:GetStringHeight())
    Private.TimeFrame:SetShown(DB.Enable)
end
