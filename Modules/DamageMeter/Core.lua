local Private = select(2, ...)

function Private:SetDamageMeterTestMode(value)
    Private.DamageMeterTestMode = value or nil

    for _, DMFrame in pairs(Private.DamageMeterFrames) do
        DMFrame.ScrollOffset = 0
    end

    if Private.DamageMeterDrilldown then Private.DamageMeterDrilldown:Hide() end
    Private:UpdateDamageMeter()
end

function Private:SetDamageMeterType(DMFrame, MeterType, SessionType)
    if DMFrame.DB.MeterType ~= MeterType or (SessionType and (DMFrame.SessionType ~= SessionType or DMFrame.EncounterSegment)) then DMFrame.ScrollOffset = 0 end
    if SessionType then DMFrame.EncounterSegment = nil end
    DMFrame.DB.MeterType = MeterType
    DMFrame.SessionType = SessionType or DMFrame.SessionType
    DMFrame.DB.SessionType = DMFrame.SessionType
    DMFrame.Title:SetFormattedText("%s %s", Private.MeterTypes[MeterType], (DMFrame.SessionType == Enum.DamageMeterSessionType.Current and "" or "Overall"))
    Private:PopulateDamageMeterBars(DMFrame, DMFrame.DB)
end

function Private:SetEncounter(encounterSegment)
    if Private.DamageMeterDrilldown then Private.DamageMeterDrilldown:Hide() end

    for _, DMFrame in pairs(Private.DamageMeterFrames) do
        DMFrame.EncounterSegment = encounterSegment
        DMFrame.ScrollOffset = 0
        Private:SetDamageMeterType(DMFrame, DMFrame.DB.MeterType, not encounterSegment and Enum.DamageMeterSessionType.Current or nil)
    end
end

function Private:SetupDamageMeter()
    Private.DamageMeterFrames = {}
    Private.DamageMeterEventFrame = CreateFrame("Frame")
    Private.DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
    Private.DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
    Private.DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_RESET")
    Private.DamageMeterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    Private.DamageMeterEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    Private.DamageMeterEventFrame:RegisterEvent("PLAYER_LOGOUT")
    Private.DamageMeterEventFrame:SetScript("OnEvent", function(_, event, meterType, sessionID)
        if event == "DAMAGE_METER_RESET" and Private.DamageMeterDrilldown then Private.DamageMeterDrilldown:Hide() end
        for IDX, DB in pairs(Private.DB.global.DamageMeter) do
            local DMFrame = Private.DamageMeterFrames[IDX]
            if DMFrame and event == "DAMAGE_METER_RESET" then
                DMFrame.EncounterSegment = nil
                DMFrame.ScrollOffset = 0
                Private:SetDamageMeterType(DMFrame, DB.MeterType)
            elseif DB.Enabled and DMFrame and (event ~= "DAMAGE_METER_COMBAT_SESSION_UPDATED" or (DB.MeterType == meterType and sessionID == (DMFrame.EncounterSegment and DMFrame.EncounterSegment.sessionID or 0))) then
                Private:PopulateDamageMeterBars(DMFrame, DB)
            end
        end
    end)

    Private:UpdateDamageMeter()
end

function Private:UpdateDamageMeter()
    local DamageMeterDB = Private.DB.global.DamageMeter
    if not Private.DamageMeterEventFrame then Private:SetupDamageMeter() return end

    for IDX, DB in pairs(DamageMeterDB) do
        if DB.Enabled then
            if not Private.DamageMeterFrames[IDX] then
                Private.DamageMeterFrames[IDX] = Private:CreateDamageMeter("DamageMeterFrame" .. IDX, DB)
            else
                Private:LayoutDamageMeter(Private.DamageMeterFrames[IDX], DB)
            end
            Private.DamageMeterFrames[IDX]:Show()
            Private:SetDamageMeterType(Private.DamageMeterFrames[IDX], DB.MeterType)
        elseif Private.DamageMeterFrames[IDX] then
            Private.DamageMeterFrames[IDX]:Hide()
        end
    end
end
