local Private = select(2, ...)

local ImportString = "!UHUI_7VhNbxtFGF5jIXFAatWTC1KxitoLtHLSUkEPTeL1fsVer+PdiICQrMnu2B663jGzs0lcFalq2v9AOUHalI/yA+DUSkicQOKCxIED4oY4IcUH5APM7Ie9tuPURUKIij04M7sz7zzv87zvOzP5zNB7tI3smhv4FupA8kXFbOPtIrCvOgR3+6thD/s+9PuKiF0cEH9fNqGNPWd3sPT98fAZLP0cNTKKtNNFBPJvv97hz4epQXFDrRHcItD32aAfc+EzMiBZbUT49J8nZg0NqiLudF1I4e70t+EbuQJ6OKC3pLqmqFb0mxdCb0oQ0LbflyUPbLqwr1qIurAIyP0xzw9kFaJWmx5LxpUsuEPvJb3EfqkiyVb4kxFUGXvURNfg83LE1G4mk1E2jGbTh1RQ3ooaGelN5ND2ycyrWh1vR4vkciEyGROb8Ryu9Kmx0sGBRxtDo3r8YmRbr4IOHA2ohN14GaEc9kaDq/H0GM/paHTcyyZfk9kKxxAQuFZ00bVrgDj5OkBOntFULoEOaEGdCUBufT4eLWNcPZjDg3HIR0Oqpxwq9kQX+P7BBAP6cEXSAVQ74+d/ubGXP+M/jgtrDFhiXAt9tHpdKMwIkr6c6DdvlGTnjZISH3Iz91PuTtlkqYKwx4FkSixm/GcTu+WiYVmGHkZ3uj14+HuSD3Fjtp7/S/iPS/hOqFo2LaQwv4TLzd0L/HlSCQ+eNgkz/7UsfHT161C5v52FT52E2X8zC6clzM4v4eOzUE3e7OnrmkQIJr5MGF13J52QRanKjiTxHyH3fklFDjzYeFF0IfCMzXehTdEWtAgjB5Ii8DxI+qsrjmN45lXk+R8rxaBlso9TllXLqIW4h41RGUkaER8nTlR05KEO6JoUUP9e2ez5FHbCzicjZjUTdiEBFBORBUB1vesACjWPqbkF3Oxw+ShMZLlmNnQzAbMa8cjFSjWzz6TUUivYBpRJMiW0whzgw5O/2dMjUGUeOWaw+Tb2eJywU+v94ccTExhzpyYtz4B1PHZCXLyophDWNc+nwLNhCTWbyA5c2ptifQrr+RFWXUe+DV0XeBAH/r06O7tuAlqHfkAIl/kQ18fDY7D0VbKVx43Kime3MakBAj1akdytdblRc0EPkihnRosrYhuQFvRvHnVSPuqkLk/mf4qZcuRKeGnYn41p1TBEowtsRHuDpR9Ofbn22+2XZmf1YPm5b/nz3dDb0Ke7qVyPIEmFwuVCIQ1HZ/xCkV1PMNmPcz43Kiczck+ILdzK8NoRp7YmrtdNo94oLGgiYVefNkCJSUZJXJmfxGBFrBumqa5ozOaivOJCwjJOjvh7jPzCYLn+TZM/ERGSxAN7L+wor0QmEhaOunIl/B0rSTuIxvPPTc6fGSSqil2HS/3HFUGv4W1INK8Z8GK6L5ms4jsbL1+3ZflS4fWCLK97beBS6Fwnl/MKBjRfZHWNIq81b6QvN+TQ5UpomgUxq4CurANWoUgs7dnc2VWOx2S3TeDuHzZy7tWcqLJHjpSqrKqMFtE0Xn23WEU5ao0Z0ZBaA9mz11As3Gq50L+/uhJQXIL8btsP2yZqeevdvsH3Bwu4rPi3VAicfpW/4LfyeHNY4/0K6xtNkQlNsNuvsq2iKyIPsmRBtt+XeFJqd8sVjGkdu66MdvpmWCVJ0KWGJ2KmMN72+rKOtyDxHyhswkqxsTBZ7m6P7ZWh1Sjt5eh9vNF8IOReUBrzTamdWzhfeCP1FBcvbeSiKmLxCkZFxvYmICG0vUlASd2tpGekavsQ0XAPrMYVCtIxiwczLMaVbGRxZClm6dIUqFkuH3a6KMQHxI8ysbmLU+ZSiyfCjPb4ZPawsZbGfThp0b9E1kxRbygEB92ogDcWojL86MpJbunG4GEYwTeEeNHFKTulNCRpHE8y68I87iScC5NkvDY1O06vsUhKyuWj7fdCsWsRBTK2A/9wBtJKzBI6L6ylg+pwQyEF00zGZCxHVP45pPIv"

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