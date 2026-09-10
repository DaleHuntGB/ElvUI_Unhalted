local Private = select(2, ...)

function Private:SetupRemoveTalkingHead()
    local EventFrame = CreateFrame("Frame", nil, UIParent)
    EventFrame:SetAllPoints(TalkingHeadFrame)
    EventFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
    EventFrame:HookScript("OnEvent", function(_, event, ...)
        if event == "TALKINGHEAD_REQUESTED" then
            if not Private.DB.global.QualityOfLife.Toggles.RemoveTalkingHead then return end
            TalkingHeadFrame:Hide()
        end
    end)
end