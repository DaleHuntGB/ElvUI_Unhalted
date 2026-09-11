local Private = select(2, ...)

function Private:SetupPositionRaidWarningFrame()
    if not Private.DB.global.QualityOfLife.Toggles.PositionRaidWarningFrame then return end
    RaidWarningFrame:ClearAllPoints()
    RaidWarningFrame:SetPoint("TOP", UIParent, "TOP", 0, -325.1)
end