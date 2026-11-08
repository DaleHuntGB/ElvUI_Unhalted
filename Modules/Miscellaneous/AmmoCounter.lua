local Private = select(2, ...)

local function AmmoCounter_OnEvent(ACF, Event, Unit)
    if Event == "UNIT_INVENTORY_CHANGED" and Unit ~= "player" then return end
    local DB = Private.DB.global.Miscellaneous.AmmoCounter.Text
    local Count = GetInventoryItemID("player", INVSLOT_AMMO) and GetInventoryItemCount("player", INVSLOT_AMMO) or 0
    local Colour = Count < DB.Threshold and DB.BelowThresholdColour or DB.Colour
    ACF.Icon:SetTexture(GetInventoryItemTexture("player", INVSLOT_AMMO) or 134400)
    ACF.Text:SetText(Count > 0 and Private:AbbreviateValue(Count) or "0")
    ACF.Text:SetTextColor(Colour[1], Colour[2], Colour[3])
end

function Private:SetupAmmoCounter()
    if Private.E.myclass ~= "HUNTER" then return end
    local DB = Private.DB.global.Miscellaneous.AmmoCounter

    local AmmoCounterFrame = CreateFrame("Frame", "AmmoCounterFrame", UIParent)
    AmmoCounterFrame:SetSize(DB.Size[1], DB.Size[2])
    RunNextFrame(function() AmmoCounterFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4]) end)
    AmmoCounterFrame:SetShown(DB.Enable)

    AmmoCounterFrame.Border = AmmoCounterFrame:CreateTexture(nil, "BACKGROUND")
    AmmoCounterFrame.Border:SetAllPoints(AmmoCounterFrame)
    AmmoCounterFrame.Border:SetColorTexture(0, 0, 0, 1)

    AmmoCounterFrame.Icon = AmmoCounterFrame:CreateTexture(nil, "ARTWORK")
    AmmoCounterFrame.Icon:SetPoint("TOPLEFT", AmmoCounterFrame, "TOPLEFT", 1, -1)
    AmmoCounterFrame.Icon:SetPoint("BOTTOMRIGHT", AmmoCounterFrame, "BOTTOMRIGHT", -1, 1)
    AmmoCounterFrame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)

    AmmoCounterFrame.Text = AmmoCounterFrame:CreateFontString(nil, "OVERLAY")
    Private.E:SetFont(AmmoCounterFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
    AmmoCounterFrame.Text:SetPoint("CENTER", AmmoCounterFrame, "CENTER", 0, 0)
    AmmoCounterFrame.Text:SetJustifyH("CENTER")
    AmmoCounter_OnEvent(AmmoCounterFrame)

    AmmoCounterFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    AmmoCounterFrame:RegisterEvent("BAG_UPDATE_DELAYED")
    AmmoCounterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    AmmoCounterFrame:SetScript("OnEvent", AmmoCounter_OnEvent)

    Private.AmmoCounterFrame = AmmoCounterFrame
end

function Private:UpdateAmmoCounter()
    local AmmoCounterFrame = Private.AmmoCounterFrame
    if not AmmoCounterFrame then return end
    local DB = Private.DB.global.Miscellaneous.AmmoCounter

    Private.E:SetFont(AmmoCounterFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
    AmmoCounterFrame:SetSize(DB.Size[1], DB.Size[2])
    AmmoCounterFrame:ClearAllPoints()
    AmmoCounterFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    if DB.Enable then
        AmmoCounterFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
        AmmoCounterFrame:RegisterEvent("BAG_UPDATE_DELAYED")
        AmmoCounterFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        AmmoCounterFrame:SetScript("OnEvent", AmmoCounter_OnEvent)
        AmmoCounter_OnEvent(AmmoCounterFrame)
    else
        AmmoCounterFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        AmmoCounterFrame:UnregisterEvent("BAG_UPDATE_DELAYED")
        AmmoCounterFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        AmmoCounterFrame:SetScript("OnEvent", nil)
    end

    AmmoCounterFrame:SetShown(DB.Enable)
end
