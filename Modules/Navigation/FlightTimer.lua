local Private = select(2, ...)

local RequestTimeout = 5

local TaxiNodeBySlot = {}
local State = {
    Name = "", Seconds = 0, RequestTime = 0, StartTime = 0, Remaining = -1,
    isEnabled = false,
}

local function StopFlight()
    State.StartTime = 0
    Private.NavigationFlightTimer:Hide()
end

local function FlightTimer_OnTakeTaxiNode(Slot)
    State.RequestTime = 0
    if not State.isEnabled then return end

    wipe(TaxiNodeBySlot)
    for _, TaxiNode in ipairs(C_TaxiMap.GetAllTaxiNodes(GetTaxiMapID())) do
        TaxiNodeBySlot[TaxiNode.slotIndex] = TaxiNode.nodeID
    end

    local Seconds = 0
    for Hop = 1, GetNumRoutes(Slot) do
        local From, To = TaxiNodeBySlot[TaxiGetNodeSlot(Slot, Hop, true)], TaxiNodeBySlot[TaxiGetNodeSlot(Slot, Hop, false)]
        local HopSeconds = From and To and Private.NavigationTaxiPaths[From] and Private.NavigationTaxiPaths[From][To]
        if not HopSeconds then return end
        Seconds = Seconds + HopSeconds
    end
    if Seconds == 0 then return end

    State.Name, State.Seconds = TaxiNodeName(Slot):match("^[^,]+"), Seconds
    State.RequestTime = GetTime()
end

local function FlightTimer_OnUpdate(FlightTimer)
    local Remaining = math.max(0, math.ceil(State.StartTime + State.Seconds - GetTime()))
    if Remaining == State.Remaining then return end
    State.Remaining = Remaining
    FlightTimer.Time:SetShown(Remaining > 0)
    FlightTimer.Time:SetFormattedText("%d:%02d", math.floor(Remaining / 60), Remaining % 60)
end

local function FlightTimer_OnEvent(FlightTimer, Event)
    if Event == "PLAYER_CONTROL_LOST" then
        if GetTime() - State.RequestTime > RequestTimeout then return end
        State.RequestTime, State.StartTime, State.Remaining = 0, GetTime(), -1
        if State.Seconds > 0 then
            FlightTimer.Name:SetText(State.Name)
            FlightTimer_OnUpdate(FlightTimer)
            FlightTimer:Show()
        end
        return
    end

    if State.StartTime == 0 then return end
    StopFlight()
end

function Private:UpdateNavigationFlightTimer()
    local FlightTimer = Private.NavigationFlightTimer
    local DB = Private.DB.global.Miscellaneous.Navigation
    local Font, FontStyle = Private:FetchFont(Private.E.db.general.font), Private.E.db.general.fontStyle

    Private.E:SetFont(FlightTimer.Name, Font, DB.Text.FontSize, FontStyle)
    Private.E:SetFont(FlightTimer.Time, Font, DB.Text.FontSize, FontStyle)

    State.isEnabled = DB.Enable and DB.FlightTimer
    if State.isEnabled then
        FlightTimer:RegisterEvent("PLAYER_CONTROL_LOST")
        FlightTimer:RegisterEvent("PLAYER_CONTROL_GAINED")
    else
        FlightTimer:UnregisterAllEvents()
        StopFlight()
    end
end

function Private:SetupNavigationFlightTimer()
    local Colour = Private.E.db.general.valuecolor
    local FlightTimer = CreateFrame("Frame", nil, UIParent)
    FlightTimer:SetAllPoints(Private.NavigationArrow)
    FlightTimer:Hide()

    FlightTimer.Name = FlightTimer:CreateFontString(nil, "OVERLAY")
    FlightTimer.Name:SetPoint("BOTTOM", FlightTimer, "CENTER", 0, 1)

    FlightTimer.Time = FlightTimer:CreateFontString(nil, "OVERLAY")
    FlightTimer.Time:SetPoint("TOP", FlightTimer, "CENTER", 0, -1)
    FlightTimer.Time:SetTextColor(Colour.r, Colour.g, Colour.b)

    FlightTimer:SetScript("OnEvent", FlightTimer_OnEvent)
    FlightTimer:SetScript("OnUpdate", FlightTimer_OnUpdate)
    hooksecurefunc("TakeTaxiNode", FlightTimer_OnTakeTaxiNode)
    hooksecurefunc("TaxiRequestEarlyLanding", StopFlight)

    Private.NavigationFlightTimer = FlightTimer
end
