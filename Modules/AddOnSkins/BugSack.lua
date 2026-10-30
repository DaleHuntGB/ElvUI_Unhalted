local Private = select(2, ...)

local function SkinButton(DB, Button)
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

    Private.LibDBIcon:Lock("BugSack")
    Button:ClearAllPoints()
    Button:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Button:SetMovable(false)
    Button:SetSize(DB.Size[1], DB.Size[2])

    local SetPoint = Button.SetPoint
    hooksecurefunc(Button, "SetPoint", function() local _DB = Private.DB.global.AddOnSkins.BugSack Button:ClearAllPoints() SetPoint(Button, _DB.Layout[1], _G["Minimap"], _DB.Layout[2], _DB.Layout[3], _DB.Layout[4]) end)
    Button:HookScript("OnEnter", function() local Tooltip = Private.LibDBIcon.tooltip if not Tooltip:IsOwned(Button) then return end Tooltip:ClearAllPoints() Tooltip:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -2, -1) end)
end

function Private:SetupBugSackSkin()
    if not Private.DB.global.AddOnSkins.BugSack.Enable then return end
    if not C_AddOns.IsAddOnLoaded("BugSack") then return end

    local DB = Private.DB.global.AddOnSkins.BugSack
    if not Private.LibDBIcon then return end

    local Button = Private.LibDBIcon:GetMinimapButton("BugSack")

    if Button then
        SkinButton(DB, Button)
    else
        Private.LibDBIcon.RegisterCallback("ElvUI_Unhalted_BugSackSkin", "LibPrivate.LibDBIcon_IconCreated", function(_, CreatedButton, Name) if Name ~= "BugSack" then return end SkinButton(DB, CreatedButton) Private.LibDBIcon.UnregisterCallback(Private, "LibPrivate.LibDBIcon_IconCreated") end)
    end

end

function Private:UpdateBugSackSkin()
    local DB = Private.DB.global.AddOnSkins.BugSack
    if not Private.LibDBIcon then return end

    local Button = Private.LibDBIcon:GetMinimapButton("BugSack")

    if Button then
        Button:ClearAllPoints()
        Button:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Button:SetSize(DB.Size[1], DB.Size[2])
    end
end