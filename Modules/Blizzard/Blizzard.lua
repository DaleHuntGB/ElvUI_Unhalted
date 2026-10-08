local Private = select(2, ...)

function Private:SetupBlizzard()
    Private:SetupActionStatusFrame()
    Private:SetupBetterPrey()
    Private:SetupMovableWindows()
    Private:SetupUIErrorsFrame()
    Private:SetupZoneText()
end
