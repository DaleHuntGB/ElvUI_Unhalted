local Private = select(2, ...)

-- Seconds a flight master may take to answer. A loss of control later than this is not the flight taking off.
local RequestTimeout = 5

local TaxiNodeBySlot, RouteNodes = {}, {}
local State = {
    Route = "", Name = "", Seconds = 0, RequestTime = 0, StartTime = 0, Remaining = -1,
    isEnabled = false, isEstimate = false,
}

local function StopFlight()
    State.StartTime = 0
    Private.NavigationFlightTimer:Hide()
end

-- Reads the hops of the flight being asked for while the flight master's map is still open.
-- A route flown before uses the time it took; a new one adds up Data.lua's estimate for each hop.
local function FlightTimer_OnTakeTaxiNode(Slot)
    State.RequestTime = 0
    if not State.isEnabled then return end

    wipe(TaxiNodeBySlot)
    for _, TaxiNode in ipairs(C_TaxiMap.GetAllTaxiNodes(GetTaxiMapID())) do
        TaxiNodeBySlot[TaxiNode.slotIndex] = TaxiNode.nodeID
    end

    local Estimate = 0
    wipe(RouteNodes)
    for Hop = 1, GetNumRoutes(Slot) do
        local From, To = TaxiNodeBySlot[TaxiGetNodeSlot(Slot, Hop, true)], TaxiNodeBySlot[TaxiGetNodeSlot(Slot, Hop, false)]
        if not From or not To then return end
        local HopSeconds = Private.NavigationTaxiPaths[From] and Private.NavigationTaxiPaths[From][To]
        Estimate = Estimate and HopSeconds and Estimate + HopSeconds
        RouteNodes[Hop], RouteNodes[Hop + 1] = From, To
    end
    if #RouteNodes == 0 then return end

    local Route = table.concat(RouteNodes, ":")
    local Measured = Private.DB.faction.Navigation.FlightTimes[Route]
    State.Route, State.Name = Route, TaxiNodeName(Slot):match("^[^,]+")
    State.Seconds, State.isEstimate = Measured or Estimate or 0, not Measured
    State.RequestTime = GetTime()
end

local function FlightTimer_OnUpdate(FlightTimer)
    local Remaining = math.max(0, math.ceil(State.StartTime + State.Seconds - GetTime()))
    if Remaining == State.Remaining then return end
    State.Remaining = Remaining
    FlightTimer.Time:SetFormattedText(State.isEstimate and "~%d:%02d" or "%d:%02d", math.floor(Remaining / 60), Remaining % 60)
end

local function FlightTimer_OnEvent(FlightTimer, Event)
    if Event == "PLAYER_CONTROL_LOST" then
        if GetTime() - State.RequestTime > RequestTimeout then return end
        State.RequestTime, State.StartTime, State.Remaining = 0, GetTime(), -1
        -- A route with no time yet is flown without a countdown, and has one from then on.
        if State.Seconds > 0 then
            FlightTimer.Name:SetText(State.Name)
            FlightTimer_OnUpdate(FlightTimer)
            FlightTimer:Show()
        end
        return
    end

    if State.StartTime == 0 then return end
    Private.DB.faction.Navigation.FlightTimes[State.Route] = math.floor(GetTime() - State.StartTime + 0.5)
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

-- Sits where the arrow does, which is hidden for the length of a flight.
function Private:CreateNavigationFlightTimer()
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
    -- An early landing ends the flight at the next flight master, so its time is neither shown nor kept.
    hooksecurefunc("TakeTaxiNode", FlightTimer_OnTakeTaxiNode)
    hooksecurefunc("TaxiRequestEarlyLanding", StopFlight)

    Private.NavigationFlightTimer = FlightTimer
end
