local Private = select(2, ...)
Private.MythicPlusTimerPreview = false

local Preview = {
    Name = "The Rookery", Level = 12, Limit = 1920, Elapsed = 1380, Deaths = 2, TimeLost = 10,
    Objectives = {
        {Name = "Kyrioss", Value = 1, Maximum = 1, Complete = true, CompletionTime = 510},
        {Name = "Stormguard Gorren", Value = 0, Maximum = 1},
        {Name = "Voidstone Monstrosity", Value = 0, Maximum = 1},
        {Name = "Enemy Forces", Value = 72.5, Maximum = 100, Percent = true},
    },
}

local function UpdateMythicPlusTracker(Frame, Hidden)
    if not ObjectiveTrackerFrame or Frame.TrackerHidden == Hidden then return end
    ObjectiveTrackerFrame:SetRolesets(Hidden and "alwaysBlocked" or "objectives")
    Frame.TrackerHidden = Hidden
end

local function CreateMythicPlusRow(Window, Index, DB)
    local function Row_UpdateSettings(Row, Settings)
        local TextDB = Settings.Text
        local Font = Private:FetchFont(Private.E.db.general.font)
        Row:ClearAllPoints()
        Row:SetPoint("TOPLEFT", Window, "TOPLEFT", 1, -1 - ((Index - 1) * Settings.RowHeight))
        Row:SetPoint("TOPRIGHT", Window, "TOPRIGHT", -1, -1 - ((Index - 1) * Settings.RowHeight))
        Row:SetHeight(Settings.RowHeight)
        Row.StatusBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", Settings.Texture))
        Private.E:SetFont(Row.Name_Text, Font, TextDB.Name_FontSize, Private.E.db.general.fontStyle)
        Private.E:SetFont(Row.Amount_Text, Font, TextDB.Amount_FontSize, Private.E.db.general.fontStyle)
        Row.Amount_Text:ClearAllPoints()
        Row.Amount_Text:SetPoint("RIGHT", Row.StatusBar, "RIGHT", TextDB.Amount_XOffset, TextDB.Amount_YOffset)
        Row.Amount_Text:SetTextColor(unpack(TextDB.Amount_Colour))
        Row.Name_Text:ClearAllPoints()
        Row.Name_Text:SetPoint("LEFT", Row.StatusBar, "LEFT", TextDB.Name_XOffset, TextDB.Name_YOffset)
        Row.Name_Text:SetPoint("RIGHT", Row.Amount_Text, "LEFT", -3, TextDB.Name_YOffset - TextDB.Amount_YOffset)
        Row.Name_Text:SetTextColor(unpack(TextDB.Name_Colour))
        if Row.TickTexts then
            for _, Text in ipairs(Row.TickTexts) do
                Private.E:SetFont(Text, Font, TextDB.Amount_FontSize, Private.E.db.general.fontStyle)
            end
        end
    end

    local Row = CreateFrame("Frame", nil, Window)
    Row.StatusBar = CreateFrame("StatusBar", nil, Row)
    Row.StatusBar:SetAllPoints(Row)
    Row.StatusBar:EnableMouse(false)
    Row.Background = Row.StatusBar:CreateTexture(nil, "BACKGROUND")
    Row.Background:SetAllPoints(Row.StatusBar)
    Row.Background:SetColorTexture(Private.E.BackgroundFadeColour.r, Private.E.BackgroundFadeColour.g, Private.E.BackgroundFadeColour.b, Private.E.BackgroundFadeColour.a)
    Row.Name_Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
    Row.Name_Text:SetJustifyH("LEFT")
    Row.Name_Text:SetWordWrap(false)
    Row.Amount_Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
    Row.Amount_Text:SetJustifyH("RIGHT")
    Row.Amount_Text:SetWordWrap(false)
    if Index == 1 then
        Row.TickTexts = {}
        for i = 1, 2 do
            local Text = Row.StatusBar:CreateFontString(nil, "OVERLAY")
            Text:SetJustifyH("RIGHT")
            Text:SetWordWrap(false)
            Row.TickTexts[i] = Text
        end
    end
    Row.UpdateSettings = Row_UpdateSettings
    Row:UpdateSettings(DB)
    return Row
end

local function ReadMythicPlusTime(Frame)
    local Data = Frame.Run
    if Data and Data.TimerID and not Data.Completed then
        local _, Elapsed, TimerType = GetWorldElapsedTime(Data.TimerID)
        if not Private:IsSecret(TimerType) and TimerType == Enum.WorldElapsedTimerTypes.ChallengeMode then
            if Private:IsSecret(Elapsed) or Elapsed then Data.Elapsed = Elapsed end
        end
    end
