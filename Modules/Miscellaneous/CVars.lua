local Private = select(2, ...)

local CVars = {
    floatingCombatTextCombatDamage_v2 = "Toggles",
    floatingCombatTextCombatHealing_v2 = "Toggles",
    ResampleAlwaysSharpen = "Toggles",
    showTutorials = "Toggles",
    showNPETutorials = "Toggles",
    housingTutorialsEnabled = "Toggles",
    ffxDeath = "Toggles",
    ffxGlow = "Toggles",
    ffxLingeringVenari = "Toggles",
    ffxNether = "Toggles",
    ffxVenari = "Toggles",
    WorldTextScale_v2 = "Sliders",
    RAID_WaterDetail = "Sliders",
    RAIDweatherDensity = "Sliders",
    autoLootRate = "Sliders",
    SpellQueueWindow = "Sliders",
    cameraDistanceMaxZoomFactor = "Sliders"
}

function Private:SyncCVars()
    local DB = Private.DB.global.Miscellaneous.CVars
    if not DB.Sync then return end

    for CVar, Group in pairs(CVars) do
        if DB[Group][CVar] == nil then
            DB[Group][CVar] = C_CVar.GetCVar(CVar)
        end

        Private:SetCVar(CVar, DB[Group][CVar])
    end
end

function Private:SetCVar(CVar, Value)
    if Value == nil then return end

    local DB = Private.DB.global.Miscellaneous.CVars
    C_CVar.SetCVar(CVar, Value)

    if DB.Sync then
        DB[CVars[CVar]][CVar] = Value
    end
end