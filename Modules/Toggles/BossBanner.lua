local Private = select(2, ...)

function Private:SetupBossBanner()
    if not Private.DB.global.Toggles.HideBossBanner then return end
    _G["BossBanner"]:UnregisterAllEvents()
end