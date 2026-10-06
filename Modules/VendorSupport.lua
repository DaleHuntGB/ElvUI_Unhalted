local Private = select(2, ...)

function Private:SetupVendorSupport()
    local DB = Private.DB.global.VendorSupport

    if not Private.VendorSupportFrame then Private.VendorSupportFrame = CreateFrame("Frame") end

    if DB.Enable then
        Private.VendorSupportFrame:RegisterEvent("MERCHANT_SHOW")
        Private.VendorSupportFrame:RegisterEvent("MERCHANT_CLOSED")
        Private.VendorSupportFrame:SetScript("OnEvent", function(_, event)
            if event == "MERCHANT_SHOW" then
                Private:SellItems(DB.MinimumQuality, DB.MinimumItemLevel)
            else
                Private:StopVendoring()
            end
        end)
    else
        Private.VendorSupportFrame:UnregisterEvent("MERCHANT_SHOW")
        Private.VendorSupportFrame:UnregisterEvent("MERCHANT_CLOSED")
        Private.VendorSupportFrame:SetScript("OnEvent", nil)
    end

end