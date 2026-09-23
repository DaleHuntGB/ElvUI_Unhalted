local Private = select(2, ...)
local UF = Private.E:GetModule("UnitFrames")

local CastEvents = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    "UNIT_SPELLCAST_CHANNEL_START",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_START",
    "UNIT_SPELLCAST_EMPOWER_STOP",
    "UNIT_SPELLCAST_EMPOWER_UPDATE",
    "UNIT_TARGET",
    "UNIT_FACTION",
}

local UnitEvents = {
    "PLAYER_TARGET_CHANGED",
    "PLAYER_FOCUS_CHANGED",
    "UPDATE_MOUSEOVER_UNIT",
    "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
    "ARENA_OPPONENT_UPDATE",
    "RAID_TARGET_UPDATE",
}

local LoadEvents = {
    PLAYER_ENTERING_WORLD = true,
    ZONE_CHANGED_NEW_AREA = true,
    PLAYER_DIFFICULTY_CHANGED = true,
    CHALLENGE_MODE_START = true,
    CHALLENGE_MODE_RESET = true,
}

local TimeFormatter = C_StringUtil.CreateSecondsFormatter()
TimeFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
TimeFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds)
TimeFormatter:SetMillisecondsThreshold(60)

local function LayoutBars(Frame)
    local DB = Private.DB.global.DungeonCasts
    local GrowUp = DB.GrowthDirection == "UP"
    local Point = GrowUp and "BOTTOMLEFT" or "TOPLEFT"
    for Index, Bar in ipairs(Frame.Bars) do
        Bar:ClearAllPoints()
        Bar:SetPoint(Point, Frame, Point, 0, (Index - 1) * (DB.Size[2] + DB.Layout[5]) * (GrowUp and 1 or -1))
    end
end

local function ConfigureBar(Bar)
    local DB = Private.DB.global.DungeonCasts
    local IconLeft = DB.IconPosition == "LEFT"
    local Height = DB.Size[2]
    Bar:SetSize(DB.Size[1], Height)
    Bar.Icon:ClearAllPoints()
    Bar.Icon:SetSize(Height - 2, Height - 2)
    Bar.Icon:SetPoint(IconLeft and "LEFT" or "RIGHT", Bar.Display, IconLeft and "LEFT" or "RIGHT", IconLeft and 1 or -1, 0)
    Bar.Status:ClearAllPoints()
    Bar.Status:SetPoint("TOPLEFT", Bar.Display, "TOPLEFT", IconLeft and Height or 1, -1)
    Bar.Status:SetPoint("BOTTOMRIGHT", Bar.Display, "BOTTOMRIGHT", IconLeft and -1 or -Height, 1)
    Bar.Status:SetStatusBarTexture(Private.LSM:Fetch("statusbar", Private.E.db.unitframe.statusbar))
    Bar.RaidMarker:SetSize(Height - 6, Height - 6)
    local Font = Private.LSM:Fetch("font", DB.Font[1])
    Bar.Text:SetFont(Font, DB.Font[2], DB.Font[3])
    Bar.Time:SetFont(Font, DB.Font[2], DB.Font[3])
end

local function CreateBar(Frame)
    local Bar = CreateFrame("Frame", nil, Frame)
    Bar:EnableMouse(false)
    Bar.Masks = {}
    Bar.Display = CreateFrame("Frame", nil, Bar, "BackdropTemplate")
    Bar.Display:EnableMouse(false)
    Bar.Display:SetAllPoints(Bar)
    Bar.Display:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    Bar.Display:SetBackdropBorderColor(0, 0, 0, 1)
    Bar.Display:SetBackdropColor(20/255, 20/255, 20/255, 1)

    Bar.Icon = Bar.Display:CreateTexture(nil, "ARTWORK")
    Bar.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
    Bar.Status = CreateFrame("StatusBar", nil, Bar.Display)
    Bar.Status:EnableMouse(false)
    Bar.RaidMarker = Bar.Status:CreateTexture(nil, "OVERLAY")
    Bar.RaidMarker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    Bar.RaidMarker:SetPoint("LEFT", Bar.Status, "LEFT", 3, 0)

    Bar.Time = Bar.Status:CreateFontString(nil, "OVERLAY")
    Bar.Time:SetPoint("RIGHT", Bar.Status, "RIGHT", -3, 0)
    Bar.Time:SetJustifyH("RIGHT")
    Bar.Time:SetWordWrap(false)
    Bar.Time:SetTextColor(1, 1, 1, 1)
    Bar.TimeBinding = C_DurationUtil.CreateDurationTextBinding()
    Bar.TimeBinding:SetFormatter(TimeFormatter)
    Bar.TimeBinding:SetFontString(Bar.Time)
    Bar.TimeBinding:SetEnabled(false)

    Bar.Text = Bar.Status:CreateFontString(nil, "OVERLAY")
    Bar.Text:SetJustifyH("LEFT")
    Bar.Text:SetWordWrap(false)
    Bar.Text:SetTextColor(1, 1, 1, 1)
    ConfigureBar(Bar)
    return Bar
