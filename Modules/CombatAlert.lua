local Private = select(2, ...)

local function ShowCombatAlert(Entering)
    local DB = Private.DB.global.CombatAlert
    local Frame = Private.CombatAlertFrame
    local Colour = Entering and DB.EnteringCombatColour or DB.ExitingCombatColour
    if Frame.ClearTimer then Frame.ClearTimer:Cancel() end
    Frame.Text:SetText(Entering and DB.EnteringCombat or DB.ExitingCombat)
    Frame.Text:SetTextColor(unpack(Colour))
    Frame:Show()
    Frame.ClearTimer = C_Timer.NewTimer(DB.HoldTime, function()
        Frame.Text:SetText("")
        Frame:Hide()
        Frame.ClearTimer = nil
    end)
end

local function ShowTestCombatAlert()
    local Frame = Private.CombatAlertFrame
    Frame.TestEntering = not Frame.TestEntering
    ShowCombatAlert(Frame.TestEntering)
end

function Private:SetCombatAlertTestMode(Enabled)
    if Enabled and (not Private.DB.global.CombatAlert.Enabled or InCombatLockdown()) then return end
    Private.CombatAlertTestMode = Enabled
    local Frame = Private.CombatAlertFrame
    if Frame then
        if Frame.ClearTimer then Frame.ClearTimer:Cancel() Frame.ClearTimer = nil end
        Frame.Text:SetText("")
        Frame:Hide()
    end
    Private:UpdateCombatAlert()
    Private.ACR:NotifyChange("ElvUI")
end

function Private:SetupCombatAlert()
    if not Private.CombatAlertFrame then
        local Frame = CreateFrame("Frame", nil, UIParent)
        Frame:SetSize(1, 1)
        Frame:EnableMouse(false)
        Frame.Text = Frame:CreateFontString(nil, "OVERLAY")
        Frame.Text:SetPoint("CENTER", Frame, "CENTER", 0, 0)
        Frame.Text:SetJustifyH("CENTER")
        Frame:SetScript("OnEvent", function(_, Event)
            if Private.CombatAlertTestMode then Private:SetCombatAlertTestMode(false) end
            ShowCombatAlert(Event == "PLAYER_REGEN_DISABLED")
        end)
        Private.CombatAlertFrame = Frame
    end

    Private:UpdateCombatAlert()
end

function Private:UpdateCombatAlert()
    local DB = Private.DB.global.CombatAlert
    local Frame = Private.CombatAlertFrame
    if not Frame then Private:SetupCombatAlert() return end
    if Frame.TestTimer then Frame.TestTimer:Cancel() Frame.TestTimer = nil end

    if not DB.Enabled then
        Private.CombatAlertTestMode = false
        if Frame.ClearTimer then Frame.ClearTimer:Cancel() Frame.ClearTimer = nil end
        Frame:UnregisterAllEvents()
        Frame.Text:SetText("")
        Frame:Hide()
        return
    end

    Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    Frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame.Text:SetFont(Private.LSM:Fetch("font", DB.Font[1]), DB.Font[2], DB.Font[3])

    if Private.CombatAlertTestMode and not InCombatLockdown() then
        Frame.TestEntering = false
        ShowTestCombatAlert()
        Frame.TestTimer = C_Timer.NewTicker(math.max(DB.HoldTime, 0.1) + 0.5, ShowTestCombatAlert)
    else
        Private.CombatAlertTestMode = false
    end
end
