local Private = select(2, ...)
local E = Private.E
local LCG = E.Libs.CustomGlow
local GlowFrames = {}
local Hooked, UpdateQueued

local function UpdateGlowAlpha(Frame)
    Frame:SetAlphaFromBoolean(Frame.Visibility:IsVisible(), 1, 0)
end

local function QueueGlowUpdate()
    if UpdateQueued then return end
    UpdateQueued = true
    C_Timer.After(0, function()
        UpdateQueued = false
        for Alert in pairs(GlowFrames) do Private:UpdateAlertGlows(Alert) end
    end)
end

function Private:CreateAlertGlow(Alert, Parent, Size, Aura)
    -- Keep the parent and anchors outside AuraContainer's secret layout.
    local Frame = CreateFrame("Frame", nil, Parent)
    Frame:SetSize(Size, Size)
    Frame:SetPoint("CENTER", Parent, "CENTER", 0, 0)
    Frame:EnableMouse(false)
    Frame:Hide()

    if Aura then
        -- Keep animation scripts outside the managed aura. Its visibility stays opaque.
        local Visibility = CreateFrame("Frame", nil, Aura)
        Visibility:SetSize(1, 1)
        Visibility:SetPoint("CENTER", Aura, "CENTER", 0, 0)
        Frame.Visibility = Visibility
    end

    if not GlowFrames[Alert] then GlowFrames[Alert] = {} end
    table.insert(GlowFrames[Alert], Frame)

    if not Hooked then
        hooksecurefunc(E, "StopAllCustomGlows", QueueGlowUpdate)
        hooksecurefunc(E, "UpdateMedia", QueueGlowUpdate)
        Hooked = true
    end
end

function Private:UpdateAlertGlows(Alert)
    local Frames = GlowFrames[Alert]
    if not Frames then return end
    local DB = Private.DB.global.QualityOfLife.Alerts
    local TestMode = not not Private[Alert .. "TestMode"]

    for _, Frame in ipairs(Frames) do
        Frame:Hide()
        Frame:SetScript("OnUpdate", nil)
        if Frame.GlowStyle then
            LCG.HideOverlayGlow(Frame, Frame.GlowStyle)
            Frame.GlowStyle = nil
        end

        local IsPreview = not Frame.Visibility
        if DB[Alert] and DB[Alert .. "Glow"] and IsPreview == TestMode then
            if Frame.Visibility then
                UpdateGlowAlpha(Frame)
                Frame:SetScript("OnUpdate", UpdateGlowAlpha)
            else
                Frame:SetAlpha(1)
            end
            Frame:Show()
            LCG.ShowOverlayGlow(Frame)
            Frame.GlowStyle = E.db.general.customGlow.style
        end
    end
end
