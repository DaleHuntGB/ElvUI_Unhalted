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
        end
        Row.TickLimit, Row.TickBonus, Row.TickWidth = Limit, Bonus, DB.Width
    end
    local Elapsed = Data.Elapsed
    local Colour = DB.Colours.Progress
    Row.StatusBar:SetMinMaxValues(0, Limit)
    Row.StatusBar:SetValue(Elapsed)
    if issecretvalue(Elapsed) then
        Row.Name_Text:SetText("Elapsed")
        Row.Amount_Text:SetFormattedText("%.0fs", Elapsed)
    else
        local Remaining = Data.Limit - Elapsed
        if Data.Completed then
            Row.Name_Text:SetFormattedText("Completed +%d", Data.Upgrade or 0)
            Row.Amount_Text:SetText(SecondsToClock(Elapsed))
            Colour = Data.OnTime and DB.Colours.Complete or DB.Colours.Expired
        else
            Row.Name_Text:SetFormattedText("Elapsed %s", SecondsToClock(Elapsed))
            Row.Amount_Text:SetFormattedText("%s%s / %s", Remaining < 0 and "+" or "", SecondsToClock(math.abs(Remaining)), SecondsToClock(Data.Limit))
            if Remaining < 0 then Colour = DB.Colours.Expired
            elseif Elapsed <= ThirdTarget then Colour = DB.Colours.Third
            elseif Elapsed <= SecondTarget then Colour = DB.Colours.Second end
        end
    end
    Row.StatusBar:SetStatusBarColor(unpack(Colour))
    Row:Show()
end
