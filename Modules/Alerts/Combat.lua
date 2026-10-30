local Private = select(2, ...)

local function CombatAlert_OnEvent(_, Event, ...)
    local DB = Private.DB.global.Alerts.Combat

    if Event == "PLAYER_REGEN_ENABLED" then
        Private.CombatAlertFrame.Text:SetText(DB.Text.Exit.Text)
        Private.CombatAlertFrame.Text:SetTextColor(DB.Text.Exit.Colour[1], DB.Text.Exit.Colour[2], DB.Text.Exit.Colour[3], 1)
        Private.CombatAlertFrame:Show()
        C_Timer.After(DB.HoldTime, function() Private.CombatAlertFrame:Hide() end)
    elseif Event == "PLAYER_REGEN_DISABLED" then
        Private.CombatAlertFrame.Text:SetText(DB.Text.Enter.Text)
        Private.CombatAlertFrame.Text:SetTextColor(DB.Text.Enter.Colour[1], DB.Text.Enter.Colour[2], DB.Text.Enter.Colour[3], 1)
        Private.CombatAlertFrame:Show()
        C_Timer.After(DB.HoldTime, function() Private.CombatAlertFrame:Hide() end)
    end
end

function Private:SetupCombatAlert()
    local DB = Private.DB.global.Alerts.Combat

    local CombatAlertFrame = CreateFrame("Frame", "CombatAlertFrame", UIParent)
    CombatAlertFrame:SetSize(1, 1)
    CombatAlertFrame:SetPoint(DB.Layout[1], _G["WorldFrame"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    CombatAlertFrame.Text = CombatAlertFrame:CreateFontString(nil, "OVERLAY")
    CombatAlertFrame.Text:SetPoint("CENTER", CombatAlertFrame, "CENTER", 0, 0)
    Private.E:SetFont(CombatAlertFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)

    Private.CombatAlertFrame = CombatAlertFrame

    if DB.Enable then
        CombatAlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        CombatAlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
        CombatAlertFrame:SetScript("OnEvent", CombatAlert_OnEvent)
    end
end

function Private:UpdateCombatAlert()
    local DB = Private.DB.global.Alerts.Combat

    Private.CombatAlertFrame:SetSize(1, 1)
    Private.CombatAlertFrame:ClearAllPoints()
    Private.CombatAlertFrame:SetPoint(DB.Layout[1], _G["WorldFrame"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    Private.E:SetFont(Private.CombatAlertFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
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
end