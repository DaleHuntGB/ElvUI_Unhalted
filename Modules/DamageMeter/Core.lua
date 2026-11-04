local Private = select(2, ...)

Private.DamageMeterEventFrames = {}
Private.DamageMeterEventFrame = CreateFrame("Frame")

local function DamageMeter_OnEvent(_, Event, MeterType, SessionID)
    if Event == "CHALLENGE_MODE_START" then C_DamageMeter.ResetAllCombatSessions() return end

    for Frame in pairs(Private.DamageMeterEventFrames) do
        local DB = Frame.DamageMeterDB
        if Event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
            local SelectedSessionID = not Frame.ShowingCombatSessions and Frame.SessionID
            if not Frame.ShowingBookmarks and MeterType == DB.MeterType and (SelectedSessionID == SessionID or (not SelectedSessionID and SessionID == 0)) then
                Frame:RefreshData()
            end
        elseif Event == "DAMAGE_METER_CURRENT_SESSION_UPDATED" then
            if not Frame.SessionID and DB.SessionType == Enum.DamageMeterSessionType.Current then
                Frame:RefreshData(true)
            elseif Frame.ShowingCombatSessions or Frame.SessionID then
                Frame:RefreshData()
            end
        elseif Event == "DAMAGE_METER_RESET" then
            Frame.SessionID = nil
            Frame.SessionName = nil
            Frame:RefreshData(true)
        elseif Event == "PLAYER_REGEN_ENABLED" then
            Frame:RefreshData()
        end
    end
end

Private.DamageMeterEventFrame:SetScript("OnEvent", DamageMeter_OnEvent)

function Private:UpdateDamageMeterEvents(Frame)
    if Frame.DamageMeterDB.Enable then
        if not next(Private.DamageMeterEventFrames) then
            Private.DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
            Private.DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_CURRENT_SESSION_UPDATED")
            Private.DamageMeterEventFrame:RegisterEvent("DAMAGE_METER_RESET")
            Private.DamageMeterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
            Private.DamageMeterEventFrame:RegisterEvent("CHALLENGE_MODE_START")
        end
        Private.DamageMeterEventFrames[Frame] = true
    else
        Private.DamageMeterEventFrames[Frame] = nil
        if not next(Private.DamageMeterEventFrames) then
            Private.DamageMeterEventFrame:UnregisterAllEvents()
        end
    end
end

function Private:SetupDamageMeters()
    for i in pairs(Private.DB.global.DamageMeter) do
        local DB = Private.DB.global.DamageMeter[i]
        if DB.Enable then
            Private:CreateWindow(DB, i)
        end
    end
end

function Private:UpdateDamageMeters()
    for i in pairs(Private.DB.global.DamageMeter) do
        local DB = Private.DB.global.DamageMeter[i]
        local Frame = _G["DamageMeter_0"..i]
        if Frame then
            Private:UpdateWindow(Frame, DB)
        elseif DB.Enable then
            Private:CreateWindow(DB, i)
        end
    end
end
