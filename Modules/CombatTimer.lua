local Private = select(2, ...)

local function CombatTimer_OnUpdate(CTFrame, TimeElapsed)
    CTFrame.TimeElapsed = CTFrame.TimeElapsed + TimeElapsed
    local TotalDuration = CTFrame.LastDuration + CTFrame.TimeElapsed
    local Minutes = math.floor(TotalDuration / 60)
    local Seconds = math.floor(TotalDuration % 60)
    CTFrame.Text:SetText(string.format((Private.DB.global.CombatTimer.Text.Format == "00:00" and "%02d:%02d") or "%d:%02d", Minutes, Seconds))
    CTFrame:SetSize(CTFrame.Text:GetStringWidth(), CTFrame.Text:GetStringHeight())
end

local function CombatTimer_OnEvent(CTFrame, Event, ...)
    if Event == "PLAYER_REGEN_DISABLED" then
        CTFrame.InCombat = true
        CTFrame:StartCombatTimer()
    elseif Event == "PLAYER_REGEN_ENABLED" then
        CTFrame.InCombat = false
        if not CTFrame.InEncounter then CTFrame:StopCombatTimer() end
    elseif Event == "ENCOUNTER_START" then
        CTFrame.InEncounter = true
        CTFrame:StartCombatTimer()
    elseif Event == "ENCOUNTER_END" then
        CTFrame.InEncounter = false
        if not CTFrame.InCombat then CTFrame:StopCombatTimer() end
    elseif Event == "PLAYER_ENTERING_WORLD" then
        Private:UpdateCombatTimer()
    end
end

function Private:SetupCombatTimer()
    local DB = Private.DB.global.CombatTimer

    local CombatTimerFrame = CreateFrame("Frame", "CombatTimerFrame", UIParent)
    CombatTimerFrame.TimeElapsed = 0
    CombatTimerFrame.LastDuration = 0
    CombatTimerFrame.InCombat = false
    CombatTimerFrame.InEncounter = false

    CombatTimerFrame.Text = CombatTimerFrame:CreateFontString(nil, "OVERLAY")

    Private.CombatTimerFrame = CombatTimerFrame

    C_Timer.NewTicker(0.1, function() Private.CombatTimerFrame:ClearAllPoints() Private.CombatTimerFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4]) end, 3)

    CombatTimerFrame.StartCombatTimer = function(CTFrame)
        if CTFrame.CombatStartTime then return end
        CTFrame.CombatStartTime = GetTime()
        CTFrame.TimeElapsed = 0
        CTFrame.LastDuration = 0
        CombatTimer_OnUpdate(CTFrame, 0)
        CTFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
        CTFrame:SetScript("OnUpdate", CombatTimer_OnUpdate)
    end

    CombatTimerFrame.StopCombatTimer = function(CTFrame)
        if CTFrame.CombatStartTime then CTFrame.LastDuration = GetTime() - CTFrame.CombatStartTime end
        CTFrame:SetScript("OnUpdate", nil)
        CTFrame.CombatStartTime = nil
        CTFrame.TimeElapsed = 0
        CombatTimer_OnUpdate(CTFrame, 0)
        CTFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
    end

    Private:UpdateCombatTimer()
end

function Private:UpdateCombatTimer()
    local DB = Private.DB.global.CombatTimer
    local CTFrame = Private.CombatTimerFrame
    if not CTFrame then return end

    CTFrame.Text:SetFont(Private:FetchFont(DB.Text.Font), DB.Text.FontSize, DB.Text.FontFlag)
    CTFrame.Text:SetTextColor(DB.Text.Colour[1], DB.Text.Colour[2], DB.Text.Colour[3])
    CTFrame.Text:ClearAllPoints()
    CTFrame.Text:SetPoint(DB.Layout[1], CTFrame, DB.Layout[1], 0, 0)
    CTFrame.Text:SetJustifyH(Private.JustificationH[DB.Layout[1]])
    CTFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
    CTFrame:ClearAllPoints()
    CTFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    if DB.Enable then
        CTFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        CTFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        CTFrame:RegisterEvent("ENCOUNTER_START")
        CTFrame:RegisterEvent("ENCOUNTER_END")
        CTFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        CTFrame:SetScript("OnEvent", CombatTimer_OnEvent)
        CTFrame.InCombat = InCombatLockdown()
        CTFrame.InEncounter = C_InstanceEncounter.IsEncounterInProgress()
        if CTFrame.InCombat or CTFrame.InEncounter then
            CTFrame:StartCombatTimer()
        elseif CTFrame.CombatStartTime then
            CTFrame:StopCombatTimer()
        end
    else
        CTFrame:UnregisterAllEvents()
        CTFrame:SetScript("OnEvent", nil)
        CTFrame:StopCombatTimer()
        CTFrame.InCombat = false
        CTFrame.InEncounter = false
    end

    CombatTimer_OnUpdate(CTFrame, 0)
    CTFrame:SetShown(DB.Enable)
end