end

local function RefreshMythicPlusClock(Frame)
    local DB = Frame.MythicPlusDB
    local Data = Frame.Run or Frame.Preview
    if not Data then return end
    ReadMythicPlusTime(Frame)

    local Row = Frame:GetRow(1)
    local Limit = math.max(1, Data.Limit)
    local Bonus = Data.Peril and math.min(90, Limit) or 0
    local ThirdTarget = (Limit - Bonus) * 0.6 + Bonus
    local SecondTarget = (Limit - Bonus) * 0.8 + Bonus
    if Row.TickLimit ~= Limit or Row.TickBonus ~= Bonus or Row.TickWidth ~= DB.Width then
        Row.Ticks = Row.Ticks or {}
        for Index, Target in ipairs({ThirdTarget, SecondTarget}) do
            local Tick = Row.Ticks[Index]
            if not Tick then
                Tick = Row.StatusBar:CreateTexture(nil, "OVERLAY", nil, -1)
                Tick:SetColorTexture(1, 1, 1, 0.75)
                Tick:SetWidth(1)
                Row.Ticks[Index] = Tick
            end
            local Offset = (DB.Width - 2) * Target / Limit
            Tick:ClearAllPoints()
            Tick:SetPoint("TOPLEFT", Row.StatusBar, "TOPLEFT", Offset, 0)
            Tick:SetPoint("BOTTOMLEFT", Row.StatusBar, "BOTTOMLEFT", Offset, 0)
            local Text = Row.TickTexts[Index]
            Text:ClearAllPoints()
            Text:SetPoint("RIGHT", Tick, "LEFT", -3, 0)
            Text:SetWidth(math.max(1, (DB.Width - 2) * (SecondTarget - ThirdTarget) / Limit - 6))
        end
        Row.TickLimit, Row.TickBonus, Row.TickWidth = Limit, Bonus, DB.Width
    end
    local Elapsed = Data.Elapsed
    local SecretElapsed = Private:IsSecret(Elapsed)
    for Index, Text in ipairs(Row.TickTexts) do
        local TextColour = DB.Text.Amount_Colour
        if SecretElapsed then
            Text:SetText("--:--")
        else
            local Remaining = (Index == 1 and ThirdTarget or SecondTarget) - Elapsed
            Text:SetFormattedText("%s%s", Remaining < 0 and "-" or "", SecondsToClock(math.abs(Remaining)))
            if Remaining < 0 then TextColour = DB.Colours.Expired end
        end
        Text:SetTextColor(unpack(TextColour))
    end
    local Colour = DB.Colours.Progress
    Row.StatusBar:SetMinMaxValues(0, Limit)
    Row.StatusBar:SetValue(Elapsed)
    if SecretElapsed then
        Row.Name_Text:SetText("Elapsed")
        Row.Amount_Text:SetFormattedText("%.0fs", Elapsed)
    else
        local Remaining = Data.Limit - Elapsed
        if Data.Completed then
            Row.Name_Text:SetFormattedText("+%d", Data.Upgrade or 0)
            Row.Amount_Text:SetText(SecondsToClock(Elapsed))
            Colour = Data.OnTime and DB.Colours.Complete or DB.Colours.Expired
        else
            Row.Name_Text:SetFormattedText("%s (%s)", SecondsToClock(Elapsed), SecondsToClock(Data.Limit))
            Row.Amount_Text:SetText("")
            if Remaining < 0 then Colour = DB.Colours.Expired
            elseif Elapsed <= ThirdTarget then Colour = DB.Colours.Third
            elseif Elapsed <= SecondTarget then Colour = DB.Colours.Second end
        end
    end
    Row.StatusBar:SetStatusBarColor(unpack(Colour))
    Row:Show()
end

local function RecordMythicPlusBoss(Frame, EncounterID, Name)
    local Run = Frame.Run
    if not Run or Run.Completed or Private:IsSecret(EncounterID) or not EncounterID then return end
    ReadMythicPlusTime(Frame)
    Run.BossCompletions = Run.BossCompletions or {}
    if not Run.BossCompletions[EncounterID] then
        Run.BossCompletions[EncounterID] = {Name = Name, Time = Run.Elapsed}
    end
    local Completion = Run.BossCompletions[EncounterID]
    for _, Objective in ipairs(Run.Objectives) do
        if Objective.EncounterID == EncounterID then
            Objective.Name = Completion.Name
            Objective.CompletionTime = Completion.Time
            Objective.Complete = true
            Objective.Value = Objective.Maximum
        end
    end
