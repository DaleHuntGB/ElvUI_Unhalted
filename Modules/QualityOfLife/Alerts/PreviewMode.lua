local Private = select(2, ...)
Private.PreviewAlertsActive = false

local function CreatePreviewAlert(FrameID, AlertDB, TestData, Index)
    local Frame = CreateFrame("Frame", FrameID, UIParent, "BackdropTemplate")
    Frame.PreviewIndex = Index
    local XOffset, YOffset = AlertDB.Layout[3], AlertDB.Layout[4]
    if Frame.PreviewIndex then
        local Index = Frame.PreviewIndex - 1
        local GrowthDirection = AlertDB.Layout[6]
        if GrowthDirection == "LEFT" then XOffset = XOffset - Index * (AlertDB.Size[1] + AlertDB.Layout[5])
        elseif GrowthDirection == "RIGHT" then XOffset = XOffset + Index * (AlertDB.Size[1] + AlertDB.Layout[5])
        elseif GrowthDirection == "UP" then YOffset = YOffset + Index * (AlertDB.Size[2] + AlertDB.Layout[5])
        elseif GrowthDirection == "DOWN" then YOffset = YOffset - Index * (AlertDB.Size[2] + AlertDB.Layout[5]) end
    end

    Frame:ClearAllPoints()
    Frame:SetSize(AlertDB.Size[1], AlertDB.Size[2])
    Frame:SetPoint(AlertDB.Layout[1], _G["UIParent"], AlertDB.Layout[2], XOffset, YOffset)
    Frame:SetShown(AlertDB.Enable)
    Frame:EnableMouse(false)
    Frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1, })
    Frame:SetBackdropColor(0, 0, 0, 0)
    Frame:SetBackdropBorderColor(0, 0, 0, 1)

    Frame.Icon = Frame:CreateTexture(nil, "OVERLAY")
    Frame.Icon:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
    Frame.Icon:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
    Frame.Icon:SetTexture(Index and TestData.IconIDs[Index] or TestData.IconID)
    Frame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    local Duration = Index and TestData.Durations[Index] or TestData.Duration
    Frame.PreviewDuration = Duration
    Frame.Cooldown = CreateFrame("Cooldown", nil, Frame, "CooldownFrameTemplate")
    Frame.Cooldown:SetAllPoints(Frame.Icon)
    Frame.Cooldown:SetCooldown(GetTime(), Duration)
    Frame.Cooldown:SetDrawSwipe(true)
    Frame.Cooldown:SetReverse(true)
    Private.ElvUI:RegisterCooldown(Frame.Cooldown)
    Frame.Cooldown:SetDrawEdge(false)
    Frame.Cooldown:SetScript("OnCooldownDone", function() if Private.PreviewAlertsActive then Frame.Cooldown:SetCooldown(GetTime(), Duration) end end)

    Private.PreviewAlertAuras[FrameID] = Frame

    return Frame
end

function Private:SetupPreviewAlerts()
    local DB = Private.DB.global.QualityOfLife.Alerts

    local AlertData = {
        Bloodlust = { IconID = 136012, Duration = 40 },
        Innervate = { IconID = 136048, Duration = 8 },
        PowerInfusion = { IconID = 135939, Duration = 10 },
        TimeSpiral = { IconID = 4622479, Duration = 15 },
        Externals = {
            IconIDs = {
                [1] = 135936,
                [2] = 135966,
                [3] = 135964,
                [4] = 135880,
                [5] = 627485,
                [6] = 237542,
                [7] = 572025,
                [8] = 4622478,
            },
            Durations = {
                [1] = 8,
                [2] = 12,
                [3] = 10,
                [4] = 10,
                [5] = 12,
                [6] = 10,
                [7] = 12,
                [8] = 8,
            }
        }
    }

    if Private.PreviewAlertsActive then
        for AlertName, TestData in pairs(AlertData) do
            if not Private.PreviewAlertAuras then Private.PreviewAlertAuras = {} end
            for Index = 1, TestData.IconIDs and 5 or 1 do
                local FrameID = "TestAura_" .. AlertName .. (TestData.IconIDs and "_" .. Index or "")
                if not Private.PreviewAlertAuras[FrameID] then
                    CreatePreviewAlert(FrameID, DB[AlertName], TestData, TestData.IconIDs and Index or nil)
                else
                    local Frame = Private.PreviewAlertAuras[FrameID]
                    Frame.Cooldown:SetCooldown(GetTime(), Frame.PreviewDuration)
                end
            end
        end
        Private:UpdatePreviewAlerts()
    else
        if Private.PreviewAlertAuras then
            for _, Frame in pairs(Private.PreviewAlertAuras) do
                Frame:Hide()
                Frame.Cooldown:Clear()
            end
        end
    end
end

function Private:UpdatePreviewAlerts()
    local DB = Private.DB.global.QualityOfLife.Alerts

    if Private.PreviewAlertsActive and Private.PreviewAlertAuras then
        for FrameID, Frame in pairs(Private.PreviewAlertAuras) do
            local AlertName = FrameID:gsub("TestAura_", ""):gsub("_%d+$", "")
            if DB[AlertName] then
                local AlertDB = DB[AlertName]
                local XOffset, YOffset = AlertDB.Layout[3], AlertDB.Layout[4]
                if Frame.PreviewIndex then
                    local Index = Frame.PreviewIndex - 1
                    local GrowthDirection = AlertDB.Layout[6]
                    if GrowthDirection == "LEFT" then XOffset = XOffset - Index * (AlertDB.Size[1] + AlertDB.Layout[5])
                    elseif GrowthDirection == "RIGHT" then XOffset = XOffset + Index * (AlertDB.Size[1] + AlertDB.Layout[5])
                    elseif GrowthDirection == "UP" then YOffset = YOffset + Index * (AlertDB.Size[2] + AlertDB.Layout[5])
                    elseif GrowthDirection == "DOWN" then YOffset = YOffset - Index * (AlertDB.Size[2] + AlertDB.Layout[5]) end
                end

                Frame:ClearAllPoints()
                Frame:SetSize(AlertDB.Size[1], AlertDB.Size[2])
                Frame:SetPoint(AlertDB.Layout[1], _G["UIParent"], AlertDB.Layout[2], XOffset, YOffset)
                Frame:SetShown(AlertDB.Enable)
            end
        end
    end
end
