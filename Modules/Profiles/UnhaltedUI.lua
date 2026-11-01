local Private = select(2, ...)

local ImportString = "!UHUI_7VfPj9tEFHaIuCG16ikFCUVF7QVa9RcVcOjuJvbY2cRJNvaKBSFFs/EkMevMhJnx7qYqUkXL/0A5wW5bKso/wKmVkDhz5MCh4sYRaX1AOZTx+EecZHcbkBCiYg7JjD3ve+993xv7+SFY8RDlbN9skh1EK7jrM5fg+5pFfOxsvHGzA8C1i+9cBGAd96HHkXOTvlfUCeTFkocgd3EPaBhueigANTgiPr8Dylrd1lrx33jp+7vh+HK83AbdcNQkdLkPMUYeMCHjiKqWewN9VjhXOLdquwNkDV0KvfuH7VzYm3P7SjiiRNQ6wWjiBJTJYBPye8eDKePl1o8yZNVGu3xf07AIYE8u9DcjCIHkEZ/eHi/9Fjte+umkHOnEAATz0PUJVdt1eWx/ftY+NZsFMgziOSErf1xXGuaI991O0/NZeIV+V7P6ZKcEO1sOJcNgVa4IY4gFeoTM7gMLdQh2si6eRpOcru0KppFzbPhNSnoUMSY2/VyQYwKg2X2XhuZPZ6xSQEPkOfQQR8elmPCvtSq6YUe/RUVmo4oi67MgUcqwXe6hEqQPpjI/AAZye31+ItknSZ7TV61pwJY/OSWV5ZVEg1wup280ul2GuKJ/EE1y2vuuw/unc29VWmQnclIoyMgAoR3Bs/T0sLEyEHXG2ymoGV+YYJt1OECTDTW5jN0oVbmabK7H5nE8Z6Ld8Sqf3E2s9TAGn6K1kufeuAGpU2xB1ykKmqoqHMAeMoUA9M6309UyxdWjBTKYDvn4kFqZhEqjsgcZO5hhwEw90gHklbOs+OutveJZ9jwu7KnAEvCKzNEeDZFyRJEEINFv0SrJL1ol8aPll8LdqiWOiniChoHkVFEz7OUEt1pq2HbDlNWdnY8f/56ch3hytJ7/S/iPS/iRVC2fFVJZXMLlbvTe+asSHrxoEub+a6fwydYPUrm/fQpfOAnz/+YpnJcwv7iEzz+Fuk16PQ+xB6srPicqCluUQM4tt4fXh0HDcB1kQ29LtLgGgk5QDy+EzVUp7EdpsBaua2Ld6JZFbpR4Qd3acodlFyMhg9thgZG43TPXKxqlhDJAhSb7z2k8C5+qIfjBxmtl0WTjxubHqMPdbWRToQCicQCrK47TwMIlZl/rJb9niZtzyIbdaEpy0snkWZVMItJPnaqZLnYHcGhxyNk9o0Y6Ig2C53TVBVSoavKfPzNRtxoWiuVvfiga7qBqjUTPPpB430z2VCw0RBRyQsuiUOvrQwdyVAmb623o5VNvUTkD0LTappX4Xo30Dt1mpvmXMlWlhq3xg0nbPeOg8PqMh/Llq8bx8LmTGfhWBTMOcQepbrfrdnyPj+ZYn2PowiR7TfO21yv71RohvEU8D7i7gSWDo/6QN3CZiH6f7OAAmGQbUfZIFwYrpfalWS+fT50DidqEFGEOouuxvl8ohVf19mImzfOXLlx8NzNKl69tFMJ9oG1D2kO8LL7CNiGVoe3NBpSkW8taZHhMI0pLL87tWgJ1kEDFR2Eqxvh0KPUIvon4VBgHR4TR9OAI0UwYc+6vzmWS2Z3QPzlA0Qviq1w6Wcs6Opya6KNmzSqbbZ0Sf7iCO31C25fk43H85PrpEOnW+LH8fr2lNCNEQDo+Oxwwq+RRiRaVOPgriySY0KakecV33p6zPkad8ZOdT6TIsfHlOWM161SbplRZy5bO4ZlL+3kmY6TliMpnKZV/Ag=="

function Private:ExportUnhaltedUI()
    local serializedData = C_EncodingUtil.SerializeCBOR(Private.DB.global)
    local compressedData = serializedData and C_EncodingUtil.CompressString(serializedData, Enum.CompressionMethod.Deflate)
    if not compressedData then return end
    ImportString = "!UHUI_" .. C_EncodingUtil.EncodeBase64(compressedData)

    StaticPopupDialogs["UHUI_EXPORT_PROFILE"] = {
        text = "Profile String",
        button1 = "Close",
        hasEditBox = true,
        hasWideEditBox = true,
        OnShow = function(Dialog, Data)
            Dialog.EditBox:SetMaxLetters(0)
            Dialog.EditBox:SetText(ImportString)
            Dialog.EditBox:SetFocus()
            Dialog.EditBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    StaticPopup_Show("UHUI_EXPORT_PROFILE")
end

function Private:ImportUnhaltedUI()
    local compressedData = C_EncodingUtil.DecodeBase64(ImportString:sub(7))
    local serializedData = compressedData and C_EncodingUtil.DecompressString(compressedData, Enum.CompressionMethod.Deflate)
    if not serializedData then return end
    local importedData = C_EncodingUtil.DeserializeCBOR(serializedData)
    if type(importedData) ~= "table" then return end
    wipe(Private.DB.global)
    for Key, Value in pairs(importedData) do Private.DB.global[Key] = Value end
end