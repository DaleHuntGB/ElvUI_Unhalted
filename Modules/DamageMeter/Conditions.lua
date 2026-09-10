local Private = select(2, ...)

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ZONE_CHANGED")
EventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
EventFrame:SetScript("OnEvent", function()
    if not Private.DamageMeterFrames then return end

    local _, InstanceType = IsInInstance()
    local Condition = InstanceType == "none" and "OpenWorld" or InstanceType == "party" and "Dungeon" or InstanceType == "raid" and "Raid"
    if not Condition then return end

    for _, DMFrame in pairs(Private.DamageMeterFrames) do
        local DB = DMFrame.DB
        if DB.Enabled and DB.Conditions.Enabled then
            local Options = DB.Conditions[Condition]
            Private:SetDamageMeterType(DMFrame, Options[2], Options[1])
        end
    end
end)
