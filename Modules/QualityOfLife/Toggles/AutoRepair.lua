local Private = select(2, ...)

function Private:SetupAutoRepair()

    if not Private.AutoRepairFrame then Private.AutoRepairFrame = CreateFrame("Frame") end
    Private.AutoRepairFrame:RegisterEvent("MERCHANT_SHOW")
    Private.AutoRepairFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "MERCHANT_SHOW" and Private.DB.global.QualityOfLife.Toggles.AutoRepair then
            if CanGuildBankRepair() and GetGuildBankWithdrawMoney() > 0 then
                RepairAllItems(true)
            else
                RepairAllItems()
            end
        end
    end)
end