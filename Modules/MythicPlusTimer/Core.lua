local Private = select(2, ...)
Private.MythicPlusTimerPreview = false

function Private:SetupMythicPlusTimer()
    if Private.isForever then return end
    local DB = Private.DB.global.MythicPlusTimer
    if DB.Enable then
        Private.MythicPlusTimerFrame = Private:CreateMythicPlusWindow(DB)
    end
end

function Private:UpdateMythicPlusTimer()
    local DB = Private.DB.global.MythicPlusTimer
    local Frame = Private.MythicPlusTimerFrame
    if Frame then
        Private:UpdateMythicPlusWindow(Frame, DB)
    elseif DB.Enable then
        Private.MythicPlusTimerFrame = Private:CreateMythicPlusWindow(DB)
    end
end
