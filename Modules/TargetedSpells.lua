local Private = select(2, ...)

local CastEvents = {
    "UNIT_SPELLCAST_START",
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED",
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
    "PLAYER_ENTERING_WORLD",
    "PLAYER_TARGET_CHANGED",
    "PLAYER_FOCUS_CHANGED",
    "UPDATE_MOUSEOVER_UNIT",
    "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
    "ARENA_OPPONENT_UPDATE",
}

local function HideBar(Bar)
    Bar.Unit = nil
    Bar:Hide()
    Bar.TimeBinding:SetEnabled(false)
    Bar.StatusBar:SetMinMaxValues(0, 1)
    Bar.StatusBar:SetValue(0)
    Bar.CastName:SetText("")
    Bar.CastTime:SetText("")
end

local function LayoutBar(Bar)
    local DB = Private.DB.global.TargetedSpells
    local Width, Height = DB.Size[1], DB.Size[2]
    Bar:SetSize(Width, Height)
    Bar.Display:SetBackdropColor(unpack(DB.BackgroundColour))

    Bar.Icon:SetSize(Height - 2, Height - 2)
    Bar.StatusBar:SetStatusBarTexture(Private.LSM:Fetch("statusbar", DB.Texture))
    Bar.StatusBar:SetStatusBarColor(unpack(DB.ForegroundColour))

    for _, TextType in ipairs({ "CastName", "CastTime" }) do
        local Text = Bar[TextType]
        local TextDB = DB.Text[TextType]
        Text:ClearAllPoints()
        Text:SetPoint(TextDB.Layout[1], Bar.StatusBar, TextDB.Layout[2], TextDB.Layout[3], TextDB.Layout[4])
        Text:SetFont(Private.LSM:Fetch("font", DB.Text.Font[1]), DB.Text.Font[2], DB.Text.Font[3])
        Text:SetTextColor(unpack(TextDB.Colour))
    end

    -- Reserve a fixed time column; measuring live cast text can return a secret width.
    local TimeWidth = math.min(Width - Height - 8, DB.Text.Font[2] * 4)
    Bar.CastTime:SetWidth(TimeWidth)
    Bar.CastName:SetWidth(math.max(1, Width - Height - TimeWidth - 12))
end

