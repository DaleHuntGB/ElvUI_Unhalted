local Private = select(2, ...)

function Private:SetupAutoSellGreys()
    local DB = Private.DB.global.QualityOfLife.Toggles

    if not Private.AutoSellGreysFrame then Private.AutoSellGreysFrame = CreateFrame("Frame") end

    if DB.AutoSellGreys then
        Private.AutoSellGreysFrame:RegisterEvent("MERCHANT_SHOW")
        Private.AutoSellGreysFrame:RegisterEvent("MERCHANT_CLOSED")
        Private.AutoSellGreysFrame:SetScript("OnEvent", function(_, event)
            if event == "MERCHANT_SHOW" then
                Private:SellGreys()
            else
                Private:StopVendoring()
            end
        end)
    else
        Private.AutoSellGreysFrame:UnregisterEvent("MERCHANT_SHOW")
        Private.AutoSellGreysFrame:UnregisterEvent("MERCHANT_CLOSED")
        Private.AutoSellGreysFrame:SetScript("OnEvent", nil)
    end

end