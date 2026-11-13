local Private = select(2, ...)

local SpellRanks = {
    ArcaneShot = { 14287, 14286, 14285, 14284, 14283, 14282, 14281, 3044 },
    AspectOfTheBeast = { 1299447, 1299446, 1299445, 13161 },
    AspectOfTheHawk = { 25296, 14322, 14321, 14320, 14319, 14318, 13165 },
    AspectOfTheWild = { 20190, 20043 },
    Disengage = { 14273, 14272, 781 },
    DistractingShot = { 15632, 15631, 15630, 15629, 14274, 20736 },
    ExplosiveTrap = { 14317, 14316, 13813 },
    FreezingTrap = { 14311, 14310, 1499 },
    HuntersMark = { 14325, 14324, 14323, 1130 },
    ImmolationTrap = { 14305, 14304, 14303, 14302, 13795 },
    ScareBeast = { 14327, 14326, 1513 },
    SerpentSting = { 25295, 13555, 13554, 13553, 13552, 13551, 13550, 13549, 1978 },
    SummonHawk = { 1293241, 1293525, 1293526, 1293527 },
    ViperSting = { 14280, 14279, 3034 },
    Volley = { 14295, 14294, 1510 },
    WingClip = { 14268, 14267, 2974 },
}

local OptimalSpells, GlowingButtons = {}, {}
local isHooked = false

local function UpdateOptimalSpells()
    wipe(OptimalSpells)
    for _, Ranks in pairs(SpellRanks) do
        for _, SpellID in ipairs(Ranks) do
            if C_SpellBook.IsSpellKnown(SpellID) then
                OptimalSpells[SpellID] = true
                break
            end
        end
    end
end

local function UpdateGlows()
    local CustomGlow = Private.E.Libs.CustomGlow
    local isEnabled = Private.DB.global.Miscellaneous.Hunter.HighlightOptimalRanks
    if isEnabled then UpdateOptimalSpells() end

    for _, Frame in PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame:EnumerateFrames() do
        if Frame.HasValidData and Frame.Button then
            local Info = Frame:HasValidData() and Frame.spellBookItemInfo
            local isOptimal = (isEnabled and Info and OptimalSpells[Info.spellID]) == true
            if isOptimal ~= (GlowingButtons[Frame.Button] == true) then
                if isOptimal then CustomGlow.ShowOverlayGlow(Frame.Button) else CustomGlow.HideOverlayGlow(Frame.Button) end
                GlowingButtons[Frame.Button] = isOptimal or nil
            end
        end
    end
end

function Private:UpdateOptimalRanks()
    if isHooked then UpdateGlows() end
end

function Private:SetupOptimalRanks()
    if Private.E.myclass ~= "HUNTER" then return end

    EventUtil.ContinueOnAddOnLoaded("Blizzard_PlayerSpells", function()
        hooksecurefunc(PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame, "DisplayViewsForCurrentPage", UpdateGlows)
        isHooked = true
    end)
end
