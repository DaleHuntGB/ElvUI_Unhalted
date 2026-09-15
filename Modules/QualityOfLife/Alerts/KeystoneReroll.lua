local Private = select(2, ...)

local function FetchKeystone()
    local ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    local keystoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    if ownedKeystoneLevel and ownedKeystoneLevel > 0 then
        return string.format("+%s %s", ownedKeystoneLevel, Private.MapIDsToInstanceNames[keystoneMapID])
    else
        return "None", nil
    end
end

local function KeystoneAlertFrame_OnEvent(KAFrame, event, ...)
    if event == "CHALLENGE_MODE_COMPLETED" then
        local completionInfo = C_ChallengeMode.GetChallengeCompletionInfo()
        local ownedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
        if completionInfo and completionInfo.onTime and ownedKeystoneLevel and ownedKeystoneLevel <= completionInfo.level then KAFrame:Show() RunNextFrame(function() KAFrame.Keystone:SetText(FetchKeystone()) end) end
    elseif event == "PLAYER_ENTERING_WORLD" and KAFrame:IsShown() and not IsInInstance() then
        KAFrame:Hide()
    elseif event == "BAG_UPDATE_DELAYED" or event == "ITEM_CHANGED" then
        RunNextFrame(function() KAFrame.Keystone:SetText(FetchKeystone()) end) -- Wait until next frame before checking for the new keystone information.
    end
end

function Private:SetupKeystoneRerollAlert()
    if Private.KeystoneAlertFrame then return end

    local KeystoneAlertFrame = CreateFrame("Frame", "KeystoneAlertFrame", UIParent, "BackdropTemplate")
    KeystoneAlertFrame:SetBackdrop({ bgFile = nil, edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    KeystoneAlertFrame:SetBackdropBorderColor(0, 0, 0, 1)
    KeystoneAlertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 325.1)
    KeystoneAlertFrame:SetSize(64, 64)

    KeystoneAlertFrame.Icon = KeystoneAlertFrame:CreateTexture(nil, "ARTWORK")
    KeystoneAlertFrame.Icon:SetPoint("TOPLEFT", KeystoneAlertFrame, "TOPLEFT", 1, -1)
    KeystoneAlertFrame.Icon:SetPoint("BOTTOMRIGHT", KeystoneAlertFrame, "BOTTOMRIGHT", -1, 1)
    KeystoneAlertFrame.Icon:SetTexture("Interface\\Icons\\inv_relics_hourglass")
    KeystoneAlertFrame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    KeystoneAlertFrame.Text = KeystoneAlertFrame:CreateFontString(nil, "OVERLAY")
    KeystoneAlertFrame.Text:SetPoint("CENTER", KeystoneAlertFrame, "CENTER", 0, 0)
    KeystoneAlertFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE, SLUG")
    KeystoneAlertFrame.Text:SetTextColor(1, 1, 1, 1)
    KeystoneAlertFrame.Text:SetText("Reroll\nKey?")

    KeystoneAlertFrame.Keystone = KeystoneAlertFrame:CreateFontString(nil, "OVERLAY")
    KeystoneAlertFrame.Keystone:SetPoint("CENTER", KeystoneAlertFrame, "BOTTOM", 0, 0)
    KeystoneAlertFrame.Keystone:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, SLUG")
    KeystoneAlertFrame.Keystone:SetTextColor(1, 1, 1, 1)
    KeystoneAlertFrame.Keystone:SetText(FetchKeystone())

    if Private.DB.global.QualityOfLife.Toggles.KeystoneRerollAlert then
        KeystoneAlertFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        KeystoneAlertFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        KeystoneAlertFrame:RegisterEvent("BAG_UPDATE_DELAYED")
        KeystoneAlertFrame:RegisterEvent("ITEM_CHANGED")
        KeystoneAlertFrame:SetScript("OnEvent", KeystoneAlertFrame_OnEvent)
    end

    KeystoneAlertFrame:Hide()

    Private.KeystoneAlertFrame = KeystoneAlertFrame
end

function Private:UpdateKeystoneRerollAlert()
    if Private.DB.global.QualityOfLife.Toggles.KeystoneRerollAlert then
        Private.KeystoneAlertFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.KeystoneAlertFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        Private.KeystoneAlertFrame:RegisterEvent("BAG_UPDATE_DELAYED")
        Private.KeystoneAlertFrame:RegisterEvent("ITEM_CHANGED")
        Private.KeystoneAlertFrame:SetScript("OnEvent", KeystoneAlertFrame_OnEvent)
    else
        Private.KeystoneAlertFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Private.KeystoneAlertFrame:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        Private.KeystoneAlertFrame:UnregisterEvent("BAG_UPDATE_DELAYED")
        Private.KeystoneAlertFrame:UnregisterEvent("ITEM_CHANGED")
        Private.KeystoneAlertFrame:SetScript("OnEvent", nil)
    end
end