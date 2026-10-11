local Private = select(2, ...)
local EventFrame

Private.CVarOptions = {
    {Type = "Toggle", Label = "Floating Combat Text: |cFFFF4040Damage|r", CVar = "floatingCombatTextCombatDamage_v2", Desc = "Displays floating combat damage."},
    {Type = "Toggle", Label = "Floating Combat Text: |cFF40FF40Healing|r", CVar = "floatingCombatTextCombatHealing_v2", Desc = "Displays floating combat healing."},
    {Type = "Toggle", Label = "Death Effects", CVar = "ffxDeath", Desc = "Displays death overlay and desaturation."},
    {Type = "Toggle", Label = "Fullscreen Glow", CVar = "ffxGlow", Desc = "Displays fullscreen glow effect."},
    {Type = "Toggle", Label = "Sharpen Textures", CVar = "ResampleAlwaysSharpen", Desc = "Sharpens textures."},
    {Type = "Toggle", Label = "Auto Loot", CVar = "autoLootDefault", Desc = "Automatically loots."},
    {Type = "Toggle", Label = "Show Tutorials", CVar = "showTutorials", Desc = "Show general tutorials."},
    {Type = "Toggle", Label = "Show New Player Tutorials", CVar = "showNPETutorials", Desc = "Show new-player tutorials."},
    {Type = "Toggle", Label = "Show World Map Coordinates", CVar = "worldMapShowPlayerCoords", LinkedCVar = "worldMapShowCursorCoords", Desc = "Show world map player and cursor coordinates."},
    {Type = "Slider", Label = "Spell Queue Window", CVar = "SpellQueueWindow", Min = 0, Max = 400, Step = 1},
    {Type = "Slider", Label = "Raid: Water Detail", CVar = "RAIDWaterDetail", Min = 0, Max = 3, Step = 1},
    {Type = "Slider", Label = "Raid: Weather Density", CVar = "RAIDweatherDensity", Min = 0, Max = 3, Step = 1},
    {Type = "Slider", Label = "Auto Loot: Rate", CVar = "autoLootRate", Min = 0, Max = 150, Step = 1},
}

local CVarNames = {}
for _, Option in ipairs(Private.CVarOptions) do
    CVarNames[string.lower(Option.CVar)] = Option.CVar
    if Option.LinkedCVar then CVarNames[string.lower(Option.LinkedCVar)] = Option.LinkedCVar end
end

function Private:SetCVar(Name, Value)
    if C_CVar.GetCVar(Name) == nil then return end
    Value = type(Value) == "boolean" and (Value and "1" or "0") or tostring(Value)
    if C_CVar.SetCVar(Name, Value) and Private.DB.global.CVars.Sync then
        Private.DB.global.CVars.Values[Name] = C_CVar.GetCVar(Name)
    end
end

function Private:UpdateCVarSync()
    local DB = Private.DB.global.CVars
    if DB.Sync then
        DB.Values = {}
        for _, Name in pairs(CVarNames) do DB.Values[Name] = C_CVar.GetCVar(Name) end
    end
    Private:SetupCVars()
end

function Private:SetupCVars()
    local DB = Private.DB.global.CVars
    if not DB.Sync and not EventFrame then return end
    if not EventFrame then
        EventFrame = CreateFrame("Frame")
        EventFrame:SetScript("OnEvent", function(_, Event, Name)
            if Event == "VARIABLES_LOADED" then
                Private:SetupCVars()
            elseif Private.DB.global.CVars.Sync then
                Name = CVarNames[string.lower(Name)]
                if Name then Private.DB.global.CVars.Values[Name] = C_CVar.GetCVar(Name) end
            end
        end)
    end
    EventFrame:UnregisterAllEvents()
    if not DB.Sync then return end
    if not C_CVar.AreCVarsLoaded() then EventFrame:RegisterEvent("VARIABLES_LOADED") return end
    for _, Name in pairs(CVarNames) do
        local Value = DB.Values[Name]
        local Current = C_CVar.GetCVar(Name)
        if Value ~= nil and Current ~= nil and Current ~= Value then C_CVar.SetCVar(Name, Value) end
    end
    EventFrame:RegisterEvent("CVAR_UPDATE")
end
