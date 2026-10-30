local Private = select(2, ...)

function Private:SkipCinematics()
    local EF = CreateFrame("Frame")
    EF:RegisterEvent("CINEMATIC_START")
    EF:HookScript("OnEvent", function(_, e, ...) if e == "CINEMATIC_START" then if not Private.DB.global.Toggles.SkipCinematics then return end CinematicFrame_CancelCinematic() end end)
end