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

local function HideIcon(Icon)
    Icon.Unit = nil
    Icon:Hide()
    Icon.Cooldown:Clear()
end

local function LayoutIcon(Icon)
    local DB = Private.DB.global.TargetedSpells
    Icon:SetSize(DB.Size[1], DB.Size[2])
end

local function LayoutIcons(Frame)
    local DB = Private.DB.global.TargetedSpells
    local GrowLeft = DB.GrowthDirection == "LEFT"
    local Direction = GrowLeft and GridLayoutMixin.Direction.RightToLeft or GridLayoutMixin.Direction.LeftToRight
    local Point = GrowLeft and "TOPRIGHT" or "TOPLEFT"
    local Anchor = AnchorUtil.CreateAnchor(Point, Frame, Point, 0, 0)
    local Layout = AnchorUtil.CreateGridLayout(Direction, math.max(#Frame.Icons, 1), DB.Layout[5], 0)
    AnchorUtil.GridLayout(Frame.Icons, Anchor, Layout)
end

local function CreateIcon(Frame)
    local Icon = CreateFrame("Frame", nil, Frame)
    Icon:EnableMouse(false)
    Icon.Masks = {}
    Icon.Display = CreateFrame("Frame", nil, Icon, "BackdropTemplate")
    Icon.Display:EnableMouse(false)
    Icon.Display:SetAllPoints(Icon)
    Icon.Display:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    Icon.Display:SetBackdropBorderColor(0, 0, 0, 1)
    Icon.Display:SetBackdropColor(20/255, 20/255, 20/255, 1)

    Icon.Texture = Icon.Display:CreateTexture(nil, "ARTWORK")
    Icon.Texture:SetPoint("TOPLEFT", Icon, "TOPLEFT", 1, -1)
    Icon.Texture:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", -1, 1)
    Icon.Texture:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    Icon.Cooldown = CreateFrame("Cooldown", nil, Icon.Display, "CooldownFrameTemplate")
    Icon.Cooldown:EnableMouse(false)
    Icon.Cooldown:SetAllPoints(Icon.Texture)
    Icon.Cooldown:SetDrawSwipe(true)
    Icon.Cooldown:SetDrawEdge(false)
    Icon.Cooldown:SetDrawBling(false)
    Icon.Cooldown:SetHideCountdownNumbers(false)
    Private.E:RegisterCooldown(Icon.Cooldown)

    LayoutIcon(Icon)
    return Icon
end

local function ShowIcon(Frame, Index, Unit, Texture, Duration, TargetsPlayer)
    local Icon = Frame.Icons[Index]
    if not Icon then
        Icon = CreateIcon(Frame)
        Frame.Icons[Index] = Icon
    end

    Icon.Unit = Unit
    local Parent, MaskCount = Icon, 0
    if Unit then
        for Previous = 1, Index - 1 do
            local SameUnit = Frame.UnitComparisons[Previous]
            if issecretvalue(SameUnit) then
                MaskCount = MaskCount + 1
                local Mask = Icon.Masks[MaskCount]
                if not Mask then
                    Mask = CreateFrame("Frame", nil, Parent)
                    Mask:EnableMouse(false)
                    Mask:SetAllPoints(Icon)
                    Icon.Masks[MaskCount] = Mask
                end
                Mask:SetAlphaFromBoolean(SameUnit, 0, 1)
                Parent = Mask
            end
        end
    end
    Icon.Display:SetParent(Parent)
    Icon.Texture:SetTexture(Texture)
    Icon.Cooldown:SetCooldownFromDurationObject(Duration)
    Icon:SetAlphaFromBoolean(TargetsPlayer, 1, 0)
    Icon:Show()
end

local function RefreshCasts()
    local Frame = Private.TargetedSpellsFrame
    local DB = Private.DB.global.TargetedSpells
    Frame.RefreshPending = nil
    if not DB.Enabled or Private.TargetedSpellsTestMode then return end

    local Count = 0
    for _, Unit in ipairs(Frame.Units) do
        if Count >= DB.MaxIcons then break end
        if UnitExists(Unit) and UnitCanAttack("player", Unit) then
            local Name, _, Texture = UnitCastingInfo(Unit)
            local Duration
            if Name then
                Duration = UnitCastingDuration(Unit)
            else
                local IsEmpowered
                Name, _, Texture, _, _, _, _, _, IsEmpowered = UnitChannelInfo(Unit)
                if Name then
                    Duration = IsEmpowered and UnitEmpoweredChannelDuration(Unit) or UnitChannelDuration(Unit)
                end
            end

            if Duration then
                local Duplicate = false
                for Index = 1, Count do
                    local SameUnit = UnitIsUnit(Unit, Frame.Icons[Index].Unit)
                    Frame.UnitComparisons[Index] = SameUnit
                    if not issecretvalue(SameUnit) and SameUnit then
                        Duplicate = true
                        break
                    end
                end

                if not Duplicate then
                    Count = Count + 1
                    ShowIcon(Frame, Count, Unit, Texture, Duration, PlayerIsSpellTarget(Unit))
                end
            end
        end
    end
    for Index = Count + 1, #Frame.Icons do HideIcon(Frame.Icons[Index]) end
    LayoutIcons(Frame)
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
        { 135812, 8 },
        { 136197, 4 },
        { 237545, 6 },
    }
    local Count = math.min(#Samples, Private.DB.global.TargetedSpells.MaxIcons)
    for Index = 1, Count do
        local Sample = Samples[Index]
        local Duration = C_DurationUtil.CreateDuration()
        Duration:SetTimeFromStart(GetTime(), Sample[2])
        ShowIcon(Frame, Index, nil, Sample[1], Duration, true)
    end
    for Index = Count + 1, #Frame.Icons do HideIcon(Frame.Icons[Index]) end
    LayoutIcons(Frame)
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
        Frame.Icons = {}
        Frame.Units = {}
        Frame.KnownUnits = {}
        Frame.UnitComparisons = {}
        Frame:SetScript("OnEvent", OnEvent)
        Private.TargetedSpellsFrame = Frame
    end

    Private:UpdateTargetedSpells()
end

function Private:UpdateTargetedSpells()
    local DB = Private.DB.global.TargetedSpells
    if DB.GrowthDirection == "UP" then DB.GrowthDirection = "LEFT" elseif DB.GrowthDirection == "DOWN" then DB.GrowthDirection = "RIGHT" end
    local Frame = Private.TargetedSpellsFrame
    if not Frame then Private:SetupTargetedSpells() return end

    Frame:UnregisterAllEvents()
    if Frame.TestTimer then Frame.TestTimer:Cancel() Frame.TestTimer = nil end
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(DB.Size[1], DB.Size[2])

    for _, Icon in ipairs(Frame.Icons) do
        HideIcon(Icon)
        LayoutIcon(Icon)
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