end

local function ReadMythicPlusObjectives(Frame)
    local Step = C_ScenarioInfo.GetScenarioStepInfo()
    if not Step or Private:IsSecret(Step.numCriteria) then return end
    ReadMythicPlusTime(Frame)
    local Run = Frame.Run
    local Previous = {}
    for _, Objective in ipairs(Run.Objectives) do Previous[Objective.ID] = Objective end
    local Objectives = {}
    for Index = 1, Step.numCriteria do
        local Info = C_ScenarioInfo.GetCriteriaInfo(Index)
        if Info and not Private:IsSecret(Info.isWeightedProgress) then
            local ID = Info.criteriaID
            if Private:IsSecret(ID) or not ID or ID == 0 then ID = Index end
            local Objective = Previous[ID] or {ID = ID}
            local EncounterID = not Private:IsSecret(Info.criteriaType) and Info.criteriaType == 165 and not Private:IsSecret(Info.assetID) and Info.assetID or nil
            Objective.EncounterID = EncounterID
            local Completion = EncounterID and Run.BossCompletions and Run.BossCompletions[EncounterID]
            Objective.Name = Info.description
            Objective.Value = Info.quantity
            Objective.Maximum = Info.isWeightedProgress and 100 or Info.totalQuantity
            Objective.Percent = Info.isWeightedProgress
            Objective.Complete = Completion ~= nil or (not Private:IsSecret(Info.completed) and Info.completed)
            if not Objective.Percent then
                if Completion then
                    Objective.Name = Completion.Name
                    Objective.CompletionTime = Completion.Time
                elseif not Private:IsSecret(Objective.Name) then
                    Objective.Name = Objective.Name:gsub("^Defeat%s+", ""):gsub("%s+defeated$", "")
                end
                if Objective.Complete then
                    if not Private:IsSecret(Objective.CompletionTime) and not Objective.CompletionTime and not Private:IsSecret(Run.Elapsed) and not Private:IsSecret(Info.elapsed) and Info.elapsed then
                        Objective.CompletionTime = math.max(0, Run.Elapsed - Info.elapsed)
                    end
                    Objective.Value = Objective.Maximum
                end
            end
            Objectives[#Objectives + 1] = Objective
        end
    end
    if #Objectives > 0 then Frame.Run.Objectives = Objectives end
end

local function RenderMythicPlusObjectives(Frame, Data, Index)
    local DB = Frame.MythicPlusDB
    for _, Objective in ipairs(Data.Objectives) do
        if (Objective.Percent and DB.ShowForces) or (not Objective.Percent and DB.ShowBosses) then
            local Row = Frame:GetRow(Index)
            local Colour = Objective.Complete and DB.Colours.Complete or DB.Colours.Progress
            local Maximum = Objective.Maximum
            if not Private:IsSecret(Maximum) and (not Maximum or Maximum <= 0) then Maximum = 1 end
            Row.StatusBar:SetMinMaxValues(0, Maximum)
            Row.StatusBar:SetValue(Objective.Value)
            Row.StatusBar:SetStatusBarColor(unpack(Colour))
            Row.Name_Text:SetText(Objective.Name)
            if Objective.Percent then
                Row.Amount_Text:SetFormattedText("%.1f%%", Objective.Value)
            elseif Objective.Complete and (Private:IsSecret(Objective.CompletionTime) or Objective.CompletionTime ~= nil) then
                if Private:IsSecret(Objective.CompletionTime) then
                    Row.Amount_Text:SetFormattedText("%.0fs", Objective.CompletionTime)
                else
                    Row.Amount_Text:SetText(SecondsToClock(Objective.CompletionTime))
                end
            else
                Row.Amount_Text:SetText("")
            end
            Row:Show()
            Index = Index + 1
        end
    end
    return Index
end

local function UpdateMythicPlusWindow(Frame, DB)
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

local function CreateMythicPlusWindow(DB)
    local function Window_GetRow(Frame, Index)
        if not Frame.Rows[Index] then Frame.Rows[Index] = CreateMythicPlusRow(Frame, Index, DB) end
        return Frame.Rows[Index]
    end

    local function Window_StopClock(Frame)
        if Frame.Ticker then Frame.Ticker:Cancel() Frame.Ticker = nil end
    end

    local function Window_ReadCompletion(Frame)
        local Run = Frame.Run
        if not Run or Run.Completed then return end
        local Info = C_ChallengeMode.GetChallengeCompletionInfo()
        if not Info or Private:IsSecret(Info.mapChallengeModeID) or Private:IsSecret(Info.time) then return end
        if Info.mapChallengeModeID ~= Run.MapID or Info.time <= 0 then return end
        Run.Completed, Run.Completing = true, nil
        Run.Elapsed = Info.time / 1000
        Run.Deaths, Run.TimeLost = C_ChallengeMode.GetDeathCount()
        if not Private:IsSecret(Info.level) and Info.level > 0 then Run.Level = Info.level end
        Run.OnTime = not Private:IsSecret(Info.onTime) and Info.onTime
        Run.Upgrade = not Private:IsSecret(Info.keystoneUpgradeLevels) and Info.keystoneUpgradeLevels or 0
        Frame:StopClock()
    end

    local function Window_Render(Frame)
        Frame.Preview = not Frame.Run and Private.MythicPlusTimerPreview and Preview or nil
        local Data = Frame.Run or Frame.Preview
        if not Data then
            Frame:StopClock()
            Frame:Hide()
            UpdateMythicPlusTracker(Frame, false)
            return
        end
        if Data.Limit <= 0 then
            Frame:Hide()
            UpdateMythicPlusTracker(Frame, false)
            return
        end
        Frame.TitleBar.Text:SetFormattedText("%s +%d", Data.Name, Data.Level)
        Frame.TitleBar.Deaths_Text:SetFormattedText("|cFFCC4040Deaths|r: %d - %s", Data.Deaths, SecondsToClock(Data.TimeLost))
        RefreshMythicPlusClock(Frame)
        local Index = RenderMythicPlusObjectives(Frame, Data, 2)
        for i = Index, #Frame.Rows do Frame.Rows[i]:Hide() end
        Frame:SetSize(DB.Width, 2 + (Index - 1) * DB.RowHeight)
        Frame:Show()
        UpdateMythicPlusTracker(Frame, Frame.Run ~= nil and Data.Limit > 0)
    end

    local function Window_RefreshData(Frame)
        if not DB.Enable then return end
        local _, InstanceType, Difficulty, _, _, _, _, InstanceID = GetInstanceInfo()
        local MapID = C_ChallengeMode.GetActiveChallengeMapID()
        if Private:IsSecret(MapID) then MapID = nil end
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
                if Private:IsSecret(Level) or Level > 0 then Run.Level = Level end
                Run.Limit = not Private:IsSecret(Limit) and Limit or 0
                Run.Peril = false
                for _, AffixID in ipairs(Affixes) do
                    if not Private:IsSecret(AffixID) and AffixID == 152 then Run.Peril = true end
                end
                Run.TimerID = nil
                for _, TimerID in ipairs({GetWorldElapsedTimers()}) do
                    local _, _, TimerType = GetWorldElapsedTime(TimerID)
                    if not Private:IsSecret(TimerType) and TimerType == Enum.WorldElapsedTimerTypes.ChallengeMode then Run.TimerID = TimerID break end
                end
                Run.Deaths, Run.TimeLost = C_ChallengeMode.GetDeathCount()
                ReadMythicPlusObjectives(Frame)
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
                        RefreshMythicPlusClock(Frame)
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
            if not Private:IsSecret(Success) and Success == 1 then
                RecordMythicPlusBoss(Frame, EncounterID, Name)
            end
        elseif Event == "WORLD_STATE_TIMER_STOP" and Frame.Run and not Private:IsSecret(...) and not Private:IsSecret(Frame.Run.TimerID) and ... == Frame.Run.TimerID then
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
            UpdateMythicPlusTracker(Frame, false)
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
    UpdateMythicPlusWindow(Frame, DB)
    return Frame
end

function Private:SetupMythicPlusTimer()
    local DB = Private.DB.global.MythicPlusTimer
    if DB.Enable then
        Private.MythicPlusTimerFrame = CreateMythicPlusWindow(DB)
    end
end

function Private:UpdateMythicPlusTimer()
    local DB = Private.DB.global.MythicPlusTimer
    local Frame = Private.MythicPlusTimerFrame
    if Frame then
        UpdateMythicPlusWindow(Frame, DB)
    elseif DB.Enable then
        Private.MythicPlusTimerFrame = CreateMythicPlusWindow(DB)
    end
end
