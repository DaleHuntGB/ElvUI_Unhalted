local Private = select(2, ...)

function Private:UpdateMythicPlusTracker(Frame, Hidden)
    if not ObjectiveTrackerFrame or Frame.TrackerHidden == Hidden then return end
    ObjectiveTrackerFrame:SetRolesets(Hidden and "alwaysBlocked" or "objectives")
    Frame.TrackerHidden = Hidden
end
