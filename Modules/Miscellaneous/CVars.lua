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
    cameraDistanceMaxZoomFactor = "Sliders",
    nameplateMaxDistance = "Sliders"
}

local FallbackMaxNameplateDistance = 41

function Private:GetMaxNameplateDistance()
    local MaxDistance = C_GameRules.GetGameRuleAsFloat(Enum.GameRule.MaxNameplateDistance)
    return MaxDistance > 0 and MaxDistance or FallbackMaxNameplateDistance
end

function Private:SyncCVars()
    local DB = Private.DB.global.Miscellaneous.CVars
    if not DB.Sync then return end

    for CVar, Group in pairs(CVars) do
        local Current = C_CVar.GetCVar(CVar)
        if DB[Group][CVar] == nil then
            DB[Group][CVar] = Current
        end

        if tostring(DB[Group][CVar]) ~= Current then Private:SetCVar(CVar, DB[Group][CVar]) end
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