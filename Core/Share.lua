local Private = select(2, ...)

function Private:ExportProfile()
    local serializedData = C_EncodingUtil.SerializeCBOR(Private.DB.global)
    local compressedData = C_EncodingUtil.CompressString(serializedData, Enum.CompressionMethod.Deflate, Enum.CompressionLevel.OptimizeForSize)
    local encodedData = C_EncodingUtil.EncodeBase64(compressedData)

    StaticPopupDialogs["ELVUI_UNHALTED_EXPORT_PROFILE"] = {
        text = "Profile String",
        button1 = "Close",
        OnButton1 = function(popupDialog) popupDialog:Hide() end,
        OnShow = function(popupDialog) popupDialog.EditBox:SetText("!UHUI_" .. encodedData) popupDialog.EditBox:SetFocus() popupDialog.EditBox:HighlightText() end,
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopup_Show("ELVUI_UNHALTED_EXPORT_PROFILE")
end

function Private:ImportProfile()

    StaticPopupDialogs["ELVUI_UNHALTED_IMPORT_PROFILE"] = {
        text = "Importing will overwrite your existing profile.",
        button1 = "Import",
        button2 = "Cancel",
        OnButton1 = function(popupDialog)
            local encodedData = popupDialog.EditBox:GetText()
            if encodedData:sub(1, 6) ~= "!UHUI_" then return Private:PrettyPrint("The profile string you used is incorrect.") end
            local compressedData = C_EncodingUtil.DecodeBase64(encodedData:sub(7))
            local serializedData = compressedData and C_EncodingUtil.DecompressString(compressedData, Enum.CompressionMethod.Deflate)
            if not serializedData then return end
            local importedData = C_EncodingUtil.DeserializeCBOR(serializedData)
            if type(importedData) ~= "table" then return end
            wipe(Private.DB.global)
            for Key, Value in pairs(importedData) do Private.DB.global[Key] = Value end
            ReloadUI()
        end,
        OnShow = function(popupDialog) popupDialog.EditBox:SetFocus() end,
        hasEditBox = true,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    StaticPopup_Show("ELVUI_UNHALTED_IMPORT_PROFILE")

    return true
end
