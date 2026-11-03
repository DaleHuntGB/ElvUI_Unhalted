local Private = select(2, ...)

local ImportString = "!UHUI_7VfPj9tEFE6IuCG16ikFCUVF7QVa7W5LBRzaJo5/beI4G3vVBSFFs/YkGep4wni8u1kVacW2/wPlBNtu+VH+AU6thMSZIwcOFTeOSJsDygFmxnbiJJttqIQQFT4kM/bMe9/7vveex9+YRp92kFP3wsBGXUi+q1odvF0Czi2X4N5gVcxwEMBgoErYwyEJDhULOth394fXfzotruH1p9Egq8o7PUQgf/bbPX59nloUD7Q6wW0Cg4At+jkvrrEB2e4gwrc/ndo1MqhJuNvzIIX7s89Gd5Qq6OOQ3pEbuqrZ0W8hI6IpQ0A7wUCRfbDpwYFmI+rBEiAPJyI/UjSI2h16KllXtuEOfZDMEvvlqqzY4ieb0RTsUwvtwleUiKn9bDarbpitVgBpRn0/GmTlm8ilnbPZt/QG3o6c5PMCmYKJw3gWnr42i10c+rQ5MmrEN8a2jRrowvGCqpjGbjIVMRsvrsXbYzznotXxLJc8TXarHENI4FrJQ7u7gLiFBkBugdFUKYMuaEODCUDufDuZLRNcPVoggknIJ0NqpAIq9SUPBMHRFAPGyCPpAqqfDwq/7h0UzgfP4sKeAJYY10WMdr8HM3OSZKAk+i2aJblFs6TMl3ya/yV/r2KxUkHY50CyZZYzwcuJ3UrJtG3TENmdHg8f/57UQzyYr+f/Ev7jEn4oVMulhcwsLuGN1v5lfv1dCY9eNAmz/7UqfHLrB6Hcc1fhCydh7t+swlkJc4tL+Owq1JI7B8a6LhOCSaAQRtf96SAUSa6xI0n8l8l/UtaQC482XpM8CHxz8yPoULQFbcLIgaQEfB+SwWrRdU3fuoX84Eu1FLYt9nDGsmabdYF7NBi3kWQQ8XHmTNVAPuqCnkUBDR5UrH5AYVdMvhozq1uwBwmgmEgsAWrrPRdQqPtMzS3g5UbuozRRlLrVNKwEzGrEIxcrNcy9lFJLq2IHUCbJjNAqC4AvT/5z58agKjxzrHDzA+zzPGGn1jHiM+LhTX7EY6RNAc6/Pu1mDsbTcUTSyhUtBbeh+wEFvgPLqNVCTujR/owEM8AvjYEbBgoc6HnAhzgMDioG+4USO1FjchinaX5UAUdz0iUTA7qT5ekeZ6MurTcss9FcWtYlwk7rHYASk+ws/BwGq1LDtCytqDObK0rRg4QlCVvY3QSzVTllcHij8WOLX6KG78syp/9ATNQ3IxMJqSd9JSS0nSrLO4jG+y9O75/7BaBp2HN5cvxxLWPU8TYkut8Kef0fyhZrUu7GG7cdRbm69M6Soqz7HeBR6N4m7xVUDGihxEqRIr99cqjD698nL+mmIkKuCtNShxetpxiAFRWJpb2Qv7DK8VjsAwl4h8etXNibGzWjKJByjRXC2Imu84axxfL+JB9zsiHlAznzfag2brc9GDxcLYYUlyH/HBuIsYXa/npvYPKWZgOP9au2BoE7qPEb/EMy7mdrfF5lc7MlMaEJ9gY11t16EvIhqzzkBANZ9rbW9fuVKsa0gT1PQTsDS9QyCXvU9CXMFMbb/kAx8BYkwSOVbSiWmsvTRXl3or0Lq3VAoE+V6H7cGz/L5F9Vm4ttqV9cvrT0buoqrVzdyPN1StMGpA2pxNjeBERAO5gGlHSHanpHqgONEI3adhzb1YMp/e7Gwk1gTCq7FpmvQzoB42gOjLoH+pCkYMy4vzITSWp1Qv/45ROde77IjgZraUfHUxN9q69ZktFUCQ57Rd/pYNJcFm/94ZNrZ7mlveFjkad7mdjpyoydchqSPIkn2XV5kXASkjKj7fGTt2d2n6DF8Mn2x0LSekSBgp0wOJ6BdOrNU6aQWUunzvGGBAWzTMZk3Iio/HNE5V8="

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