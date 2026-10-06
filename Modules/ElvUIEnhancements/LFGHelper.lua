local Private = select(2, ...)
local LFGHelperFrame;
local EventFrame;
local RefreshTimer;

local function UpdateLFGHelperFilters()
    if not LFGHelperFrame or not Private.DB.global.ElvUIEnhancements.LFGHelper then return end
    local Filters = C_LFGList.GetAdvancedFilter()
    local Activities = {}
    for _, GroupID in ipairs(Filters.activities) do Activities[GroupID] = true end

    for _, Button in ipairs(LFGHelperFrame.Buttons) do
        local Selected
        if Button.GroupID then
            Selected = Activities[Button.GroupID]
        elseif Button.FilterKey == "AllDungeons" then
            Selected = #Filters.activities == 0
        elseif Button.FilterKey == "PartyFit" then
            Selected = LFGHelperFrame.PartyFit
        else
            Selected = not LFGHelperFrame.PartyFit and Filters[Button.FilterKey]
            Button:SetEnabled(not LFGHelperFrame.PartyFit)
            Button.Text:SetAlpha(LFGHelperFrame.PartyFit and 0.45 or 1)
        end
        if Selected then
            Button:SetBackdropBorderColor(96/255, 128/255, 1, 1)
            Button:SetBackdropColor(96/255, 128/255, 1, 0.25)
        else
            Button:SetBackdropBorderColor(0, 0, 0, 1)
            Button:SetBackdropColor(20/255, 20/255, 20/255, 1)
        end
        if Button.Background then Button.Background:SetAlpha(Selected and 0.4 or 0.25) end
    end
end

local function UpdateLFGHelperKeys()
    if not LFGHelperFrame or not Private.DB.global.ElvUIEnhancements.LFGHelper then return end
    local KeyLevels = {}
    for _, Run in ipairs(C_MythicPlus.GetRunHistory(true, false, true)) do
        KeyLevels[Run.mapChallengeModeID] = math.max(KeyLevels[Run.mapChallengeModeID] or 0, Run.level)
    end
    for _, Button in ipairs(LFGHelperFrame.Buttons) do
        if Button.Level then
            local Level = KeyLevels[Button.MapChallengeModeID] or 0
            Button.Level:SetText(Level > 0 and string.format("+%d", Level) or "-")
        end
    end
end

