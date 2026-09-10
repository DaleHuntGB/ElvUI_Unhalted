local Private = select(2, ...)

function Private:SetupVendorHelper()
    local DB = Private.DB.global.VendorHelper

    if not Private.AutoVendorFrame then Private.AutoVendorFrame = CreateFrame("Frame") end

    if DB.AutoVendor then
        Private.AutoVendorFrame:RegisterEvent("MERCHANT_SHOW")
        Private.AutoVendorFrame:RegisterEvent("MERCHANT_CLOSED")
        Private.AutoVendorFrame:SetScript("OnEvent", function(_, event)
            if event == "MERCHANT_SHOW" then
                Private:SellItems(DB.MinimumQuality, DB.MinimumItemLevel)
            else
                Private:StopVendoring()
            end
        end)
    else
        Private.AutoVendorFrame:UnregisterEvent("MERCHANT_SHOW")
        Private.AutoVendorFrame:UnregisterEvent("MERCHANT_CLOSED")
        Private.AutoVendorFrame:SetScript("OnEvent", nil)
    end

end