local Private = select(2, ...)

function Private:SetupEnhancedMovers()
    local restrictionsAreActive = C_RestrictedActions.IsAddOnRestrictionActive(0) == true or C_RestrictedActions.IsAddOnRestrictionActive(1) == true or C_RestrictedActions.IsAddOnRestrictionActive(2) == true
    if InCombatLockdown() or restrictionsAreActive then return end

    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvUF_PlayerMover.Enable, "ElvUF_PlayerMover", table.concat(Private.DB.global.ElvUI.Movers.ElvUF_PlayerMover.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvUF_TargetMover.Enable, "ElvUF_TargetMover", table.concat(Private.DB.global.ElvUI.Movers.ElvUF_TargetMover.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvUF_TargetCastbarMover.Enable, "ElvUF_TargetCastbarMover", table.concat(Private.DB.global.ElvUI.Movers.ElvUF_TargetCastbarMover.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvUF_PetMover.Enable, "ElvUF_PetMover", table.concat(Private.DB.global.ElvUI.Movers.ElvUF_PetMover.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvUF_FocusMover.Enable, "ElvUF_FocusMover", table.concat(Private.DB.global.ElvUI.Movers.ElvUF_FocusMover.Layout, ","))

    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvAB_1.Enable, "ElvAB_1", table.concat(Private.DB.global.ElvUI.Movers.ElvAB_1.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvAB_2.Enable, "ElvAB_2", table.concat(Private.DB.global.ElvUI.Movers.ElvAB_2.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvAB_3.Enable, "ElvAB_3", table.concat(Private.DB.global.ElvUI.Movers.ElvAB_3.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvAB_4.Enable, "ElvAB_4", table.concat(Private.DB.global.ElvUI.Movers.ElvAB_4.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvAB_5.Enable, "ElvAB_5", table.concat(Private.DB.global.ElvUI.Movers.ElvAB_5.Layout, ","))
    Private:SetMover(Private.DB.global.ElvUI.Movers.ElvAB_6.Enable, "ElvAB_6", table.concat(Private.DB.global.ElvUI.Movers.ElvAB_6.Layout, ","))

    Private.E:LoadMovers()
end
