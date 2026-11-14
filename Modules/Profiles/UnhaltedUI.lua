local Private = select(2, ...)

local ImportString = "!UHUI_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"

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