local Private = select(2, ...)

-- Ordered by item level (highest first), so the best ammo carried is counted.
local ItemIDs = {
    13377, -- Miniature Cannon Balls
    12654, -- Doomshot
    18042, -- Thorium Headed Arrow
    15997, -- Thorium Shells
    19316, -- Ice Threaded Arrow
    19317, -- Ice Threaded Bullet
    11630, -- Rockshard Pellets
    10513, -- Mithril Gyro-Shot
    11285, -- Jagged Arrow
    11284, -- Accurate Slugs
    10579, -- Explosive Arrow
    10512, -- Hi-Impact Mithril Slugs
    9399, -- Precision Arrow
    3465, -- Exploding Shot
    3464, -- Feathered Arrow
    8069, -- Crafted Solid Shot
    3030, -- Razor Arrow
    3033, -- Solid Shot
    8068, -- Crafted Heavy Shot
    5568, -- Smooth Pebble
    2515, -- Sharp Arrow
    2519, -- Heavy Shot
    8067, -- Crafted Light Shot
    4960, -- Flash Pellet
    2512, -- Rough Arrow
    2516, -- Light Shot
}

local function AmmoCounter_OnEvent(ACF, Event, Unit)
    if Event == "UNIT_INVENTORY_CHANGED" and Unit ~= "player" then return end
    local DB = Private.DB.global.Miscellaneous.AmmoCounter.Text
    local Count = 0
    for _, ID in ipairs(ItemIDs) do
        Count = C_Item.GetItemCount(ID)
        if Count > 0 then break end
    end
    local Colour = Count < DB.Threshold and DB.BelowThresholdColour or DB.Colour
    ACF.Text:SetText(Count > 0 and Private:AbbreviateValue(Count) or "0")
    ACF.Text:SetTextColor(Colour[1], Colour[2], Colour[3])
end

function Private:SetupAmmoCounter()
    if not Private.isForever or Private.E.myclass ~= "HUNTER" then return end
    local DB = Private.DB.global.Miscellaneous.AmmoCounter

    local AmmoCounterFrame = CreateFrame("Frame", "AmmoCounterFrame", UIParent)
    AmmoCounterFrame:SetSize(1, 1)
    RunNextFrame(function() AmmoCounterFrame:SetPoint(DB.Layout[1], _G[DB.AnchorParent], DB.Layout[2], DB.Layout[3], DB.Layout[4]) end)
    AmmoCounterFrame:SetShown(DB.Enable)

    AmmoCounterFrame.Text = AmmoCounterFrame:CreateFontString(nil, "OVERLAY")
    Private.E:SetFont(AmmoCounterFrame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
    AmmoCounterFrame.Text:SetPoint(DB.Layout[1], AmmoCounterFrame, DB.Layout[1], 0, 0)
    AmmoCounter_OnEvent(AmmoCounterFrame)
    AmmoCounterFrame.Text:SetJustifyH(Private.JustificationH[DB.Layout[1]])
    AmmoCounterFrame:SetSize(AmmoCounterFrame.Text:GetStringWidth(), AmmoCounterFrame.Text:GetStringHeight())

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
    AmmoCounterFrame.Text:ClearAllPoints()
    AmmoCounterFrame.Text:SetPoint(DB.Layout[1], AmmoCounterFrame, DB.Layout[1], 0, 0)
    AmmoCounterFrame.Text:SetJustifyH(Private.JustificationH[DB.Layout[1]])
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

    AmmoCounterFrame:SetSize(AmmoCounterFrame.Text:GetStringWidth(), AmmoCounterFrame.Text:GetStringHeight())
    AmmoCounterFrame:SetShown(DB.Enable)
end