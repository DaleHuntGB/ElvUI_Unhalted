local Private = select(2, ...)

function Private:SetupTalkingHead()
    if Private.isForever then return end
    if not Private.DB.global.Toggles.HideTalkingHead then return end
    local EF = CreateFrame("Frame")
    EF:RegisterEvent("TALKINGHEAD_REQUESTED")
    EF:SetScript("OnEvent", function(_, e) if e == "TALKINGHEAD_REQUESTED" then _G["TalkingHeadFrame"]:Hide() end end)
end