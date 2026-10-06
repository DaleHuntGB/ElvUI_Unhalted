local Private = select(2, ...)
Private.PreviewCombatAlertActive = false

local function CombatAlert_OnEvent(_, Event, ...)
    local DB = Private.DB.global.CombatAlert

    if Event == "PLAYER_REGEN_ENABLED" then
        Private.CombatAlertFrame.Text:SetText(DB.Text.ExitingCombat.Text)
        Private.CombatAlertFrame.Text:SetTextColor(DB.Text.ExitingCombat.Colour[1], DB.Text.ExitingCombat.Colour[2], DB.Text.ExitingCombat.Colour[3], 1)
        Private.CombatAlertFrame:Show()
        C_Timer.After(DB.HoldTime, function() Private.CombatAlertFrame:Hide() end)
    elseif Event == "PLAYER_REGEN_DISABLED" then
        Private.CombatAlertFrame.Text:SetText(DB.Text.EnteringCombat.Text)
        Private.CombatAlertFrame.Text:SetTextColor(DB.Text.EnteringCombat.Colour[1], DB.Text.EnteringCombat.Colour[2], DB.Text.EnteringCombat.Colour[3], 1)
        Private.CombatAlertFrame:Show()
        C_Timer.After(DB.HoldTime, function() Private.CombatAlertFrame:Hide() end)
    end
end

function Private:PreviewCombatAlert()
    local DB = Private.DB.global.CombatAlert
    local Random = math.random()

    if Private.PreviewCombatAlertActive and DB.Enable then
        Private.CombatAlertFrame:Show()
        Private.CombatAlertFrame.Text:SetText(Random > 0.5 and DB.Text.EnteringCombat.Text or DB.Text.ExitingCombat.Text)
        Private.CombatAlertFrame.Text:SetTextColor(Random > 0.5 and DB.Text.EnteringCombat.Colour[1] or DB.Text.ExitingCombat.Colour[1], Random > 0.5 and DB.Text.EnteringCombat.Colour[2] or DB.Text.ExitingCombat.Colour[2], Random > 0.5 and DB.Text.EnteringCombat.Colour[3] or DB.Text.ExitingCombat.Colour[3], 1)
    else
        Private.CombatAlertFrame:Hide()
    end
end

function Private:SetupCombatAlert()
    local DB = Private.DB.global.CombatAlert

    local CombatAlertFrame = CreateFrame("Frame", "CombatAlertFrame", UIParent)
    CombatAlertFrame:SetSize(1, 1)
    CombatAlertFrame:SetPoint(DB.Layout[1], _G["WorldFrame"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    CombatAlertFrame.Text = CombatAlertFrame:CreateFontString(nil, "OVERLAY")
    CombatAlertFrame.Text:SetFont(Private:FetchFont(DB.Text.Font), DB.Text.FontSize, DB.Text.FontFlag)
    CombatAlertFrame.Text:SetPoint("CENTER", CombatAlertFrame, "CENTER", 0, 0)

    Private.CombatAlertFrame = CombatAlertFrame

    if DB.Enable then
        CombatAlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        CombatAlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        CombatAlertFrame:SetScript("OnEvent", CombatAlert_OnEvent)
    end
end

function Private:UpdateCombatAlert()
    local DB = Private.DB.global.CombatAlert

    Private.CombatAlertFrame:SetSize(1, 1)
    Private.CombatAlertFrame:ClearAllPoints()
    Private.CombatAlertFrame:SetPoint(DB.Layout[1], _G["WorldFrame"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    Private.CombatAlertFrame.Text:SetFont(Private:FetchFont(DB.Text.Font), DB.Text.FontSize, DB.Text.FontFlag)
    Private.CombatAlertFrame.Text:SetPoint("CENTER", Private.CombatAlertFrame, "CENTER", 0, 0)

    if DB.Enable then
        Private.CombatAlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatAlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatAlertFrame:SetScript("OnEvent", CombatAlert_OnEvent)
    else
        Private.CombatAlertFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        Private.CombatAlertFrame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        Private.CombatAlertFrame:SetScript("OnEvent", nil)
    end

    Private:PreviewCombatAlert()
end