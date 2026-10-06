local Private = select(2, ...)

function Private:SetupDungeonCasts()
    local DB = Private.DB.global.DungeonCasts
    local Frame = Private.DungeonCastsFrame
    if not Frame then
        Frame = CreateFrame("Frame", nil, UIParent)
        Frame.Bars, Frame.Units, Frame.Casts = {}, {}, {}
        Frame.Sequence = 0
        Frame.Formatter = C_StringUtil.CreateNumericRuleFormatter()
        Frame.Formatter:SetBreakpoints({
            {threshold = 0, step = 0.1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%.1f"},
            {threshold = 3, step = 1, rounding = Enum.NumericRuleFormatRounding.Up, format = "%d"},
        })
        Frame:SetScript("OnEvent", function(_, Event, ...) Private:UpdateDungeonCasts(Event, ...) end)
        Private.DungeonCastsFrame = Frame
    end

    Frame:UnregisterAllEvents()
    if not DB.Enable then
        if Frame.TestTimer then Frame.TestTimer:Cancel() Frame.TestTimer = nil end
        Frame.Testing = false
        for _, Cast in pairs(Frame.Casts) do if Cast.HoldTimer then Cast.HoldTimer:Cancel() end end
        wipe(Frame.Units)
        wipe(Frame.Casts)
        for _, Bar in ipairs(Frame.Bars) do Bar.Binding:SetEnabled(false) Bar:Hide() end
        Frame:Hide()
        return
    end

    local Height = math.max(DB.Size[2], 12)
    local Width = math.max(DB.Size[1], Height + DB.FontSize * 3.5 + 24)
    local Up = DB.GrowthDirection == "UP"
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(Width, Height)
    for Index = 1, DB.Num do
        local Bar = Frame.Bars[Index]
        if not Bar then
            Bar = CreateFrame("StatusBar", nil, Frame)
            Bar.Background = Bar:CreateTexture(nil, "BACKGROUND")
            Bar.Background:SetAllPoints()
            Bar.Icon = Bar:CreateTexture(nil, "ARTWORK")
            Bar.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            Bar.Icon:SetPoint("RIGHT", Bar, "LEFT", 1, 0)
            Bar.Border = CreateFrame("Frame", nil, Bar)
            Bar.Border:SetPoint("TOPLEFT", Bar.Icon, "TOPLEFT")
            Bar.Border:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT")
            Bar.Border:EnableMouse(false)
            for _, Edge in ipairs({"Top", "Bottom", "Left", "Right"}) do Bar.Border[Edge] = Bar.Border:CreateTexture(nil, "OVERLAY") Bar.Border[Edge]:SetColorTexture(0, 0, 0, 1) end
            Bar.Border.Top:SetPoint("TOPLEFT")
            Bar.Border.Top:SetPoint("TOPRIGHT")
            Bar.Border.Bottom:SetPoint("BOTTOMLEFT")
            Bar.Border.Bottom:SetPoint("BOTTOMRIGHT")
            Bar.Border.Left:SetPoint("TOPLEFT")
            Bar.Border.Left:SetPoint("BOTTOMLEFT")
            Bar.Border.Right:SetPoint("TOPRIGHT")
            Bar.Border.Right:SetPoint("BOTTOMRIGHT")
            Bar.Marker = Bar:CreateTexture(nil, "OVERLAY")
            Bar.Marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
            Bar.Marker:SetPoint("LEFT", 3, 0)
            Bar.Name = Bar:CreateFontString(nil, "OVERLAY")
            Bar.Name:SetJustifyH("LEFT")
            Bar.Name:SetWordWrap(false)
            Bar.Time = Bar:CreateFontString(nil, "OVERLAY")
            Bar.Time:SetPoint("RIGHT", -3, 0)
            Bar.Time:SetJustifyH("RIGHT")
            Bar.Binding = C_DurationUtil.CreateDurationTextBinding()
            Bar.Binding:SetFontString(Bar.Time)
            Bar.Binding:SetFormatter(Frame.Formatter)
            Frame.Bars[Index] = Bar
        end
        Bar:ClearAllPoints()
        Bar:SetPoint(Up and "BOTTOMRIGHT" or "TOPRIGHT", Frame, Up and "BOTTOMRIGHT" or "TOPRIGHT", 0, (Up and 1 or -1) * (Index - 1) * (Height + DB.Spacing))
        Bar:SetSize(Width - Height - 1, Height)
        Bar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", DB.Texture))
        Bar.Background:SetColorTexture(unpack(DB.BackgroundColour))
        Bar.Icon:SetSize(Height, Height)
        local Pixel = PixelUtil.GetPixelToUIUnitFactor() / Bar:GetEffectiveScale()
        Bar.Border.Top:SetHeight(Pixel)
        Bar.Border.Bottom:SetHeight(Pixel)
        Bar.Border.Left:SetWidth(Pixel)
        Bar.Border.Right:SetWidth(Pixel)
        Bar.Marker:SetSize(math.min(Height, 18), math.min(Height, 18))
        Bar.Name:SetFont(Private:FetchFont(DB.Font), DB.FontSize, DB.FontFlag)
        Bar.Time:SetFont(Private:FetchFont(DB.Font), DB.FontSize, DB.FontFlag)
        Bar.Time:SetSize(DB.FontSize * 3.5, Height)
    end
    Frame:Show()
    Frame:RegisterEvent("UI_SCALE_CHANGED")

    if not Frame.Testing then
        for _, Event in ipairs({
            "PLAYER_ENTERING_WORLD", "NAME_PLATE_UNIT_ADDED", "NAME_PLATE_UNIT_REMOVED", "UNIT_FACTION", "RAID_TARGET_UPDATE",
            "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
            "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_CHANNEL_STOP",
            "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "SPELL_UPDATE_COOLDOWN", "SPELLS_CHANGED", "UNIT_PET",
        }) do
            Frame:RegisterEvent(Event)
        end
        Private:UpdateDungeonCasts("SPELLS_CHANGED")
        Private:UpdateDungeonCasts("REFRESH")
    else
        Private:UpdateDungeonCasts()
    end
end

function Private:UpdateDungeonCasts(Event, Unit, CastGUID, SpellID, Extra, CastBarID)
    local Frame = Private.DungeonCastsFrame
    local DB = Private.DB.global.DungeonCasts
    if not Frame or not DB.Enable then return end
    if Event == "UI_SCALE_CHANGED" then Private:SetupDungeonCasts() return end
    if Event == "UNIT_FACTION" then
        if Unit == "player" then
            Unit = nil
        elseif not Frame.Units[Unit] then
            return
        end
    end

    if Event == "SPELLS_CHANGED" or Event == "PLAYER_ENTERING_WORLD" or (Event == "UNIT_PET" and Unit == "player") then
        Frame.InterruptID = nil
        for _, ID in ipairs(Private.InterruptIDs[select(2, UnitClass("player"))]) do
            if C_SpellBook.IsSpellKnown(ID, Enum.SpellBookSpellBank.Player) or C_SpellBook.IsSpellKnown(ID, Enum.SpellBookSpellBank.Pet) then Frame.InterruptID = ID break end
        end
    end

    if Event == "PLAYER_ENTERING_WORLD" then
        Unit = nil
        for _, Cast in pairs(Frame.Casts) do
            if Cast.HoldTimer then Cast.HoldTimer:Cancel() end
        end
        wipe(Frame.Casts)
    end
    if Event == "REFRESH" or Event == "PLAYER_ENTERING_WORLD" then
        wipe(Frame.Units)
        for _, NamePlate in ipairs(C_NamePlate.GetNamePlates()) do
            local Token = NamePlate:GetUnit()
            if Token then Frame.Units[Token] = true end
        end
        for Token, Cast in pairs(Frame.Casts) do
            if not Frame.Units[Token] and not Cast.Holding then Frame.Casts[Token] = nil end
        end
    elseif Event == "NAME_PLATE_UNIT_ADDED" then
        Frame.Units[Unit] = true
    elseif Event == "NAME_PLATE_UNIT_REMOVED" then
        Frame.Units[Unit] = nil
        if Frame.Casts[Unit] and not Frame.Casts[Unit].Holding then Frame.Casts[Unit] = nil end
    elseif Event == "HOLD_FINISHED" then
        if Frame.Casts[Unit] == CastGUID then Frame.Casts[Unit] = nil end
    elseif Event and Event:find("^UNIT_SPELLCAST_") then
        if not Frame.Units[Unit] then return end
        local Cast = Frame.Casts[Unit]
        if Event == "UNIT_SPELLCAST_STOP" or Event == "UNIT_SPELLCAST_FAILED" or Event == "UNIT_SPELLCAST_INTERRUPTED" or Event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            -- Stop events put the public cast ID after the interrupter GUID when present.
            local ID = Extra
            if Event == "UNIT_SPELLCAST_INTERRUPTED" or Event == "UNIT_SPELLCAST_CHANNEL_STOP" then ID = CastBarID end
            if not Cast or Cast.ID ~= ID or Cast.Holding then return end
            if Event == "UNIT_SPELLCAST_INTERRUPTED" or (Event == "UNIT_SPELLCAST_CHANNEL_STOP" and (issecretvalue(Extra) or Extra ~= nil)) then
                Cast.Holding = true
                Cast.InterruptedBy = Extra
                Cast.HoldTimer = C_Timer.NewTimer(2, function() Private:UpdateDungeonCasts("HOLD_FINISHED", Unit, Cast) end)
            else
                Frame.Casts[Unit] = nil
            end
        elseif Cast and Event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
            Cast.NotInterruptible = false
        elseif Cast and Event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
            Cast.NotInterruptible = true
        end
    elseif Event == "UNIT_PET" and Unit ~= "player" then
        return
    end

    if Event == "REFRESH" or Event == "PLAYER_ENTERING_WORLD" or Event == "NAME_PLATE_UNIT_ADDED" or Event == "UNIT_FACTION"
        or Event == "UNIT_SPELLCAST_START" or Event == "UNIT_SPELLCAST_DELAYED" or Event == "UNIT_SPELLCAST_CHANNEL_START" or Event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        for Token in pairs(Frame.Units) do
            if not Unit or Token == Unit then
                local Cast = Frame.Casts[Token]
                if UnitCanAttack("player", Token) and not UnitPlayerControlled(Token) then
                    local Name, _, Icon, _, _, _, _, NotInterruptible, _, ID = UnitCastingInfo(Token)
                    local Channel = false
                    if not ID then
                        Name, _, Icon, _, _, _, NotInterruptible, _, _, _, ID = UnitChannelInfo(Token)
                        Channel = true
                    end
                    if ID then
                        if not Cast or Cast.ID ~= ID then
                            if Cast and Cast.HoldTimer then Cast.HoldTimer:Cancel() end
                            Frame.Sequence = Frame.Sequence + 1
                            Cast = {ID = ID, Order = Frame.Sequence}
                            Frame.Casts[Token] = Cast
                        end
                        if not Cast.Holding then
                            Cast.Name, Cast.Icon, Cast.NotInterruptible = Name, Icon, NotInterruptible
                            if not issecretvalue(NotInterruptible) and NotInterruptible == nil then Cast.NotInterruptible = false end
                            Cast.Duration = Channel and UnitChannelDuration(Token) or UnitCastingDuration(Token)
                            Cast.Direction = Channel and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime
                        end
                    elseif Cast and not Cast.Holding then
                        Frame.Casts[Token] = nil
                    end
                elseif Cast and not Cast.Holding then
                    Frame.Casts[Token] = nil
                end
            end
        end
    end

    local Ready = false
    if Frame.InterruptID then
        local Cooldown = C_Spell.GetSpellCooldownDuration(Frame.InterruptID, true)
        if Cooldown then Ready = Cooldown:IsZero() end
    end
    local Casts = {}
    for Token, Cast in pairs(Frame.Casts) do
        if not Frame.Testing and Frame.Units[Token] and not Cast.Holding then Cast.Marker = GetRaidTargetIndex(Token) end
        Casts[#Casts + 1] = Cast
    end
    table.sort(Casts, function(A, B) return A.Order < B.Order end)
    for Index, Bar in ipairs(Frame.Bars) do
        local Cast = Index <= DB.Num and Casts[Index]
        if Cast then
            Bar.Icon:SetTexture(Cast.Icon)
            local HasMarker = issecretvalue(Cast.Marker) or Cast.Marker ~= nil
            Bar.Marker:SetShown(HasMarker)
            if HasMarker then SetRaidTargetIconTexture(Bar.Marker, Cast.Marker) end
            Bar.Name:ClearAllPoints()
            Bar.Name:SetPoint("LEFT", Bar, "LEFT", HasMarker and math.min(DB.Size[2], 18) + 5 or 3, 0)
            Bar.Name:SetPoint("RIGHT", Cast.Holding and Bar or Bar.Time, Cast.Holding and "RIGHT" or "LEFT", -3, 0)
            if Cast.Holding then
                Bar.Binding:SetEnabled(false)
                Bar.Time:SetText("")
                Bar:SetMinMaxValues(0, 1)
                Bar:SetValue(1)
                Bar.Name:SetText("Interrupted")
                if issecretvalue(Cast.InterruptedBy) or Cast.InterruptedBy ~= nil then
                    local Name = UnitNameFromGUID(Cast.InterruptedBy)
                    local _, Class = UnitClassFromGUID(Cast.InterruptedBy)
                    local Colour
                    if issecretvalue(Class) or Class then Colour = C_ClassColor.GetClassColor(Class) end
                    if issecretvalue(Name) or Name then
                        if Colour then Name = C_ColorUtil.WrapTextInColor(Name, Colour) end
                        Bar.Name:SetFormattedText("Interrupted By %s", Name)
                    end
                end
                Bar:SetStatusBarColor(unpack(DB.NonInterruptibleColour))
            else
                Bar.Name:SetText(Cast.Name)
                Bar:SetTimerDuration(Cast.Duration, Enum.StatusBarInterpolation.Immediate, Cast.Direction)
                Bar.Binding:SetDuration(Cast.Duration)
                Bar.Binding:SetEnabled(true)
                local CanInterrupt = Ready
                if Frame.Testing then CanInterrupt = Cast.Ready end
                local Colour = {}
                for Component = 1, 4 do
                    local Available = C_CurveUtil.EvaluateColorValueFromBoolean(CanInterrupt, DB.InterruptibleColour[Component], DB.InterruptOnCooldownColour[Component])
                    Colour[Component] = C_CurveUtil.EvaluateColorValueFromBoolean(Cast.NotInterruptible, DB.NonInterruptibleColour[Component], Available)
                end
                Bar:SetStatusBarColor(unpack(Colour))
            end
            Bar:Show()
        else
            Bar.Binding:SetEnabled(false)
            Bar:Hide()
        end
    end
end

function Private:TestDungeonCasts()
    local Frame = Private.DungeonCastsFrame
    local Testing = Private.PreviewDungeonCastsActive and Private.DB.global.DungeonCasts.Enable or false
    if not Frame or (not Testing and not Frame.Testing) then return end
    if Frame.TestTimer and not Testing then Frame.TestTimer:Cancel() Frame.TestTimer = nil end
    for _, Cast in pairs(Frame.Casts) do
        if Cast.HoldTimer then Cast.HoldTimer:Cancel() end
    end
    wipe(Frame.Casts)
    wipe(Frame.Units)
    Frame.Testing = Testing
    if Frame.Testing then
        local TestDuration = 5
        for Index, Name in ipairs({"Interrupt Ready", "Cannot Interrupt", "Interrupt On Cooldown", "Interrupted"}) do
            local Duration = C_DurationUtil.CreateDuration()
            Duration:SetTimeFromStart(GetTime(), TestDuration)
            Frame.Casts[Index] = {
                Order = Index, Name = Name, Icon = 136197, Marker = Index,
                Duration = Duration, Direction = Enum.StatusBarTimerDirection.ElapsedTime,
                NotInterruptible = Index == 2, Ready = Index == 1,
            }
        end
        local Cast = Frame.Casts[4]
        Cast.Holding, Cast.InterruptedBy = true, UnitGUID("player")
        Cast.HoldTimer = C_Timer.NewTimer(2, function() Private:UpdateDungeonCasts("HOLD_FINISHED", 4, Cast) end)
        Frame.TestTimer = Frame.TestTimer or C_Timer.NewTicker(TestDuration, function() Private:TestDungeonCasts() end)
    end
    Private:SetupDungeonCasts()
end
