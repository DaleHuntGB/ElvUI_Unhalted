local Private = select(2, ...)

function Private:SetupAutoDelete()
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self) if self.EditBox and Private.DB.global.QualityOfLife.Toggles.AutoDelete then self.EditBox:SetText("DELETE") end end)
end