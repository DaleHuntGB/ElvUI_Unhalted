local Private = select(2, ...)
local Hooked = false

function Private:SetupZoneText()
    local ZTDB = Private.DB.global.Blizzard.ZoneText
    local SZTDB = Private.DB.global.Blizzard.SubZoneText
    local ZTS = _G["ZoneTextString"]
    local SZTS = _G["SubZoneTextString"]

    ZTS:ClearAllPoints()
    ZTS:SetPoint(ZTDB.Layout[1], _G["UIParent"], ZTDB.Layout[2], ZTDB.Layout[3], ZTDB.Layout[4])
    ZTS:SetFont(Private:FetchFont(ZTDB.Font), ZTDB.FontSize, ZTDB.FontFlag)
    ZTS:SetShadowColor(0, 0, 0, 0)
    ZTS:SetShadowOffset(0, 0)

    SZTS:SetFont(Private:FetchFont(SZTDB.Font), SZTDB.FontSize, SZTDB.FontFlag)
    SZTS:SetShadowColor(0, 0, 0, 0)
    SZTS:SetShadowOffset(0, 0)

    local Anchor = PVPInfoTextString:GetText() ~= "" and PVPInfoTextString or ZTS
    SZTS:ClearAllPoints()
    SZTS:SetPoint(SZTDB.Layout[1], Anchor, SZTDB.Layout[2], SZTDB.Layout[3], SZTDB.Layout[4])

    PVPInfoTextString:SetAlpha(0)
    PVPArenaTextString:SetAlpha(0)

    ZTS:SetShown(ZTDB.Enable)
    SZTS:SetShown(SZTDB.Enable)

    hooksecurefunc("SetZoneText", function() local DB = Private.DB.global.Blizzard.SubZoneText local Anchor = PVPInfoTextString:GetText() ~= "" and PVPInfoTextString or ZoneTextString SubZoneTextString:ClearAllPoints() SubZoneTextString:SetPoint(DB.Layout[1], Anchor, DB.Layout[2], DB.Layout[3], DB.Layout[4]) end)
end

function Private:UpdateZoneText()
    local ZTDB = Private.DB.global.Blizzard.ZoneText
    local SZTDB = Private.DB.global.Blizzard.SubZoneText
    local ZTS = _G["ZoneTextString"]
    local SZTS = _G["SubZoneTextString"]

    ZTS:ClearAllPoints()
    ZTS:SetPoint(ZTDB.Layout[1], _G["UIParent"], ZTDB.Layout[2], ZTDB.Layout[3], ZTDB.Layout[4])
    ZTS:SetFont(Private:FetchFont(ZTDB.Font), ZTDB.FontSize, ZTDB.FontFlag)
    ZTS:SetShadowColor(0, 0, 0, 0)
    ZTS:SetShadowOffset(0, 0)

    SZTS:SetFont(Private:FetchFont(SZTDB.Font), SZTDB.FontSize, SZTDB.FontFlag)
    SZTS:SetShadowColor(0, 0, 0, 0)
    SZTS:SetShadowOffset(0, 0)

    SetZoneText(true)
    local Anchor = PVPInfoTextString:GetText() ~= "" and PVPInfoTextString or ZTS
    SZTS:ClearAllPoints()
    SZTS:SetPoint(SZTDB.Layout[1], Anchor, SZTDB.Layout[2], SZTDB.Layout[3], SZTDB.Layout[4])

    PVPInfoTextString:SetAlpha(0)
    PVPArenaTextString:SetAlpha(0)

    ZTS:SetShown(ZTDB.Enable)
    SZTS:SetShown(SZTDB.Enable)

    ZTS:SetText(Private.AddOnName .. ": Sample Zone Text...")
    SZTS:SetText(Private.AddOnName .. ": Sample Sub Zone Text...")
    FadingFrame_Show(ZoneTextFrame)
    FadingFrame_Show(SubZoneTextFrame)
end
