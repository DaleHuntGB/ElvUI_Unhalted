local Private = select(2, ...)

function Private:SetupCVars()
    if not Private.DB.global.CVars.SyncCVars then return end
    -- Toggles
    C_CVar.SetCVar("autoLootDefault", Private.DB.global.CVars.autoLootDefault and "1" or "0")
    C_CVar.SetCVar("floatingCombatTextCombatDamage_v2", Private.DB.global.CVars.floatingCombatTextCombatDamage_v2 and "1" or "0")
    C_CVar.SetCVar("floatingCombatTextCombatHealing_v2", Private.DB.global.CVars.floatingCombatTextCombatHealing_v2 and "1" or "0")
    C_CVar.SetCVar("ffxDeath", Private.DB.global.CVars.ffxDeath and "1" or "0")
    C_CVar.SetCVar("ffxGlow", Private.DB.global.CVars.ffxGlow and "1" or "0")
    C_CVar.SetCVar("ResampleAlwaysSharpen", Private.DB.global.CVars.ResampleAlwaysSharpen and "1" or "0")
    C_CVar.SetCVar("AutoPushSpellToActionBar", Private.DB.global.CVars.AutoPushSpellToActionBar and "1" or "0")
    C_CVar.SetCVar("showTutorials", Private.DB.global.CVars.showTutorials and "1" or "0")
    C_CVar.SetCVar("worldMapShowCursorCoords", Private.DB.global.CVars.worldMapShowCursorCoords and "1" or "0")
    C_CVar.SetCVar("worldMapShowPlayerCoords", Private.DB.global.CVars.worldMapShowPlayerCoords and "1" or "0")
    -- Sliders
    C_CVar.SetCVar("SpellQueueWindow", Private.DB.global.CVars.SpellQueueWindow)
    C_CVar.SetCVar("RAIDWaterDetail", Private.DB.global.CVars.RAIDWaterDetail)
    C_CVar.SetCVar("RAIDweatherDensity", Private.DB.global.CVars.RAIDweatherDensity)
    C_CVar.SetCVar("autoLootRate", Private.DB.global.CVars.autoLootRate)
end

function Private:SyncCVars()
    if not Private.DB.global.CVars.SyncCVars then return end

    Private.DB.global.CVars.autoLootDefault = C_CVar.GetCVarBool("autoLootDefault")
    Private.DB.global.CVars.floatingCombatTextCombatDamage_v2 = C_CVar.GetCVarBool("floatingCombatTextCombatDamage_v2")
    Private.DB.global.CVars.floatingCombatTextCombatHealing_v2 = C_CVar.GetCVarBool("floatingCombatTextCombatHealing_v2")
    Private.DB.global.CVars.ffxDeath = C_CVar.GetCVarBool("ffxDeath")
    Private.DB.global.CVars.ffxGlow = C_CVar.GetCVarBool("ffxGlow")
    Private.DB.global.CVars.ResampleAlwaysSharpen = C_CVar.GetCVarBool("ResampleAlwaysSharpen")
    Private.DB.global.CVars.AutoPushSpellToActionBar = C_CVar.GetCVarBool("AutoPushSpellToActionBar")
    Private.DB.global.CVars.showTutorials = C_CVar.GetCVarBool("showTutorials")
    Private.DB.global.CVars.worldMapShowCursorCoords = C_CVar.GetCVarBool("worldMapShowCursorCoords")
    Private.DB.global.CVars.worldMapShowPlayerCoords = C_CVar.GetCVarBool("worldMapShowPlayerCoords")
    Private.DB.global.CVars.SpellQueueWindow = tonumber(C_CVar.GetCVar("SpellQueueWindow"))
    Private.DB.global.CVars.RAIDWaterDetail = tonumber(C_CVar.GetCVar("RAIDWaterDetail"))
    Private.DB.global.CVars.RAIDweatherDensity = tonumber(C_CVar.GetCVar("RAIDweatherDensity"))
    Private.DB.global.CVars.autoLootRate = tonumber(C_CVar.GetCVar("autoLootRate"))
end