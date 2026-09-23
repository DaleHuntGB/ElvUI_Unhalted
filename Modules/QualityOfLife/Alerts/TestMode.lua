local Private = select(2, ...)

local AlertData = {
    BloodlustAlert = { Icon = 136012, Duration = 40 },
    InnervateAlert = { Icon = 136048, Duration = 8 },
    PowerInfusionAlert = { Icon = 135939, Duration = 10 },
    TimeSpiralAlert = { Icon = 4622479, Duration = 15 },
}

local TestFrames = {}

function Private:SetAlertTestMode(Alert, Enabled)
    local DB = Private.DB.global.QualityOfLife.Alerts
    if Enabled and (not DB[Alert] or InCombatLockdown()) then return end
    local Data = AlertData[Alert]
    local Container = Private[Alert .. "Container"]
    local Frame = TestFrames[Alert]

    if Enabled and not Frame then
        local Size = Alert == "TimeSpiralAlert" and 48 or 42
        Frame = CreateFrame("Frame", nil, UIParent)
        Frame:SetSize(Size, Size)
        Frame:SetPoint("CENTER", Private[Alert .. "Anchor"], "CENTER", 0, 0)
        Frame:SetFrameStrata("TOOLTIP")
        Frame:EnableMouse(false)

        local Border = Frame:CreateTexture(nil, "BACKGROUND")
        Border:SetAllPoints(Frame)
        Border:SetColorTexture(0, 0, 0, 1)

        local Icon = Frame:CreateTexture(nil, "ARTWORK")
        Icon:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
        Icon:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
        Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
        Icon:SetTexture(Data.Icon)

        Frame.Cooldown = CreateFrame("Cooldown", nil, Frame, "CooldownFrameTemplate")
        Frame.Cooldown:SetAllPoints(Icon)
        Frame.Cooldown:SetDrawSwipe(true)
        Frame.Cooldown:SetReverse(true)
        Frame.Cooldown:SetHideCountdownNumbers(false)
        Frame.Cooldown:SetDrawEdge(false)
        Frame.Cooldown:SetScript("OnCooldownDone", function(Cooldown)
            if Private[Alert .. "TestMode"] then Cooldown:SetCooldown(GetTime(), Data.Duration) end
        end)
        Private.E:RegisterCooldown(Frame.Cooldown)

        Frame:SetScript("OnEvent", function() Private:SetAlertTestMode(Alert, false) end)
        TestFrames[Alert] = Frame
    end

    Private[Alert .. "TestMode"] = Enabled
    if Frame then
        Frame:UnregisterAllEvents()
        Frame:SetShown(Enabled)
        if Enabled then
            Frame:RegisterEvent("PLAYER_REGEN_DISABLED")
            Frame.Cooldown:SetCooldown(GetTime(), Data.Duration)
        else
            Frame.Cooldown:Clear()
        end
    end
    if Container then
        Container:SetShown(DB[Alert] and not Enabled)
        if DB[Alert] and not Enabled then Container:UpdateAllAuras() end
    end
    Private.ACR:NotifyChange("ElvUI")
end
