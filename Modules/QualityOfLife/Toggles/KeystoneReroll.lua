local Private = select(2, ...)

local function FetchKeystone()
    local ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    local keystoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    if ownedKeystoneLevel and ownedKeystoneLevel > 0 then
        return string.format("+%s |cFF6080FF%s|r", ownedKeystoneLevel, Private.MapIDsToInstanceNames[keystoneMapID])
    else return
    end
end

local function KeystoneRerollReminderFrame_OnEvent(KRRFrame, event, ...)
    if event == "CHALLENGE_MODE_COMPLETED" then
        local completionInfo = C_ChallengeMode.GetChallengeCompletionInfo()
        local ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
        if completionInfo and completionInfo.onTime and ownedKeystoneLevel and ownedKeystoneLevel <= completionInfo.level then KRRFrame:Show() RunNextFrame(function() KRRFrame.Keystone:SetText(FetchKeystone()) end) end
    elseif event == "PLAYER_ENTERING_WORLD" and KRRFrame:IsShown() and not IsInInstance() then
        KRRFrame:Hide()
    elseif event == "BAG_UPDATE_DELAYED" or event == "ITEM_CHANGED" then
        RunNextFrame(function() KRRFrame.Keystone:SetText(FetchKeystone()) end) -- Wait until next frame before checking for the new keystone information.
    end
end

function Private:SetupKeystoneRerollReminder()
    if Private.KeystoneRerollReminderFrame then return end

    local KeystoneRerollReminderFrame = CreateFrame("Frame", "KeystoneRerollReminderFrame", UIParent, "BackdropTemplate")
    KeystoneRerollReminderFrame:SetBackdrop({ bgFile = nil, edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    KeystoneRerollReminderFrame:SetBackdropBorderColor(0, 0, 0, 1)
    KeystoneRerollReminderFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 325.1)
    KeystoneRerollReminderFrame:SetSize(64, 64)

    KeystoneRerollReminderFrame.Icon = KeystoneRerollReminderFrame:CreateTexture(nil, "ARTWORK")
    KeystoneRerollReminderFrame.Icon:SetPoint("TOPLEFT", KeystoneRerollReminderFrame, "TOPLEFT", 1, -1)
    KeystoneRerollReminderFrame.Icon:SetPoint("BOTTOMRIGHT", KeystoneRerollReminderFrame, "BOTTOMRIGHT", -1, 1)
    KeystoneRerollReminderFrame.Icon:SetTexture("Interface\\Icons\\inv_relics_hourglass")
    KeystoneRerollReminderFrame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    KeystoneRerollReminderFrame.Text = KeystoneRerollReminderFrame:CreateFontString(nil, "OVERLAY")
    KeystoneRerollReminderFrame.Text:SetPoint("CENTER", KeystoneRerollReminderFrame, "CENTER", 0, 0)
    KeystoneRerollReminderFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE, SLUG")
    KeystoneRerollReminderFrame.Text:SetTextColor(1, 1, 1, 1)
    KeystoneRerollReminderFrame.Text:SetText("Reroll\nKey?")

    KeystoneRerollReminderFrame.Keystone = KeystoneRerollReminderFrame:CreateFontString(nil, "OVERLAY")
    KeystoneRerollReminderFrame.Keystone:SetPoint("CENTER", KeystoneRerollReminderFrame, "BOTTOM", 0, 0)
    KeystoneRerollReminderFrame.Keystone:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, SLUG")
    KeystoneRerollReminderFrame.Keystone:SetTextColor(1, 1, 1, 1)
    KeystoneRerollReminderFrame.Keystone:SetText(FetchKeystone())

    if Private.DB.global.QualityOfLife.Toggles.KeystoneReroll then
        KeystoneRerollReminderFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        KeystoneRerollReminderFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        KeystoneRerollReminderFrame:RegisterEvent("BAG_UPDATE_DELAYED")
        KeystoneRerollReminderFrame:RegisterEvent("ITEM_CHANGED")
        KeystoneRerollReminderFrame:SetScript("OnEvent", KeystoneRerollReminderFrame_OnEvent)
    end

    KeystoneRerollReminderFrame:Hide()

    Private.KeystoneRerollReminderFrame = KeystoneRerollReminderFrame
end

function Private:UpdateKeystoneRerollReminder()
    if Private.DB.global.QualityOfLife.Toggles.KeystoneReroll then
        Private.KeystoneRerollReminderFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.KeystoneRerollReminderFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        Private.KeystoneRerollReminderFrame:RegisterEvent("BAG_UPDATE_DELAYED")
        Private.KeystoneRerollReminderFrame:RegisterEvent("ITEM_CHANGED")
        Private.KeystoneRerollReminderFrame:SetScript("OnEvent", KeystoneRerollReminderFrame_OnEvent)
    else
        Private.KeystoneRerollReminderFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Private.KeystoneRerollReminderFrame:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        Private.KeystoneRerollReminderFrame:UnregisterEvent("BAG_UPDATE_DELAYED")
        Private.KeystoneRerollReminderFrame:UnregisterEvent("ITEM_CHANGED")
        Private.KeystoneRerollReminderFrame:SetScript("OnEvent", nil)
    end
end