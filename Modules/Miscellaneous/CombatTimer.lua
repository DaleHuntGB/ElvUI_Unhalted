local Private = select(2, ...)

local function CombatTimer_OnUpdate(CTFrame, TimeElapsed)
    CTFrame.TimeElapsed = CTFrame.TimeElapsed + TimeElapsed
    local TotalSeconds = math.floor(CTFrame.LastDuration + CTFrame.TimeElapsed)
    if TotalSeconds == CTFrame.ShownSeconds then return end
    CTFrame.ShownSeconds = TotalSeconds
    CTFrame.Text:SetFormattedText((Private.DB.global.Miscellaneous.CombatTimer.Text.Format == "00:00" and "%02d:%02d") or "%d:%02d", math.floor(TotalSeconds / 60), TotalSeconds % 60)
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
    local DB = Private.DB.global.Miscellaneous.CombatTimer

    local CombatTimerFrame = CreateFrame("Frame", "CombatTimerFrame", UIParent)
    CombatTimerFrame:SetSize(1, 1)
    CombatTimerFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    CombatTimerFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
    CombatTimerFrame:SetShown(DB.Enable)

    CombatTimerFrame.TimeElapsed = 0;
    CombatTimerFrame.LastDuration = 0;
    CombatTimerFrame.ShownSeconds = 0
    CombatTimerFrame.InCombat = InCombatLockdown()
    CombatTimerFrame.InEncounter = false

    CombatTimerFrame.Text = CombatTimerFrame:CreateFontString(nil, "OVERLAY")
    Private.E:SetFont(CombatTimerFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
    CombatTimerFrame.Text:SetPoint(DB.Layout[1], CombatTimerFrame, DB.Layout[1], 0, 0)
    CombatTimerFrame.Text:SetText(DB.Text.Format == "00:00" and "00:00" or "0:00")
    CombatTimerFrame.Text:SetJustifyH(Private.JustificationH[DB.Layout[1]])
    CombatTimerFrame.Text:SetTextColor(DB.Text.Colour[1], DB.Text.Colour[2], DB.Text.Colour[3])
    CombatTimerFrame:SetSize(CombatTimerFrame.Text:GetStringWidth(), CombatTimerFrame.Text:GetStringHeight())

    Private.CombatTimerFrame = CombatTimerFrame

    CombatTimerFrame.StartCombatTimer = function(CTFrame)
        if CTFrame.CombatStartTime then return end
        CTFrame.CombatStartTime = GetTime()
        CTFrame.TimeElapsed = 0
        CTFrame.LastDuration = 0
        CTFrame.ShownSeconds = 0
        CTFrame.Text:SetText(string.format((DB.Text.Format == "00:00" and "%02d:%02d") or "%d:%02d", 0, 0))
        CTFrame:SetSize(CTFrame.Text:GetStringWidth(), CTFrame.Text:GetStringHeight())
        CTFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
        CTFrame:SetScript("OnUpdate", CombatTimer_OnUpdate)
    end

    CombatTimerFrame.StopCombatTimer = function(CTFrame)
        if CTFrame.CombatStartTime then CTFrame.LastDuration = GetTime() - CTFrame.CombatStartTime end
        CTFrame:SetScript("OnUpdate", nil)
        CTFrame.CombatStartTime = nil
        CTFrame.TimeElapsed = 0
        CTFrame.Text:SetText(string.format((DB.Text.Format == "00:00" and "%02d:%02d") or "%d:%02d", math.floor(CTFrame.LastDuration / 60), math.floor(CTFrame.LastDuration % 60)))
        CTFrame:SetSize(CTFrame.Text:GetStringWidth(), CTFrame.Text:GetStringHeight())
        CTFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
    end

    if DB.Enable then
        CombatTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        CombatTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        CombatTimerFrame:RegisterEvent("ENCOUNTER_START")
        CombatTimerFrame:RegisterEvent("ENCOUNTER_END")
        CombatTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        CombatTimerFrame:SetScript("OnEvent", CombatTimer_OnEvent)
    end
end

function Private:UpdateCombatTimer()
    local DB = Private.DB.global.Miscellaneous.CombatTimer

    if Private.CombatTimerFrame then
        Private.E:SetFont(Private.CombatTimerFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
        Private.CombatTimerFrame.Text:SetText(DB.Text.Format == "00:00" and "00:00" or "0:00")
        Private.CombatTimerFrame.Text:SetTextColor(DB.Text.Colour[1], DB.Text.Colour[2], DB.Text.Colour[3])
        Private.CombatTimerFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OOCOpacity)
        Private.CombatTimerFrame:ClearAllPoints()
        Private.CombatTimerFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    if DB.Enable then
        Private.CombatTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatTimerFrame:RegisterEvent("ENCOUNTER_START")
        Private.CombatTimerFrame:RegisterEvent("ENCOUNTER_END")
        Private.CombatTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.CombatTimerFrame:SetScript("OnEvent", CombatTimer_OnEvent)
        Private.CombatTimerFrame.TimeElapsed = 0;
        Private.CombatTimerFrame.LastDuration = 0;
        Private.CombatTimerFrame.InCombat = InCombatLockdown()
        Private.CombatTimerFrame.InEncounter = false

    else
        Private.CombatTimerFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatTimerFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatTimerFrame:UnregisterEvent("ENCOUNTER_START")
        Private.CombatTimerFrame:UnregisterEvent("ENCOUNTER_END")
        Private.CombatTimerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Private.CombatTimerFrame:SetScript("OnEvent", nil)
        Private.CombatTimerFrame:SetScript("OnUpdate", nil)
    end

    Private.CombatTimerFrame:SetShown(DB.Enable)
end