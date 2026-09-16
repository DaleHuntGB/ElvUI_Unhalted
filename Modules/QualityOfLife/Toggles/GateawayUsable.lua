local Private = select(2, ...)
local GatewayItemID = 188152

local function GatewayUsableReminderFrame_OnEvent(GURFrame)
    local hasShard = C_Item.GetItemCount(GatewayItemID) > 0
    local isUsable = C_Spell.IsSpellUsable(113902)
    GURFrame.Text:SetText(not hasShard and "|cFFCC4040Buy|r" or "|cFF40CC40Usable|r")
    GURFrame:SetShown(isUsable or not hasShard)
end

function Private:SetupGatewayUsableReminder()
    if Private.GatewayUsableReminderFrame then return end

    local GatewayUsableReminderFrame = CreateFrame("Frame", "GatewayUsableReminderFrame", UIParent, "BackdropTemplate")
    GatewayUsableReminderFrame:SetBackdrop({ bgFile = nil, edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    GatewayUsableReminderFrame:SetBackdropBorderColor(0, 0, 0, 1)
    GatewayUsableReminderFrame:SetPoint("CENTER", UIParent, "CENTER", -125.1, 125.1)
    GatewayUsableReminderFrame:SetSize(48, 48)

    GatewayUsableReminderFrame.Icon = GatewayUsableReminderFrame:CreateTexture(nil, "ARTWORK")
    GatewayUsableReminderFrame.Icon:SetPoint("TOPLEFT", GatewayUsableReminderFrame, "TOPLEFT", 1, -1)
    GatewayUsableReminderFrame.Icon:SetPoint("BOTTOMRIGHT", GatewayUsableReminderFrame, "BOTTOMRIGHT", -1, 1)
    GatewayUsableReminderFrame.Icon:SetTexture(607513)
    GatewayUsableReminderFrame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    GatewayUsableReminderFrame.Text = GatewayUsableReminderFrame:CreateFontString(nil, "OVERLAY")
    GatewayUsableReminderFrame.Text:SetPoint("CENTER", GatewayUsableReminderFrame, "CENTER", 0, 0)
    GatewayUsableReminderFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE, SLUG")
    GatewayUsableReminderFrame.Text:SetTextColor(1, 1, 1, 1)

    Private.GatewayUsableReminderFrame = GatewayUsableReminderFrame
    Private:UpdateGatewayUsableReminder()
end

function Private:UpdateGatewayUsableReminder()
    local GURFrame = Private.GatewayUsableReminderFrame
    if not GURFrame then Private:SetupGatewayUsableReminder() return end

    if Private.DB.global.QualityOfLife.Toggles.GatewayUsable then
        GURFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        GURFrame:RegisterEvent("BAG_UPDATE_DELAYED")
        GURFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
        GURFrame:RegisterEvent("SPELL_UPDATE_USABLE")
        GURFrame:SetScript("OnEvent", GatewayUsableReminderFrame_OnEvent)
        GatewayUsableReminderFrame_OnEvent(GURFrame)
    else
        GURFrame:UnregisterAllEvents()
        GURFrame:SetScript("OnEvent", nil)
        GURFrame:Hide()
    end
end
