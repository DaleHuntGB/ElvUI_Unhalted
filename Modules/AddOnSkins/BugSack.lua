local Private = select(2, ...)

function Private:SetupBugSack()
    if not Private.DB.global.AddOnSkins.BugSack then return end
    if not C_AddOns.IsAddOnLoaded("BugSack") then return end

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
    end

    local Button = DBIcon:GetMinimapButton("BugSack")

    if Button then
        SkinButton(Button)
        Button:ClearAllPoints()
        Button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -1, -1)
        Button:SetMovable(false)
        Button:SetSize(18, 18)
    else
        DBIcon.RegisterCallback(Private, "LibDBIcon_IconCreated", function(_, CreatedButton, Name)
            if Name ~= "BugSack" then return end
            SkinButton(CreatedButton)
            DBIcon.UnregisterCallback(Private, "LibDBIcon_IconCreated")
        end)
    end
end
