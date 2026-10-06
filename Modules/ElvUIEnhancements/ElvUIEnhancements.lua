local Private = select(2, ...)

function Private:SetupElvUIEnhancements()
    Private:SetupLootRollFix()
    Private:UpdateCastbarInterruptCooldown()
    Private:UpdateOverAbsorbs()
    Private:UpdateLFGHelper()
end
