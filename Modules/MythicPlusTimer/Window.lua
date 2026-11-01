local Private = select(2, ...)

local Preview = {
    Name = "The Rookery", Level = 12, Limit = 1920, Elapsed = 1380, Deaths = 2, TimeLost = 10,
    Objectives = {
        {Name = "Kyrioss", Value = 1, Maximum = 1, Complete = true, CompletionTime = 510},
        {Name = "Stormguard Gorren", Value = 0, Maximum = 1},
        {Name = "Voidstone Monstrosity", Value = 0, Maximum = 1},
        {Name = "Enemy Forces", Value = 72.5, Maximum = 100, Percent = true},
    },
}

function Private:CreateMythicPlusWindow(DB)
    local function Window_GetRow(Frame, Index)
        if not Frame.Rows[Index] then Frame.Rows[Index] = Private:CreateMythicPlusRow(Frame, Index, DB) end
        return Frame.Rows[Index]
    end

    local function Window_StopClock(Frame)
        if Frame.Ticker then Frame.Ticker:Cancel() Frame.Ticker = nil end
    end

    local function Window_ReadCompletion(Frame)
        local Run = Frame.Run
        if not Run or Run.Completed then return end
        local Info = C_ChallengeMode.GetChallengeCompletionInfo()
        if not Info or issecretvalue(Info.mapChallengeModeID) or issecretvalue(Info.time) then return end
        if Info.mapChallengeModeID ~= Run.MapID or Info.time <= 0 then return end
        Run.Completed, Run.Completing = true, nil
        Run.Elapsed = Info.time / 1000
        Run.Deaths, Run.TimeLost = C_ChallengeMode.GetDeathCount()
        if not issecretvalue(Info.level) and Info.level > 0 then Run.Level = Info.level end
        Run.OnTime = not issecretvalue(Info.onTime) and Info.onTime
        Run.Upgrade = not issecretvalue(Info.keystoneUpgradeLevels) and Info.keystoneUpgradeLevels or 0
        Frame:StopClock()
    end

    local function Window_Render(Frame)
        Frame.Preview = not Frame.Run and Private.MythicPlusTimerPreview and Preview or nil
        local Data = Frame.Run or Frame.Preview
        if not Data then
            Frame:StopClock()
            Frame:Hide()
            Private:UpdateMythicPlusTracker(Frame, false)
            return
        end
        if Data.Limit <= 0 then
            Frame:Hide()
            Private:UpdateMythicPlusTracker(Frame, false)
            return
        end
        Frame.TitleBar.Text:SetFormattedText("%s +%d", Data.Name, Data.Level)
        Frame.TitleBar.Deaths_Text:SetFormattedText("|cFFCC4040Deaths|r: %d - %s", Data.Deaths, SecondsToClock(Data.TimeLost))
        Private:RefreshMythicPlusClock(Frame)
        local Index = Private:RenderMythicPlusObjectives(Frame, Data, 2)
        for i = Index, #Frame.Rows do Frame.Rows[i]:Hide() end
        Frame:SetSize(DB.Width, 2 + (Index - 1) * DB.RowHeight)
        Frame:Show()
        Private:UpdateMythicPlusTracker(Frame, Frame.Run ~= nil and Data.Limit > 0)
    end

    local function Window_RefreshData(Frame)
        if not DB.Enable then return end
        local _, InstanceType, Difficulty, _, _, _, _, InstanceID = GetInstanceInfo()
        local MapID = C_ChallengeMode.GetActiveChallengeMapID()
        if issecretvalue(MapID) then MapID = nil end
        local Active = C_ChallengeMode.IsChallengeModeActive()
        if InstanceType ~= "party" or Difficulty ~= 8 or (Frame.Resetting and not Active) then
            Frame.Run = nil
            if Difficulty ~= 8 then Frame.Resetting = nil end
            Frame:Render()
            return
        end
        if MapID and MapID > 0 then
            if not Frame.Run or Frame.Run.MapID ~= MapID or Frame.Run.InstanceID ~= InstanceID then
                Frame:StopClock()
                Frame.Run = {MapID = MapID, InstanceID = InstanceID, Level = 0, Elapsed = 0, Objectives = {}}
            end
            local Run = Frame.Run
            if not Run.Completed then
                local Name, _, Limit = C_ChallengeMode.GetMapUIInfo(MapID)
                local Level, Affixes = C_ChallengeMode.GetActiveKeystoneInfo()
                Run.Name = Name
                if issecretvalue(Level) or Level > 0 then Run.Level = Level end
                Run.Limit = not issecretvalue(Limit) and Limit or 0
                Run.Peril = false
                for _, AffixID in ipairs(Affixes) do
                    if not issecretvalue(AffixID) and AffixID == 152 then Run.Peril = true end
                end
                Run.TimerID = nil
                for _, TimerID in ipairs({GetWorldElapsedTimers()}) do
                    local _, _, TimerType = GetWorldElapsedTime(TimerID)
                    if not issecretvalue(TimerType) and TimerType == Enum.WorldElapsedTimerTypes.ChallengeMode then Run.TimerID = TimerID break end
                end
                Run.Deaths, Run.TimeLost = C_ChallengeMode.GetDeathCount()
                Private:ReadMythicPlusObjectives(Frame)
            end
        elseif Frame.Run and Frame.Run.InstanceID ~= InstanceID then
            Frame.Run = nil
        end
        local Run = Frame.Run
        if Run then
            if Run.Completing or not Active then Frame:ReadCompletion() end
            if Run.Completed then
                for _, Objective in ipairs(Run.Objectives) do
                    Objective.Complete = true
                    Objective.Value = Objective.Maximum
                end
            elseif not Frame.Ticker then
                Frame.Ticker = C_Timer.NewTicker(0.2, function()
                    if not DB.Enable or not Frame.Run then Frame:StopClock() return end
                    if not Frame.Run.TimerID or Frame.Run.Limit <= 0 or Frame.Run.Completing then
                        Frame:RefreshData()
                    else
                        Private:RefreshMythicPlusClock(Frame)
                    end
                end)
            end
        end
        Frame:Render()
    end

    local function Window_OnEvent(Frame, Event, ...)
        if not DB.Enable then return end
        if Event == "ADDON_LOADED" and ... ~= "Blizzard_ObjectiveTracker" then return end
        if Event == "CHALLENGE_MODE_RESET" then
            Frame:StopClock()
            Frame.Run, Frame.Resetting = nil, true
            Frame:Render()
            return
        elseif Event == "CHALLENGE_MODE_START" then
            Frame:StopClock()
            Frame.Run, Frame.Resetting = nil, nil
        elseif Event == "CHALLENGE_MODE_COMPLETED" and Frame.Run then
            Frame.Run.Completing = true
        elseif Event == "ENCOUNTER_END" then
            if not Frame.Run or Frame.Run.Completed then return end
            local EncounterID, Name, _, _, Success = ...
            if not issecretvalue(Success) and Success == 1 then
                Private:RecordMythicPlusBoss(Frame, EncounterID, Name)
            end
        elseif Event == "WORLD_STATE_TIMER_STOP" and Frame.Run and not issecretvalue(...) and not issecretvalue(Frame.Run.TimerID) and ... == Frame.Run.TimerID then
            Frame.Run.TimerID = nil
        elseif (Event == "SCENARIO_UPDATE" or Event == "SCENARIO_CRITERIA_UPDATE" or Event == "SCENARIO_POI_UPDATE") and not Frame.Run then
            return
        end
        Frame:RefreshData()
    end

    local function Window_UpdateEnabled(Frame)
        Frame:UnregisterAllEvents()
        if DB.Enable then
            for _, Event in ipairs({
                "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "PLAYER_DIFFICULTY_CHANGED",
                "CHALLENGE_MODE_START", "CHALLENGE_MODE_RESET", "CHALLENGE_MODE_COMPLETED",
                "CHALLENGE_MODE_DEATH_COUNT_UPDATED", "WORLD_STATE_TIMER_START", "WORLD_STATE_TIMER_STOP",
                "SCENARIO_UPDATE", "SCENARIO_CRITERIA_UPDATE", "SCENARIO_POI_UPDATE", "ENCOUNTER_END", "ADDON_LOADED",
            }) do Frame:RegisterEvent(Event) end
            Frame:RefreshData()
        else
            Frame:StopClock()
            Frame.Run, Frame.Preview = nil, nil
            Frame:Hide()
            Private:UpdateMythicPlusTracker(Frame, false)
        end
    end

    local Frame = CreateFrame("Frame", "ElvUI_Unhalted_MythicPlusTimer", UIParent, "BackdropTemplate")
    Frame:Hide()
    Frame.MythicPlusDB = DB
    Frame.Rows = {}
    Frame.TitleBar = CreateFrame("Frame", nil, Frame, "BackdropTemplate")
    Frame.TitleBar.Text = Frame.TitleBar:CreateFontString(nil, "OVERLAY")
    Frame.TitleBar.Text:SetJustifyH("LEFT")
    Frame.TitleBar.Text:SetWordWrap(false)
    Frame.TitleBar.Deaths_Text = Frame.TitleBar:CreateFontString(nil, "OVERLAY")
    Frame.TitleBar.Deaths_Text:SetJustifyH("RIGHT")
    Frame.TitleBar.Deaths_Text:SetWordWrap(false)
    Frame.GetRow = Window_GetRow
    Frame.StopClock = Window_StopClock
    Frame.ReadCompletion = Window_ReadCompletion
    Frame.Render = Window_Render
    Frame.RefreshData = Window_RefreshData
    Frame.UpdateEnabled = Window_UpdateEnabled
    Frame:SetScript("OnEvent", Window_OnEvent)
    Private:UpdateMythicPlusWindow(Frame, DB)
    return Frame
