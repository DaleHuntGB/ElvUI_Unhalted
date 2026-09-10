local Private = select(2, ...)

local function CombatTimer_OnUpdate(combatTimerFrame, timeElapsed)
    combatTimerFrame.TimeElapsed = combatTimerFrame.TimeElapsed + timeElapsed
    if combatTimerFrame.TimeElapsed < 1 then return end

    combatTimerFrame.LastDuration = GetTime() - combatTimerFrame.CombatStartTime
    combatTimerFrame.Text:SetText(string.format("%02d:%02d", math.floor(combatTimerFrame.LastDuration / 60), math.floor(combatTimerFrame.LastDuration % 60)))
    combatTimerFrame:SetSize(math.max(1, combatTimerFrame.Text:GetStringWidth()), math.max(1, combatTimerFrame.Text:GetStringHeight()))
    combatTimerFrame.TimeElapsed = 0
end

function Private:SetupCombatTimer()
    local DB = Private.DB.global.CombatTimer

    if not Private.CombatTimerFrame then
        local CombatTimerFrame = CreateFrame("Frame", nil, UIParent)
        CombatTimerFrame:SetSize(1, 1)
        CombatTimerFrame:SetFrameStrata("HIGH")
        CombatTimerFrame:EnableMouse(false)
        CombatTimerFrame.TimeElapsed = 0
        CombatTimerFrame.LastDuration = 0
        CombatTimerFrame.InCombat = InCombatLockdown()
        CombatTimerFrame.InEncounter = false

        CombatTimerFrame:SetPoint(DB.Layout[1], _G["ElvUF_Player"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        CombatTimerFrame:SetAlphaFromBoolean(UnitAffectingCombat("player"), 1, DB.OutOfCombatAlpha)

        CombatTimerFrame.Text = CombatTimerFrame:CreateFontString(nil, "OVERLAY")
        CombatTimerFrame.Text:SetPoint("CENTER", CombatTimerFrame, "CENTER", 0, 0)
        CombatTimerFrame.Text:SetJustifyH("CENTER")
        CombatTimerFrame.Text:SetFont(Private.LSM:Fetch("font", DB.Font[1]), DB.Font[2], DB.Font[3])
        CombatTimerFrame.Text:SetTextColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])
        CombatTimerFrame.Text:SetText(string.format("%02d:%02d", 0, 0))

        CombatTimerFrame.StartTimer = function(combatTimerFrame)
            if combatTimerFrame.CombatStartTime then return end

            combatTimerFrame.CombatStartTime = GetTime()
            combatTimerFrame.TimeElapsed = 0
            combatTimerFrame.LastDuration = 0
            combatTimerFrame.Text:SetText(string.format("%02d:%02d", 0, 0))
            combatTimerFrame:SetSize(math.max(1, combatTimerFrame.Text:GetStringWidth()), math.max(1, combatTimerFrame.Text:GetStringHeight()))
            combatTimerFrame:SetAlpha(1)
            combatTimerFrame:Show()
            combatTimerFrame:SetScript("OnUpdate", CombatTimer_OnUpdate)
        end

        CombatTimerFrame.StopTimer = function(combatTimerFrame)
            if combatTimerFrame.CombatStartTime then
                combatTimerFrame.LastDuration = GetTime() - combatTimerFrame.CombatStartTime
            end

            combatTimerFrame:SetScript("OnUpdate", nil)
            combatTimerFrame.CombatStartTime = nil
            combatTimerFrame.TimeElapsed = 0
            combatTimerFrame.Text:SetText(string.format("%02d:%02d", math.floor(combatTimerFrame.LastDuration / 60), math.floor(combatTimerFrame.LastDuration % 60)))
            combatTimerFrame:SetSize(math.max(1, combatTimerFrame.Text:GetStringWidth()), math.max(1, combatTimerFrame.Text:GetStringHeight()))
            combatTimerFrame:SetAlpha(DB.OutOfCombatAlpha)
            combatTimerFrame:Show()
        end

        CombatTimerFrame:SetScript("OnEvent", function(combatTimerFrame, event)
            if event == "PLAYER_REGEN_DISABLED" then
                combatTimerFrame.InCombat = true
                combatTimerFrame:StartTimer()
            elseif event == "PLAYER_REGEN_ENABLED" then
                combatTimerFrame.InCombat = false
                if not combatTimerFrame.InEncounter then combatTimerFrame:StopTimer() end
            elseif event == "ENCOUNTER_START" then
                combatTimerFrame.InEncounter = true
                combatTimerFrame:StartTimer()
            elseif event == "ENCOUNTER_END" then
                combatTimerFrame.InEncounter = false
                if not combatTimerFrame.InCombat then combatTimerFrame:StopTimer() end
            elseif event == "PLAYER_ENTERING_WORLD" then
                combatTimerFrame:ClearAllPoints()
                combatTimerFrame:SetPoint(DB.Layout[1], _G["ElvUF_Player"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
            end
        end)

        Private.CombatTimerFrame = CombatTimerFrame
    end

    Private:UpdateCombatTimer()
end

function Private:UpdateCombatTimer()
    local DB = Private.DB.global.CombatTimer
    local CombatTimerFrame = Private.CombatTimerFrame
    if not CombatTimerFrame then Private:SetupCombatTimer() return end

    CombatTimerFrame:UnregisterAllEvents()
    CombatTimerFrame:ClearAllPoints()
    CombatTimerFrame:SetPoint(DB.Layout[1], _G["ElvUF_Player"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    if DB.Enabled then
        CombatTimerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        CombatTimerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        CombatTimerFrame:RegisterEvent("ENCOUNTER_START")
        CombatTimerFrame:RegisterEvent("ENCOUNTER_END")
        CombatTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

        CombatTimerFrame.Text:SetPoint("CENTER", CombatTimerFrame, "CENTER", 0, 0)
        CombatTimerFrame.Text:SetJustifyH("CENTER")
        CombatTimerFrame.Text:SetFont(Private.LSM:Fetch("font", DB.Font[1]), DB.Font[2], DB.Font[3])
        CombatTimerFrame.Text:SetTextColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])
        CombatTimerFrame.Text:SetText(string.format("%02d:%02d", 0, 0))

        if InCombatLockdown() and not CombatTimerFrame.CombatStartTime then CombatTimerFrame.InCombat = true CombatTimerFrame:StartTimer() end
        CombatTimerFrame:SetAlpha(CombatTimerFrame.CombatStartTime and 1 or DB.OutOfCombatAlpha)
        CombatTimerFrame:Show()
    else
        if CombatTimerFrame.CombatStartTime then CombatTimerFrame.LastDuration = GetTime() - CombatTimerFrame.CombatStartTime end
        CombatTimerFrame:SetScript("OnUpdate", nil)
        CombatTimerFrame.CombatStartTime = nil
        CombatTimerFrame.InCombat = false
        CombatTimerFrame.InEncounter = false
        CombatTimerFrame.Text:SetText("")
        CombatTimerFrame:Hide()
        return
    end

    CombatTimerFrame:SetSize(math.max(1, CombatTimerFrame.Text:GetStringWidth()), math.max(1, CombatTimerFrame.Text:GetStringHeight()))
end
