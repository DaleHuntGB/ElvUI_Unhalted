local Private = select(2, ...)

local function HideCombatAlert()
    Private.CombatAlertFrame.HideTimer = nil
    Private.CombatAlertFrame:Hide()
end

local function CombatAlert_OnEvent(CombatAlertFrame, Event)
    local DB = Private.DB.global.Alerts.Combat
    local TextDB = Event == "PLAYER_REGEN_DISABLED" and DB.Text.Enter or DB.Text.Exit

    CombatAlertFrame.Text:SetText(TextDB.Text)
    CombatAlertFrame.Text:SetTextColor(TextDB.Colour[1], TextDB.Colour[2], TextDB.Colour[3], 1)
    CombatAlertFrame:Show()
    if CombatAlertFrame.HideTimer then CombatAlertFrame.HideTimer:Cancel() end
    CombatAlertFrame.HideTimer = C_Timer.NewTimer(DB.HoldTime, HideCombatAlert)
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