local function FilterLFGHelperResults(SearchPanel)
    if not LFGHelperFrame or not LFGHelperFrame.PartyFit or not Private.DB.global.ElvUIEnhancements.LFGHelper or not LFGHelperFrame:IsVisible() then return end
    if SearchPanel.categoryID ~= GROUP_FINDER_CATEGORY_ID_DUNGEONS or not LFGHelperFrame.SearchResults then return end
    if InCombatLockdown() then EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") return end

    local Party = LFGHelperFrame.Party
    if not Party then
        Party = {NumMembers = math.max(GetNumGroupMembers(LE_PARTY_CATEGORY_HOME), 1), TANK = 0, HEALER = 0, DAMAGER = 0, KnownRoles = true}
        local IsRaid = IsInRaid(LE_PARTY_CATEGORY_HOME)
        for Index = 1, Party.NumMembers do
            local Unit = IsRaid and "raid" .. Index or (Index == 1 and "player" or "party" .. (Index - 1))
            local Role = Unit == "player" and Private.ElvUI:GetPlayerRole() or UnitGroupRolesAssigned(Unit)
            if Private.ElvUI:NotSecretValue(Role) and Party[Role] then
                Party[Role] = Party[Role] + 1
            else
                Party.KnownRoles = false
            end
        end
        LFGHelperFrame.Party = Party
    end

    local Results = {}
    local Selected;
    local Changed = false
    for _, ResultID in ipairs(LFGHelperFrame.SearchResults) do
        local Info = C_LFGList.GetSearchResultInfo(ResultID)
        local Slots = C_LFGList.GetSearchResultMemberCounts(ResultID)
        local Fits = Party.KnownRoles and Private.ElvUI:NotSecretValue(Info) and Info and canaccesstable(Info)
            and Private.ElvUI:NotSecretValue(Slots) and Slots and canaccesstable(Slots) and Private.ElvUI:NotSecretValue(Info.numMembers)
            and Private.ElvUI:NotSecretValue(Slots.TANK_REMAINING) and Private.ElvUI:NotSecretValue(Slots.HEALER_REMAINING) and Private.ElvUI:NotSecretValue(Slots.DAMAGER_REMAINING)
            and Info.numMembers and Slots.TANK_REMAINING and Slots.HEALER_REMAINING and Slots.DAMAGER_REMAINING
            and Info.numMembers + Party.NumMembers <= 5 and Party.TANK <= Slots.TANK_REMAINING and Party.HEALER <= Slots.HEALER_REMAINING and Party.DAMAGER <= Slots.DAMAGER_REMAINING
        if Fits then
            table.insert(Results, ResultID)
            if SearchPanel.results[#Results] ~= ResultID then Changed = true end
            if SearchPanel.selectedResult == ResultID then Selected = true end
        end
    end
    if #Results ~= #SearchPanel.results then Changed = true end
    if SearchPanel.selectedResult and not Selected then SearchPanel.selectedResult = nil Changed = true end
    SearchPanel.results = Results
    SearchPanel.totalResults = #Results
    return Changed
end

local function QueueLFGHelperResults()
    if RefreshTimer then return end
    RefreshTimer = C_Timer.NewTimer(0.1, function()
        RefreshTimer = nil
        local SearchPanel = LFGListFrame.SearchPanel
        if FilterLFGHelperResults(SearchPanel) then LFGListSearchPanel_UpdateResults(SearchPanel) end
    end)
end

local function ToggleLFGHelperFilter(Button)
    if InCombatLockdown() or not Private.DB.global.ElvUIEnhancements.LFGHelper then return end
    local Filters = C_LFGList.GetAdvancedFilter()
    if Button.FilterKey == "PartyFit" then
        LFGHelperFrame.PartyFit = not LFGHelperFrame.PartyFit
        LFGHelperFrame.Party = nil
        if LFGHelperFrame.PartyFit and (Filters.needsTank or Filters.needsHealer or Filters.needsDamage) then
            Filters.needsTank, Filters.needsHealer, Filters.needsDamage = false, false, false
            C_LFGList.SaveAdvancedFilter(Filters)
        end
        Private:UpdateLFGHelper()
        LFGListSearchPanel_UpdateResultList(LFGListFrame.SearchPanel)
        return
    end
    if LFGHelperFrame.PartyFit and not Button.GroupID and Button.FilterKey ~= "AllDungeons" then return end
    if Button.GroupID then
        local Selected
        for Index, GroupID in ipairs(Filters.activities) do
            if GroupID == Button.GroupID then table.remove(Filters.activities, Index) Selected = true break end
        end
        if not Selected then table.insert(Filters.activities, Button.GroupID) end
    elseif Button.FilterKey == "AllDungeons" then
        Filters.activities = {}
    else
        Filters[Button.FilterKey] = not Filters[Button.FilterKey]
    end
    C_LFGList.SaveAdvancedFilter(Filters)
    LFGListSearchPanel_DoSearch(LFGListFrame.SearchPanel)
end

local function CreateLFGHelperButton(Text, X, Y, Width, FilterKey, GroupID)
    local Button = CreateFrame("Button", nil, LFGHelperFrame, "BackdropTemplate")
    Button:SetTemplate()
    Button:SetPoint("TOPLEFT", LFGHelperFrame, "TOPLEFT", X, Y)
    Button:SetSize(Width, 24)
    Button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    Button:GetHighlightTexture():SetAlpha(0.1)
    Button.FilterKey = FilterKey
    Button.GroupID = GroupID
    Button:SetScript("OnClick", ToggleLFGHelperFilter)

    Button.Text = Button:CreateFontString(nil, "OVERLAY")
    Button.Text:SetFont(Private.ElvUI.media.normFont, 11, "OUTLINE")
    Button.Text:SetPoint("LEFT", Button, "LEFT", 6, 0)
    if GroupID then
        Button.Text:SetJustifyH("LEFT")
        Button.Text:SetTextColor(1, 0.82, 0)
        Button.Level = Button:CreateFontString(nil, "OVERLAY")
        Button.Level:SetFont(Private.ElvUI.media.normFont, 11, "OUTLINE")
        Button.Level:SetPoint("RIGHT", Button, "RIGHT", -6, 0)
        Button.Level:SetWidth(36)
        Button.Level:SetJustifyH("RIGHT")
        Button.Text:SetPoint("RIGHT", Button.Level, "LEFT", -6, 0)
    else
        Button.Text:SetPoint("RIGHT", Button, "RIGHT", -6, 0)
    end
    Button.Text:SetWordWrap(false)
    Button.Text:SetText(Text)
    table.insert(LFGHelperFrame.Buttons, Button)
    return Button
end

local function CreateLFGHelper()
    local SearchPanel = LFGListFrame.SearchPanel
    LFGHelperFrame = CreateFrame("Frame", nil, SearchPanel, "BackdropTemplate")
    LFGHelperFrame:SetTemplate("Transparent")
    LFGHelperFrame:SetPoint("TOPLEFT", PVEFrame, "TOPRIGHT", 1, 0)
    LFGHelperFrame:SetFrameLevel(SearchPanel:GetFrameLevel())
    LFGHelperFrame.Buttons = {}
    Private.LFGHelperFrame = LFGHelperFrame

    CreateLFGHelperButton("All Dungeons", 12, -12, 236, "AllDungeons")

    local Maps = {}
    for _, MapChallengeModeID in ipairs(C_ChallengeMode.GetMapTable()) do
        local Name, _, _, _, _, MapID = C_ChallengeMode.GetMapUIInfo(MapChallengeModeID)
        if MapID then
            Maps[MapID] = Maps[MapID] or {}
            table.insert(Maps[MapID], {Name = Name, MapChallengeModeID = MapChallengeModeID})
        end
    end
    local Filters = bit.bor(Enum.LFGListFilter.CurrentSeason, Enum.LFGListFilter.PvE)
    local Groups = C_LFGList.GetAvailableActivityGroups(GROUP_FINDER_CATEGORY_ID_DUNGEONS, Filters)
    local NumDungeons = 0
    for _, GroupID in ipairs(Groups) do
        local Name = C_LFGList.GetActivityGroupInfo(GroupID)
        if Name then
            local Button = CreateLFGHelperButton(Name, 12, -40 - NumDungeons * 28, 236, nil, GroupID)
            for _, ActivityID in ipairs(C_LFGList.GetAvailableActivities(GROUP_FINDER_CATEGORY_ID_DUNGEONS, GroupID, Filters)) do
                local Activity = C_LFGList.GetActivityInfoTable(ActivityID)
                if Activity and Activity.isMythicPlusActivity and not Button.Background then
                    local InstanceID = C_EncounterJournal.GetInstanceForGameMap(Activity.mapID)
                    local Image = InstanceID and select(4, EJ_GetInstanceInfo(InstanceID))
                    if Image then
                        Button.Background = Button:CreateTexture(nil, "ARTWORK")
                        Button.Background:SetPoint("TOPLEFT", Button, "TOPLEFT", 1, -1)
                        Button.Background:SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -1, 1)
                        Button.Background:SetTexture(Image)
                        -- Center-crop the journal's 175x95 artwork inside the rectangular row.
                        local Crop = (95 - 175 * (Button:GetHeight() - 2) / (Button:GetWidth() - 2)) / 256
                        Button.Background:SetTexCoord(0, 175/256, Crop, 95/128 - Crop)
                    end
                end
                local ChallengeMaps = Activity and Activity.isMythicPlusActivity and Maps[Activity.mapID]
                if ChallengeMaps then
                    for _, Map in ipairs(ChallengeMaps) do
                        if #ChallengeMaps == 1 or Map.Name == Name then Button.MapChallengeModeID = Map.MapChallengeModeID break end
                    end
                end
                if Button.MapChallengeModeID then break end
            end
            NumDungeons = NumDungeons + 1
        end
    end

    local Y = -44 - NumDungeons * 28
    CreateLFGHelperButton(INLINE_TANK_ICON .. " Tank", 12, Y, 76, "needsTank")
    CreateLFGHelperButton(INLINE_HEALER_ICON .. " Healer", 92, Y, 76, "needsHealer")
    CreateLFGHelperButton(INLINE_DAMAGER_ICON .. " DPS", 172, Y, 76, "needsDamage")
    CreateLFGHelperButton("Party Fit", 12, Y - 28, 236, "PartyFit")
    LFGHelperFrame:SetSize(260, -Y + 64)
    LFGHelperFrame:Hide()

    SearchPanel:HookScript("OnShow", function() Private:UpdateLFGHelper() end)
    SearchPanel:HookScript("OnHide", function() Private:UpdateLFGHelper() end)
    hooksecurefunc("LFGListSearchPanel_SetCategory", function() Private:UpdateLFGHelper() end)
    hooksecurefunc(C_LFGList, "SaveAdvancedFilter", UpdateLFGHelperFilters)
    hooksecurefunc("LFGListUtil_SortSearchResults", function(SearchPanel)
        if not LFGHelperFrame.PartyFit or not Private.DB.global.ElvUIEnhancements.LFGHelper or SearchPanel ~= LFGListFrame.SearchPanel or SearchPanel.categoryID ~= GROUP_FINDER_CATEGORY_ID_DUNGEONS then return end
        if RefreshTimer then RefreshTimer:Cancel() RefreshTimer = nil end
        LFGHelperFrame.SearchResults = SearchPanel.results
        FilterLFGHelperResults(SearchPanel)
    end)
