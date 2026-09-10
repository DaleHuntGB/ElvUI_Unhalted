local Private = select(2, ...)


function Private:SetupRemoveBossBanner()
    if not Private.DB.global.QualityOfLife.Toggles.RemoveBossBanner then return end
    local Frame = _G.BossBanner
    if Frame then
        Frame:UnregisterAllEvents()
    end
end