end

local function ColourBar(Bar)
    local Colours = Private.E.db.unitframe.colors
    local Cast, NoInterrupt = Colours.castColor, Colours.castNoInterrupt
    local Ready = Private:IsInterruptReady()
    Bar.Status:SetStatusBarColor(
        C_CurveUtil.EvaluateColorValueFromBoolean(Bar.NotInterruptible, NoInterrupt.r, C_CurveUtil.EvaluateColorValueFromBoolean(Ready, Cast.r, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Bar.NotInterruptible, NoInterrupt.g, C_CurveUtil.EvaluateColorValueFromBoolean(Ready, Cast.g, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Bar.NotInterruptible, NoInterrupt.b, C_CurveUtil.EvaluateColorValueFromBoolean(Ready, Cast.b, 128/255)),
        C_CurveUtil.EvaluateColorValueFromBoolean(Bar.NotInterruptible, NoInterrupt.a, Cast.a)
    )
end

function Private:UpdateDungeonCastColours()
    for _, Bar in ipairs(Private.DungeonCastsFrame.Bars) do
        if Bar:IsShown() then ColourBar(Bar) end
    end
end

local function ShowBar(Frame, Index, Unit, Name, Texture, Duration, Direction, NotInterruptible, Target, Marker)
    local Bar = Frame.Bars[Index]
    if not Bar then
        Bar = CreateBar(Frame)
        Frame.Bars[Index] = Bar
    end

    Bar.Unit = Unit
    if not issecretvalue(NotInterruptible) and NotInterruptible == nil then NotInterruptible = false end
    Bar.NotInterruptible = NotInterruptible
    local Parent, MaskCount = Bar, 0
    if Unit then
        -- Restricted unit comparisons can only control display alpha, as in Targeted Spells.
        for Previous = 1, Index - 1 do
            local SameUnit = Frame.UnitComparisons[Previous]
            if issecretvalue(SameUnit) then
                MaskCount = MaskCount + 1
                local Mask = Bar.Masks[MaskCount]
                if not Mask then
                    Mask = CreateFrame("Frame", nil, Parent)
                    Mask:EnableMouse(false)
                    Mask:SetAllPoints(Bar)
                    Bar.Masks[MaskCount] = Mask
                end
                Mask:SetAlphaFromBoolean(SameUnit, 0, 1)
                Parent = Mask
            end
        end
    end
    Bar.Display:SetParent(Parent)
    Bar.Icon:SetTexture(Texture)
    Bar.Status:SetTimerDuration(Duration, Enum.StatusBarInterpolation.Immediate, Direction)
    Bar.TimeBinding:SetDuration(Duration)
    Bar.TimeBinding:SetEnabled(true)
    if Target then
        local TargetClass = Private.E.myclass
        if Unit then TargetClass = UnitSpellTargetClass(Unit) end
        local Colour = UF:GetCasterColor(TargetClass)
        Bar.Text:SetFormattedText("%s: |c%s%s|r", Name, Colour or "FFFFFFFF", Target)
    else
        Bar.Text:SetText(Name)
    end

    Bar.Text:ClearAllPoints()
    Bar.Text:SetPoint("RIGHT", Bar.Time, "LEFT", -4, 0)
    if Marker then
        SetRaidTargetIconTexture(Bar.RaidMarker, Marker)
        Bar.RaidMarker:Show()
        Bar.Text:SetPoint("LEFT", Bar.RaidMarker, "RIGHT", 3, 0)
    else
        Bar.RaidMarker:Hide()
        Bar.Text:SetPoint("LEFT", Bar.Status, "LEFT", 3, 0)
    end
    ColourBar(Bar)
    Bar:Show()
end

local function HideBars(Frame, First)
    for Index = First, #Frame.Bars do
        local Bar = Frame.Bars[Index]
        Bar.Unit = nil
        Bar:Hide()
        Bar.TimeBinding:SetEnabled(false)
    end
end

local function RefreshCasts()
    local Frame = Private.DungeonCastsFrame
    local DB = Private.DB.global.DungeonCasts
    Frame.RefreshPending = nil
    if not Frame.Active or Private.DungeonCastsTestMode then return end

    local Count = 0
    for _, Unit in ipairs(Frame.Units) do
        if Count >= DB.MaxIcons then break end
        if UnitExists(Unit) and UnitCanAttack("player", Unit) then
            local Name, _, Texture, _, _, _, _, NotInterruptible = UnitCastingInfo(Unit)
            local Duration
            local Direction = Enum.StatusBarTimerDirection.ElapsedTime
            if Name then
                Duration = UnitCastingDuration(Unit)
            else
                local IsEmpowered
                Name, _, Texture, _, _, _, NotInterruptible, _, IsEmpowered = UnitChannelInfo(Unit)
                if Name then
                    Duration = IsEmpowered and UnitEmpoweredChannelDuration(Unit) or UnitChannelDuration(Unit)
                    if not IsEmpowered then Direction = Enum.StatusBarTimerDirection.RemainingTime end
                end
            end

            if Duration then
                local Duplicate = false
                for Index = 1, Count do
                    local SameUnit = UnitIsUnit(Unit, Frame.Bars[Index].Unit)
                    Frame.UnitComparisons[Index] = SameUnit
                    if not issecretvalue(SameUnit) and SameUnit then Duplicate = true break end
                end
                if not Duplicate then
                    Count = Count + 1
                    ShowBar(Frame, Count, Unit, Name, Texture, Duration, Direction, NotInterruptible, UnitSpellTargetName(Unit), GetRaidTargetIndex(Unit))
                end
            end
        end
    end
    HideBars(Frame, Count + 1)
    LayoutBars(Frame)
end

local function QueueRefresh(Frame)
    if Frame.RefreshPending then return end
    Frame.RefreshPending = true
    RunNextFrame(RefreshCasts)
end

local function AddUnit(Frame, Unit)
    if issecretvalue(Unit) or not Unit or Frame.KnownUnits[Unit] then return end
    if not UnitCanAttack("player", Unit) then return end
    Frame.KnownUnits[Unit] = true
    Frame.Units[#Frame.Units + 1] = Unit
end

local function ScanUnits(Frame)
    wipe(Frame.Units)
    wipe(Frame.KnownUnits)
    for _, NamePlate in ipairs(C_NamePlate.GetNamePlates()) do AddUnit(Frame, NamePlate.namePlateUnitToken) end
    for Index = 1, MAX_BOSS_FRAMES do AddUnit(Frame, "boss" .. Index) end
    for Index = 1, 5 do AddUnit(Frame, "arena" .. Index) end
    for _, Unit in ipairs({ "target", "focus", "mouseover" }) do AddUnit(Frame, Unit) end
end

local function OnEvent(Frame, Event, Unit)
    if LoadEvents[Event] then Private:UpdateDungeonCasts() return end
    if Event == "PLAYER_REGEN_DISABLED" then if Private.DungeonCastsTestMode then Private:SetDungeonCastsTestMode(false) end return end
    if Private.DungeonCastsTestMode then return end

    if Event == "NAME_PLATE_UNIT_REMOVED" then
        if not issecretvalue(Unit) and Frame.KnownUnits[Unit] then
            Frame.KnownUnits[Unit] = nil
            for Index, KnownUnit in ipairs(Frame.Units) do
                if KnownUnit == Unit then table.remove(Frame.Units, Index) break end
            end
        end
    elseif Event == "NAME_PLATE_UNIT_ADDED" then
        AddUnit(Frame, Unit)
    elseif Event == "UNIT_TARGET" or Event == "UNIT_FACTION" or Event:find("^UNIT_SPELLCAST_") then
        if issecretvalue(Unit) or not Unit then return end
        AddUnit(Frame, Unit)
        if not Frame.KnownUnits[Unit] then return end
    else
        ScanUnits(Frame)
    end
    QueueRefresh(Frame)
end

local function ShowTestCasts()
    local Frame = Private.DungeonCastsFrame
    local Samples = {
        { "Fireball", 135812, false, 8 },
        { "Shadow Bolt", 136197, true, 7 },
        { "Arcane Missiles", 136096, false, 6 },
    }
    local Count = math.min(#Samples, Private.DB.global.DungeonCasts.MaxIcons)
    for Index = 1, Count do
        local Sample = Samples[Index]
        local Duration = C_DurationUtil.CreateDuration()
        Duration:SetTimeFromStart(GetTime(), 8)
        ShowBar(Frame, Index, nil, Sample[1], Sample[2], Duration, Index == 3 and Enum.StatusBarTimerDirection.RemainingTime or Enum.StatusBarTimerDirection.ElapsedTime, Sample[3], UnitName("player"), Sample[4])
    end
    HideBars(Frame, Count + 1)
    LayoutBars(Frame)
end

function Private:SetDungeonCastsTestMode(Enabled)
    if Enabled and (not Private.DB.global.DungeonCasts.Enabled or InCombatLockdown()) then return end
    Private.DungeonCastsTestMode = Enabled
    Private:UpdateDungeonCasts()
    Private.ACR:NotifyChange("ElvUI")
end

function Private:SetupDungeonCasts()
    if not Private.DungeonCastsFrame then
        local Frame = CreateFrame("Frame", nil, UIParent)
        Frame:EnableMouse(false)
        Frame:SetFrameStrata("HIGH")
        Frame.Bars = {}
        Frame.Units = {}
        Frame.KnownUnits = {}
        Frame.UnitComparisons = {}
        Frame:SetScript("OnEvent", OnEvent)
        Private.DungeonCastsFrame = Frame
    end
    Private:UpdateDungeonCasts()
end

function Private:UpdateDungeonCasts()
    local DB = Private.DB.global.DungeonCasts
    local Frame = Private.DungeonCastsFrame
    if not Frame then Private:SetupDungeonCasts() return end

    Frame:UnregisterAllEvents()
    Frame.Active = false
    if Frame.TestTimer then Frame.TestTimer:Cancel() Frame.TestTimer = nil end
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(DB.Size[1], DB.Size[2])
    HideBars(Frame, 1)
    for _, Bar in ipairs(Frame.Bars) do ConfigureBar(Bar) end
    wipe(Frame.Units)
    wipe(Frame.KnownUnits)

    if not DB.Enabled then
        Private.DungeonCastsTestMode = false
        Private:UpdateCastbarInterruptCooldown()
        Frame:Hide()
        return
    end

    for Event in pairs(LoadEvents) do Frame:RegisterEvent(Event) end
    Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    if Private.DungeonCastsTestMode and not InCombatLockdown() then
        Private:UpdateCastbarInterruptCooldown()
        Frame:Show()
        ShowTestCasts()
        Frame.TestTimer = C_Timer.NewTicker(8, ShowTestCasts)
        return
    end

    Private.DungeonCastsTestMode = false
    local _, InstanceType, DifficultyID = GetInstanceInfo()
    if next(DB.LoadConditions) and not DB.LoadConditions[InstanceType] and not DB.LoadConditions[DifficultyID] then
        Private:UpdateCastbarInterruptCooldown()
        Frame:Hide()
        return
    end

    Frame.Active = true
    Private:UpdateCastbarInterruptCooldown()
    Frame:Show()
    for _, Event in ipairs(CastEvents) do Frame:RegisterEvent(Event) end
    for _, Event in ipairs(UnitEvents) do Frame:RegisterEvent(Event) end
    Frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    Frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    ScanUnits(Frame)
    QueueRefresh(Frame)
end
