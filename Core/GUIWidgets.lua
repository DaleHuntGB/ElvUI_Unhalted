local Private = select(2, ...)
local ACH = Private.ACH
local AG = Private.AG

AG:RegisterWidgetType("Notice", function()
    local Widget = AG:Create("Label")
    local OnAcquire = Widget.OnAcquire
    local SetText = Widget.SetText
    local SetFontObject = Widget.SetFontObject
    local NoticeFont = CreateFont("UHNoticeFont" .. AG:GetNextWidgetNum("Notice"))

    Widget.type = "Notice"

    Widget.SetText = function(self, Text)
        SetText(self, Text and "|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\InfoButton.png:12:12|t " .. Text or "")
    end

    Widget.SetFontObject = function(self, FontObject)
        NoticeFont:CopyFontObject(FontObject or GameFontHighlightSmall)

        local FontPath, FontSize = NoticeFont:GetFont()
        NoticeFont:SetFont(FontPath, FontSize, "OUTLINE, SLUG")

        SetFontObject(self, NoticeFont)
    end

    Widget.SetCustomData = function(self, Data)
        if Data.isImportant then
            self:SetColor(204/255, 64/255, 64/255)
        else
            self:SetColor(1, 1, 1)
        end
    end

    Widget.OnAcquire = function(self)
        OnAcquire(self)
        self:SetJustifyH("CENTER")
    end

    return Widget
end, 2)

function ACH:Notice(name, order, isImportant, fontSize, width, hidden)
    local Notice = self:Description(name, order, fontSize, nil, nil, nil, nil, width, hidden)
    Notice.dialogControl = "Notice"
    Notice.arg = { isImportant = isImportant }
    return Notice
end
