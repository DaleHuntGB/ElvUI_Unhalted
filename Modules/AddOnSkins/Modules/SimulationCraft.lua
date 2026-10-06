local Private = select(2, ...)

function Private:SetupSimulationCraftSkin()
    if not Private.DB.global.AddOnSkins.SimulationCraft.Enable then return end
    if not C_AddOns.IsAddOnLoaded("SimulationCraft") then return end

    local DB = Private.DB.global.AddOnSkins.SimulationCraft

    local DBIcon = LibStub("LibDBIcon-1.0", true)
    if not DBIcon then return end

    local function SkinButton(Button)
        if Button.Border then return end

        local Highlight = Button:GetHighlightTexture()
        for _, Region in ipairs({ Button:GetRegions() }) do
            if Region:IsObjectType("Texture") and Region ~= Button.icon and Region ~= Highlight then
                Region:Hide()
            end
        end

        Button.Border = Button:CreateTexture(nil, "BACKGROUND")
        Button.Border:SetAllPoints(Button)
        Button.Border:SetColorTexture(0, 0, 0, 1)

        Button.icon:ClearAllPoints()
        Button.icon:SetPoint("TOPLEFT", Button, "TOPLEFT", 1, -1)
        Button.icon:SetPoint("BOTTOMRIGHT", Button, "BOTTOMRIGHT", -1, 1)

        Highlight:SetColorTexture(1, 1, 1, 0.15)
        Highlight:ClearAllPoints()
        Highlight:SetAllPoints(Button.icon)

        DBIcon:Lock("SimulationCraft")
        Button:ClearAllPoints()
        Button:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Button:SetMovable(false)
        Button:SetSize(DB.Size[1], DB.Size[2])

        local SetPoint = Button.SetPoint
        hooksecurefunc(Button, "SetPoint", function()
            local _DB = Private.DB.global.AddOnSkins.SimulationCraft
            Button:ClearAllPoints()
            SetPoint(Button, _DB.Layout[1], _G["Minimap"], _DB.Layout[2], _DB.Layout[3], _DB.Layout[4])
        end)

        Button:HookScript("OnEnter", function()
            local Tooltip = DBIcon.tooltip
            if not Tooltip:IsOwned(Button) then return end
            Tooltip:ClearAllPoints()
            Tooltip:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -2, -1)
        end)
    end

    local Button = DBIcon:GetMinimapButton("SimulationCraft")

    if Button then
        SkinButton(Button)
    else
        DBIcon.RegisterCallback("ElvUI_Unhalted_SimulationCraftSkin", "LibDBIcon_IconCreated", function(_, CreatedButton, Name) if Name ~= "SimulationCraft" then return end SkinButton(CreatedButton) DBIcon.UnregisterCallback(Private, "LibDBIcon_IconCreated") end)
    end

end

function Private:UpdateSimulationCraftSkin()
    local DB = Private.DB.global.AddOnSkins.SimulationCraft
    local DBIcon = LibStub("LibDBIcon-1.0", true)
    if not DBIcon then return end

    local Button = DBIcon:GetMinimapButton("SimulationCraft")

    if Button then
        Button:ClearAllPoints()
        Button:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Button:SetSize(DB.Size[1], DB.Size[2])
    end
end