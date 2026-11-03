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

local function SystemStats_OnEnter()
    if Private.isForever then return end

    local AccentColour = Private.E.AccentColour
    local RaidsCompleted = {}
    local MythicPlusRunsCompleted = {}
    local WorldRunsCompleted = {}

    GameTooltip:SetOwner(_G["Minimap"], "ANCHOR_NONE")
    GameTooltip:SetPoint("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 1, -2)

    if not C_AddOns.IsAddOnLoaded("Blizzard_WeeklyRewards") then C_AddOns.LoadAddOn("Blizzard_WeeklyRewards") end

    local function FetchRaidData()
        if WeeklyRewardsUtil.HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Raid) then
            local RaidRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Raid)
            for i = 1, 3 do
                local DifficultyName = Private.RaidDifficultyIDs[RaidRuns[i].level]
                if DifficultyName == nil then break end
                table.insert(RaidsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "%s|r [%s]", i, DifficultyName, Private.GVaultLevels["Raids"][RaidRuns[i].level]))
            end

            if #RaidsCompleted > 0 then
                GameTooltip:AddLine("|c" .. AccentColour .. "Raid|r |cFFFFFFFFGreat Vault|r", 1, 1, 1)
                for _, Raid in pairs(RaidsCompleted) do
                    GameTooltip:AddLine(Raid, 1, 1, 1)
                end
            end
        end
    end

    local function FetchMythicPlusData()
        if WeeklyRewardsUtil.HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.Activities) then
            local MythicPlusRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.Activities)
            for i = 1, 3 do
                if MythicPlusRuns[i].activityTierID == 0 then break end
                local KeyLevel = MythicPlusRuns[i].level
                if KeyLevel > 10 then KeyLevel = 10 end
                table.insert(MythicPlusRunsCompleted, string.format("Slot #%d: |c" .. AccentColour .. "+%d|r [%s]", i, MythicPlusRuns[i].level, Private.GVaultLevels["Mythic+"][KeyLevel]))
            end

            if #MythicPlusRunsCompleted > 0 then
                if #RaidsCompleted > 0 then
                    GameTooltip:AddLine(" ", 1, 1, 1)
                end
                GameTooltip:AddLine("|c" .. AccentColour .. "Mythic+|r |cFFFFFFFFGreat Vault|r", 1, 1, 1)
                for _, Key in pairs(MythicPlusRunsCompleted) do
                    GameTooltip:AddLine(Key, 1, 1, 1)
                end
            end
        end
    end

    local function FetchWorldData()
        if WeeklyRewardsUtil.HasUnlockedRewards(Enum.WeeklyRewardChestThresholdType.World) then
            local WorldRuns = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.World)
            for i = 1, 3 do
                local WorldLevel = WorldRuns[i].level
                if WorldLevel == nil or WorldLevel == 0 then break end
                if WorldLevel > 13 then WorldLevel = 13 end
                table.insert(WorldRunsCompleted, string.format("Slot #%d: Tier |c" .. AccentColour .. "%d|r [%s]", i, WorldRuns[i].level, Private.GVaultLevels["World"][WorldLevel]))
            end

            if #WorldRunsCompleted > 0 then
                if #RaidsCompleted > 0 or #MythicPlusRunsCompleted > 0 then GameTooltip:AddLine(" ", 1, 1, 1) end
                GameTooltip:AddLine("|c" .. AccentColour .. "World|r |cFFFFFFFFGreat Vault|r", 1, 1, 1)
                for _, Delve in pairs(WorldRunsCompleted) do
                    GameTooltip:AddLine(Delve, 1, 1, 1)
                end
            end
        end
    end

    FetchRaidData()
    FetchMythicPlusData()
    FetchWorldData()

    GameTooltip:Show()
end

local function SystemStats_OnLeave()
    if Private.isForever then return end
    GameTooltip:Hide()
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
        Private.SystemStatsFrame:SetScript("OnEnter", SystemStats_OnEnter)
        Private.SystemStatsFrame:SetScript("OnLeave", SystemStats_OnLeave)
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
        Private.SystemStatsFrame:SetScript("OnEnter", SystemStats_OnEnter)
        Private.SystemStatsFrame:SetScript("OnLeave", SystemStats_OnLeave)
    else
        Private.SystemStatsFrame:SetScript("OnUpdate", nil)
        Private.SystemStatsFrame:SetScript("OnEnter", nil)
        Private.SystemStatsFrame:SetScript("OnLeave", nil)
    end

    Private.SystemStatsFrame:ClearAllPoints()
    Private.SystemStatsFrame:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.SystemStatsFrame.Text:ClearAllPoints()
    Private.SystemStatsFrame.Text:SetPoint(DB.Layout[1], Private.SystemStatsFrame, DB.Layout[1], 0, 0)
    Private.SystemStatsFrame:SetWidth(Private.SystemStatsFrame.Text:GetUnboundedStringWidth())
    Private.SystemStatsFrame:SetHeight(Private.SystemStatsFrame.Text:GetStringHeight())
    Private.SystemStatsFrame:SetShown(DB.Enable)
end
