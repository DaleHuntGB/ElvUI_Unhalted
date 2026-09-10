local Private = select(2, ...)

function Private:SetupSkipCinematics()
    local EventFrame = CreateFrame("Frame", nil, UIParent)
    EventFrame:RegisterEvent("CINEMATIC_START")
    EventFrame:HookScript("OnEvent", function(_, event, ...)
        if event == "CINEMATIC_START" then
            if not Private.DB.global.QualityOfLife.Toggles.SkipCinematics then return end
            CinematicFrame_CancelCinematic()
        end
    end)
end