end

function Private:UpdateLFGHelper()
    local Enabled = Private.DB.global.ElvUIEnhancements.LFGHelper
    if not Enabled and not LFGHelperFrame and not EventFrame then return end
    if not EventFrame then
        EventFrame = CreateFrame("Frame")
        EventFrame:SetScript("OnEvent", function(_, Event)
            if Event == "CHALLENGE_MODE_MAPS_UPDATE" then
                UpdateLFGHelperKeys()
            elseif Event == "GROUP_ROSTER_UPDATE" or Event == "PLAYER_ROLES_ASSIGNED" or Event == "PLAYER_SPECIALIZATION_CHANGED" then
                LFGHelperFrame.Party = nil
                QueueLFGHelperResults()
            elseif Event == "LFG_LIST_SEARCH_RESULT_UPDATED" then
                QueueLFGHelperResults()
            else
                Private:UpdateLFGHelper()
            end
        end)
    end
    EventFrame:UnregisterAllEvents()
    if RefreshTimer then RefreshTimer:Cancel() RefreshTimer = nil end
    if InCombatLockdown() then EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") return end

    local SearchPanel = LFGListFrame and LFGListFrame.SearchPanel
    if Enabled and not SearchPanel then EventFrame:RegisterEvent("ADDON_LOADED") return end
    local Show = Enabled and SearchPanel:IsVisible() and SearchPanel.categoryID == GROUP_FINDER_CATEGORY_ID_DUNGEONS
    if Enabled and not LFGHelperFrame then CreateLFGHelper() end
    if not LFGHelperFrame then return end

    if Show then
        local WasShown = LFGHelperFrame:IsShown()
        LFGHelperFrame:Show()
        UpdateLFGHelperFilters()
        UpdateLFGHelperKeys()
        EventFrame:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
        if LFGHelperFrame.PartyFit then
            EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
            EventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
            EventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
            EventFrame:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
            if not WasShown then
                LFGHelperFrame.Party = nil
                LFGListSearchPanel_UpdateResultList(SearchPanel)
            elseif LFGHelperFrame.SearchResults then
                QueueLFGHelperResults()
            end
        else
            LFGHelperFrame.Party = nil
            LFGHelperFrame.SearchResults = nil
        end
        if not WasShown then C_MythicPlus.RequestMapInfo() end
    else
        LFGHelperFrame:Hide()
        LFGHelperFrame.Party = nil
        LFGHelperFrame.SearchResults = nil
        if not Enabled and LFGHelperFrame.PartyFit then
            LFGHelperFrame.PartyFit = false
            LFGListSearchPanel_UpdateResultList(SearchPanel)
        end
    end
end
