local Private = select(2, ...)


function Private:SetupRemoveLossOfControlFrame()
    if not Private.DB.global.QualityOfLife.Toggles.RemoveLossOfControlFrame then return end
    local Frame = _G.LossOfControlFrame
    if Frame then
        Frame:UnregisterAllEvents()
    end
end