local function LayoutBars(Frame)
    local DB = Private.DB.global.TargetedSpells
    local GrowUp = DB.GrowthDirection == "UP"
    local Direction = GrowUp and GridLayoutMixin.Direction.BottomLeftToTopRightVertical or GridLayoutMixin.Direction.TopLeftToBottomRightVertical
    local Point = GrowUp and "BOTTOMLEFT" or "TOPLEFT"
    local Anchor = AnchorUtil.CreateAnchor(Point, Frame, Point, 0, 0)
    local Layout = AnchorUtil.CreateGridLayout(Direction, math.max(#Frame.Bars, 1), 0, DB.Layout[5])
    AnchorUtil.GridLayout(Frame.Bars, Anchor, Layout)
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

    Bar.Icon = Bar.Display:CreateTexture(nil, "ARTWORK")
    Bar.Icon:SetPoint("TOPLEFT", Bar, "TOPLEFT", 1, -1)
    Bar.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    Bar.StatusBar = CreateFrame("StatusBar", nil, Bar.Display)
    Bar.StatusBar:EnableMouse(false)
    Bar.StatusBar:SetPoint("TOPLEFT", Bar.Icon, "TOPRIGHT", 1, 0)
    Bar.StatusBar:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT", -1, 1)

    Bar.CastName = Bar.StatusBar:CreateFontString(nil, "OVERLAY")
    Bar.CastName:SetJustifyH("LEFT")
    Bar.CastName:SetWordWrap(false)
    Bar.CastTime = Bar.StatusBar:CreateFontString(nil, "OVERLAY")
    Bar.CastTime:SetJustifyH("RIGHT")
    Bar.CastTime:SetWordWrap(false)

    Bar.TimeBinding = C_DurationUtil.CreateDurationTextBinding()
    Bar.TimeBinding:SetFontString(Bar.CastTime)
    Bar.TimeBinding:SetFormatter(Frame.TimeFormatter)
    Bar.TimeBinding:SetEnabled(false)
    LayoutBar(Bar)
    return Bar
end

local function ShowBar(Frame, Index, Unit, Name, Icon, Duration, Direction, TargetsPlayer)
    local Bar = Frame.Bars[Index]
    if not Bar then
        Bar = CreateBar(Frame)
        Frame.Bars[Index] = Bar
    end

    Bar.Unit = Unit
    local Parent, MaskCount = Bar, 0
    if Unit then
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
    Bar.CastName:SetText(Name)
    Bar.Icon:SetTexture(Icon)
    Bar.StatusBar:SetTimerDuration(Duration, Enum.StatusBarInterpolation.Immediate, Direction)
    Bar.TimeBinding:SetDuration(Duration)
    Bar.TimeBinding:SetEnabled(true)
    Bar:SetAlphaFromBoolean(TargetsPlayer, 1, 0)
    Bar:Show()
end

local function RefreshCasts()
    local Frame = Private.TargetedSpellsFrame
    Frame.RefreshPending = nil
    if not Private.DB.global.TargetedSpells.Enabled or Private.TargetedSpellsTestMode then return end

    local Count = 0
    for _, Unit in ipairs(Frame.Units) do
        if UnitExists(Unit) and UnitCanAttack("player", Unit) then
            local Name, _, Icon = UnitCastingInfo(Unit)
            local Duration, Direction
            if Name then
                Duration = UnitCastingDuration(Unit)
                Direction = Enum.StatusBarTimerDirection.ElapsedTime
            else
                local IsEmpowered
                Name, _, Icon, _, _, _, _, _, IsEmpowered = UnitChannelInfo(Unit)
                if Name then
                    Duration = IsEmpowered and UnitEmpoweredChannelDuration(Unit) or UnitChannelDuration(Unit)
                    Direction = IsEmpowered and Enum.StatusBarTimerDirection.ElapsedTime or Enum.StatusBarTimerDirection.RemainingTime
                end
            end

            if Duration then
                local Duplicate = false
                for Index = 1, Count do
                    local SameUnit = UnitIsUnit(Unit, Frame.Bars[Index].Unit)
                    Frame.UnitComparisons[Index] = SameUnit
                    if not issecretvalue(SameUnit) and SameUnit then
                        Duplicate = true
                        break
                    end
                end

                if not Duplicate then
                    Count = Count + 1
                    ShowBar(Frame, Count, Unit, Name, Icon, Duration, Direction, PlayerIsSpellTarget(Unit))
                end
            end
        end
    end
    for Index = Count + 1, #Frame.Bars do HideBar(Frame.Bars[Index]) end
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
    if Event == "PLAYER_REGEN_DISABLED" then if Private.TargetedSpellsTestMode then Private:SetTargetedSpellsTestMode(false) end return end

    if Private.TargetedSpellsTestMode then return end

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
    local Frame = Private.TargetedSpellsFrame
    local Samples = {
        { "Fireball", 135812, 8, Enum.StatusBarTimerDirection.ElapsedTime },
        { "Shadow Bolt", 136197, 4, Enum.StatusBarTimerDirection.ElapsedTime },
        { "Penance", 237545, 6, Enum.StatusBarTimerDirection.RemainingTime },
    }
    for Index, Sample in ipairs(Samples) do
        local Duration = C_DurationUtil.CreateDuration()
        Duration:SetTimeFromStart(GetTime(), Sample[3])
        ShowBar(Frame, Index, nil, Sample[1], Sample[2], Duration, Sample[4], true)
    end
    for Index = #Samples + 1, #Frame.Bars do HideBar(Frame.Bars[Index]) end
    LayoutBars(Frame)
end

function Private:SetTargetedSpellsTestMode(Enabled)
    if Enabled and (not Private.DB.global.TargetedSpells.Enabled or InCombatLockdown()) then return end
    Private.TargetedSpellsTestMode = Enabled
    Private:UpdateTargetedSpells()
    Private.ACR:NotifyChange("ElvUI")
end

function Private:SetupTargetedSpells()
    if not Private.TargetedSpellsFrame then
        local Frame = CreateFrame("Frame", nil, UIParent)
        Frame:EnableMouse(false)
        Frame:SetFrameStrata("HIGH")
        Frame.Bars = {}
        Frame.Units = {}
        Frame.KnownUnits = {}
        Frame.UnitComparisons = {}
        Frame.TimeFormatter = C_StringUtil.CreateNumericRuleFormatter()
        Frame.TimeFormatter:SetBreakpoints({
            { threshold = 0, format = "%.1f", step = 0.1, rounding = Enum.NumericRuleFormatRounding.Up },
            { threshold = 5, format = "%.0f", step = 1, rounding = Enum.NumericRuleFormatRounding.Up },
        })
        Frame:SetScript("OnEvent", OnEvent)
        Private.TargetedSpellsFrame = Frame
    end

    Private:UpdateTargetedSpells()
end

function Private:UpdateTargetedSpells()
    local DB = Private.DB.global.TargetedSpells
    local Frame = Private.TargetedSpellsFrame
    if not Frame then Private:SetupTargetedSpells() return end

    Frame:UnregisterAllEvents()
    if Frame.TestTimer then Frame.TestTimer:Cancel() Frame.TestTimer = nil end
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(DB.Size[1], DB.Size[2])

    for _, Bar in ipairs(Frame.Bars) do
        HideBar(Bar)
        LayoutBar(Bar)
    end

    if not DB.Enabled then
        Private.TargetedSpellsTestMode = false
        wipe(Frame.Units)
        wipe(Frame.KnownUnits)
        Frame:Hide()
        return
    end

    Frame:Show()
    Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    if Private.TargetedSpellsTestMode and not InCombatLockdown() then ShowTestCasts() Frame.TestTimer = C_Timer.NewTicker(8, ShowTestCasts) return end

    Private.TargetedSpellsTestMode = false
    for _, Event in ipairs(CastEvents) do Frame:RegisterEvent(Event) end
    for _, Event in ipairs(UnitEvents) do Frame:RegisterEvent(Event) end
    Frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    Frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    ScanUnits(Frame)
    QueueRefresh(Frame)
end
