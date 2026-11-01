local Private = select(2, ...)

function Private:ReadMythicPlusTime(Frame)
    local Data = Frame.Run
    if Data and Data.TimerID and not Data.Completed then
        local _, Elapsed, TimerType = GetWorldElapsedTime(Data.TimerID)
        if not issecretvalue(TimerType) and TimerType == Enum.WorldElapsedTimerTypes.ChallengeMode then
            if issecretvalue(Elapsed) or Elapsed then Data.Elapsed = Elapsed end
        end
    end
end

function Private:RefreshMythicPlusClock(Frame)
    local DB = Frame.MythicPlusDB
    local Data = Frame.Run or Frame.Preview
    if not Data then return end
    Private:ReadMythicPlusTime(Frame)

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
    local SecretElapsed = issecretvalue(Elapsed)
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
