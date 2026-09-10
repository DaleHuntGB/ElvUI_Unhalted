local Private = select(2, ...)

function Private:SetupCombatAlert()
    local DB = Private.DB.global.CombatAlert

    if not Private.CombatAlertFrame then
        Private.CombatAlertFrame = CreateFrame("Frame", nil, UIParent)
        Private.CombatAlertFrame:SetSize(1, 1)
        Private.CombatAlertFrame:EnableMouse(false)
        Private.CombatAlertFrame.Text = Private.CombatAlertFrame:CreateFontString(nil, "OVERLAY")
        Private.CombatAlertFrame.Text:SetPoint("CENTER", Private.CombatAlertFrame, "CENTER", 0, 0)
        Private.CombatAlertFrame.Text:SetJustifyH("CENTER")
    end

    if DB.Enabled then
        Private.CombatAlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatAlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatAlertFrame:SetScript("OnEvent", function(_, event, ...)
            if Private.CombatAlertFrame.ClearTimer then Private.CombatAlertFrame.ClearTimer:Cancel() Private.CombatAlertFrame.ClearTimer = nil end
            if event == "PLAYER_REGEN_DISABLED" then
                Private.CombatAlertFrame.Text:SetText(Private.DB.global.CombatAlert.EnteringCombat)
                Private.CombatAlertFrame.Text:SetTextColor(Private.DB.global.CombatAlert.EnteringCombatColour[1], Private.DB.global.CombatAlert.EnteringCombatColour[2], Private.DB.global.CombatAlert.EnteringCombatColour[3], Private.DB.global.CombatAlert.EnteringCombatColour[4])
                Private.CombatAlertFrame:Show()
			    Private.CombatAlertFrame.ClearTimer = C_Timer.NewTimer(Private.DB.global.CombatAlert.HoldTime, function() Private.CombatAlertFrame.Text:SetText("") Private.CombatAlertFrame:Hide() Private.CombatAlertFrame.ClearTimer = nil end)
            elseif event == "PLAYER_REGEN_ENABLED" then
                Private.CombatAlertFrame.Text:SetText(Private.DB.global.CombatAlert.ExitingCombat)
                Private.CombatAlertFrame.Text:SetTextColor(Private.DB.global.CombatAlert.ExitingCombatColour[1], Private.DB.global.CombatAlert.ExitingCombatColour[2], Private.DB.global.CombatAlert.ExitingCombatColour[3], Private.DB.global.CombatAlert.ExitingCombatColour[4])
                Private.CombatAlertFrame:Show()
                Private.CombatAlertFrame.ClearTimer = C_Timer.NewTimer(Private.DB.global.CombatAlert.HoldTime, function() Private.CombatAlertFrame.Text:SetText("") Private.CombatAlertFrame:Hide() Private.CombatAlertFrame.ClearTimer = nil end)
            end
        end)
        Private.CombatAlertFrame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Private.CombatAlertFrame.Text:SetFont(Private.LSM:Fetch("font", DB.Font[1]), DB.Font[2], DB.Font[3])
    end
end

function Private:UpdateCombatAlert()
    local DB = Private.DB.global.CombatAlert

    if DB.Enabled then
        Private.CombatAlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatAlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatAlertFrame:SetScript("OnEvent", function(_, event, ...)
            if Private.CombatAlertFrame.ClearTimer then Private.CombatAlertFrame.ClearTimer:Cancel() Private.CombatAlertFrame.ClearTimer = nil end
            if event == "PLAYER_REGEN_DISABLED" then
                Private.CombatAlertFrame.Text:SetText(Private.DB.global.CombatAlert.EnteringCombat)
                Private.CombatAlertFrame.Text:SetTextColor(Private.DB.global.CombatAlert.EnteringCombatColour[1], Private.DB.global.CombatAlert.EnteringCombatColour[2], Private.DB.global.CombatAlert.EnteringCombatColour[3], Private.DB.global.CombatAlert.EnteringCombatColour[4])
                Private.CombatAlertFrame:Show()
                Private.CombatAlertFrame.ClearTimer = C_Timer.NewTimer(Private.DB.global.CombatAlert.HoldTime, function() Private.CombatAlertFrame.Text:SetText("") Private.CombatAlertFrame:Hide() Private.CombatAlertFrame.ClearTimer = nil end)
            elseif event == "PLAYER_REGEN_ENABLED" then
                Private.CombatAlertFrame.Text:SetText(Private.DB.global.CombatAlert.ExitingCombat)
                Private.CombatAlertFrame.Text:SetTextColor(Private.DB.global.CombatAlert.ExitingCombatColour[1], Private.DB.global.CombatAlert.ExitingCombatColour[2], Private.DB.global.CombatAlert.ExitingCombatColour[3], Private.DB.global.CombatAlert.ExitingCombatColour[4])
                Private.CombatAlertFrame:Show()
                Private.CombatAlertFrame.ClearTimer = C_Timer.NewTimer(Private.DB.global.CombatAlert.HoldTime, function() Private.CombatAlertFrame.Text:SetText("") Private.CombatAlertFrame:Hide() Private.CombatAlertFrame.ClearTimer = nil end)
            end
        end)
        Private.CombatAlertFrame:ClearAllPoints()
        Private.CombatAlertFrame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Private.CombatAlertFrame.Text:SetFont(Private.LSM:Fetch("font", DB.Font[1]), DB.Font[2], DB.Font[3])
    else
        if Private.CombatAlertFrame.ClearTimer then Private.CombatAlertFrame.ClearTimer:Cancel() Private.CombatAlertFrame.ClearTimer = nil end
        Private.CombatAlertFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatAlertFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatAlertFrame:SetScript("OnEvent", nil)
        Private.CombatAlertFrame.Text:SetText("")
        Private.CombatAlertFrame:Hide()
    end
end