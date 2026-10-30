local Private = select(2, ...)

function Private:SetupLossOfControl()
    if not Private.DB.global.Toggles.HideLossOfControl then return end
    local EF = CreateFrame("Frame")
    EF:RegisterEvent("LOSS_OF_CONTROL_ADDED")
    EF:SetScript("OnEvent", function(_, e) if e == "LOSS_OF_CONTROL_ADDED" then _G["LossOfControlFrame"]:Hide() end end)
end