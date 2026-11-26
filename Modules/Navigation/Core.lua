local Private = select(2, ...)

local function Navigation_OnEvent()
    local KnownTaxiNodes = Private.DB.global.Miscellaneous.Navigation.TaxiNodes[Private.DB.keys.char]
    for _, TaxiNode in ipairs(C_TaxiMap.GetAllTaxiNodes(GetTaxiMapID())) do
        if TaxiNode.slotIndex and Private.NavigationTaxiNodes[TaxiNode.nodeID] then
            local NodeType = TaxiNodeGetType(TaxiNode.slotIndex)
            KnownTaxiNodes[TaxiNode.nodeID] = (NodeType == "CURRENT" or NodeType == "REACHABLE") or nil
        end
    end
    Private:DrawNavigationMap()
end

function Private:UpdateNavigation()
    local NavigationFrame = Private.NavigationFrame
    if not NavigationFrame then return end
    local DB = Private.DB.global.Miscellaneous.Navigation

    Private:UpdateNavigationArrow()
    Private:DrawNavigationMap()
    Private:UpdateAvailableQuests()
    Private:UpdateInstancePortals()
    Private:UpdateLevelZones()
    Private:UpdateQuestObjectives()

    if DB.Enable then
        NavigationFrame:RegisterEvent("TAXIMAP_OPENED")
        NavigationFrame:SetScript("OnEvent", Navigation_OnEvent)
    else
        NavigationFrame:UnregisterAllEvents()
        NavigationFrame:SetScript("OnEvent", nil)
    end
end

function Private:SetupNavigation()
    Private.NavigationFrame = CreateFrame("Frame")
    Private:SetupNavigationArrow()
    Private:SetupNavigationMap()
    Private:SetupAvailableQuests()
    Private:SetupInstancePortals()
    Private:SetupLevelZones()
    Private:SetupQuestObjectives()
    Private:UpdateNavigation()
end