end

function Private:UpdateMythicPlusWindow(Frame, DB)
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetWidth(DB.Width)
    Frame:SetBackdrop(DB.ShowBackdrop and {bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1} or nil)
    Frame:SetBackdropColor(Private.E.BackgroundColour.r, Private.E.BackgroundColour.g, Private.E.BackgroundColour.b, Private.E.BackgroundColour.a)
    Frame:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    local TitleDB = DB.TitleBar
    Frame.TitleBar:ClearAllPoints()
    Frame.TitleBar:SetPoint("BOTTOMLEFT", Frame, "TOPLEFT", TitleDB.XOffset, TitleDB.YOffset)
    Frame.TitleBar:SetSize(DB.Width, TitleDB.Height)
    Frame.TitleBar:SetBackdrop(TitleDB.ShowBackdrop and {bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1} or nil)
    Frame.TitleBar:SetBackdropColor(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Frame.TitleBar:SetBackdropBorderColor(Private.E.bordercolour.r, Private.E.bordercolour.g, Private.E.bordercolour.b, Private.E.bordercolour.a)
    Frame.TitleBar:SetShown(TitleDB.Enable)
    local TextDB = TitleDB.Text
    Frame.TitleBar.Text:ClearAllPoints()
    Frame.TitleBar.Text:SetPoint(TextDB.Layout[1], Frame.TitleBar, TextDB.Layout[2], TextDB.Layout[3], TextDB.Layout[4])
    Private.E:SetFont(Frame.TitleBar.Text, Private:FetchFont(Private.E.db.general.font), TextDB.FontSize, Private.E.db.general.fontStyle)
    Frame.TitleBar.Text:SetTextColor(unpack(TextDB.Colour))
    Frame.TitleBar.Text:SetShown(TextDB.Enable)
    Frame.TitleBar.Deaths_Text:ClearAllPoints()
    Frame.TitleBar.Deaths_Text:SetPoint("RIGHT", Frame.TitleBar, "RIGHT", -3, TextDB.Layout[4])
    Private.E:SetFont(Frame.TitleBar.Deaths_Text, Private:FetchFont(Private.E.db.general.font), TextDB.FontSize, Private.E.db.general.fontStyle)
    Frame.TitleBar.Deaths_Text:SetTextColor(unpack(TextDB.Colour))
    Frame.TitleBar.Deaths_Text:SetShown(DB.ShowDeaths and TextDB.Enable)
    if DB.ShowDeaths and TextDB.Layout[1] == "LEFT" and TextDB.Layout[2] == "LEFT" then
        Frame.TitleBar.Text:SetPoint("RIGHT", Frame.TitleBar.Deaths_Text, "LEFT", -3, 0)
    end
    for _, Row in ipairs(Frame.Rows) do Row:UpdateSettings(DB) end
    Frame:UpdateEnabled()
end
