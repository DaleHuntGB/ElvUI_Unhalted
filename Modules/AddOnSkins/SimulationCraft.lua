local Private = select(2, ...)
local S = Private.E:GetModule("Skins")

local function SkinWindow()
    local Frame = _G.SimcFrame
    if not Frame or Frame.UnhaltedSkinned then return end

    Frame:StripTextures()
    Frame:SetTemplate("Transparent")
    S:HandleButton(_G.SimcFrameButton)
    S:HandleScrollBar(_G.SimcScrollFrame.ScrollBar)
    S:HandleCheckBox(_G.AutomaticClose)
    S:HandleCheckBox(_G.SimcOffspecLoadouts)
    _G.SimcEditBox:FontTemplate()
    Frame.UnhaltedSkinned = true
end

local function SkinSimulationCraft()
    local AddOn = LibStub("AceAddon-3.0"):GetAddon("Simulationcraft")
    hooksecurefunc(AddOn, "GetMainFrame", SkinWindow)
    SkinWindow()

    local DBIcon = LibStub("LibDBIcon-1.0")
    local Button

    local function PositionButton()
        if not Button then return end
        local BugSack = DBIcon:GetMinimapButton("BugSack")
        local Point, RelativeTo, RelativePoint, X, Y = "TOPRIGHT", Minimap, "TOPRIGHT", -1, -1
        if BugSack and BugSack:IsShown() then
            Point, RelativeTo, RelativePoint, X, Y = "RIGHT", BugSack, "LEFT", -1, 0
        end

        local CurrentPoint, CurrentRelativeTo, CurrentRelativePoint, CurrentX, CurrentY = Button:GetPoint()
        if CurrentPoint == Point and CurrentRelativeTo == RelativeTo and CurrentRelativePoint == RelativePoint and CurrentX == X and CurrentY == Y then return end
        Button:ClearAllPoints()
        Button:SetPoint(Point, RelativeTo, RelativePoint, X, Y)
    end

    local function IconCreated(_, CreatedButton, Name)
        if Name == "SimulationCraft" then
            Button = CreatedButton
            Button.border:Hide()
            Button.background:Hide()
            Button:SetSize(18, 18)
            Button.icon:SetInside(Button, 1, 1)
            S:HandleIcon(Button.icon, true)
            Button.icon.backdrop:SetAllPoints(Button)
            Button.icon.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

            local Highlight = Button:GetHighlightTexture()
            Highlight:SetColorTexture(1, 1, 1, 0.15)
            Highlight:ClearAllPoints()
            Highlight:SetAllPoints(Button.icon)

            DBIcon:Lock("SimulationCraft")
            Button:SetMovable(false)
            PositionButton()
            hooksecurefunc(Button, "SetPoint", PositionButton)
            Button:HookScript("OnEnter", function()
                local Tooltip = DBIcon.tooltip
                if not Tooltip:IsOwned(Button) then return end
                Tooltip:ClearAllPoints()
                Tooltip:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", -2, -1)
            end)
        elseif Name == "BugSack" then
            CreatedButton:HookScript("OnShow", PositionButton)
            CreatedButton:HookScript("OnHide", PositionButton)
            PositionButton()
        else
            return
        end

        if Button and DBIcon:GetMinimapButton("BugSack") then
            DBIcon.UnregisterCallback("UnhaltedUI_SimulationCraft", "LibDBIcon_IconCreated")
        end
    end

    -- Use a separate callback owner so BugSack's pending skin keeps its registration.
    DBIcon.RegisterCallback("UnhaltedUI_SimulationCraft", "LibDBIcon_IconCreated", IconCreated)
    for _, Name in ipairs({ "SimulationCraft", "BugSack" }) do
        local ExistingButton = DBIcon:GetMinimapButton(Name)
        if ExistingButton then IconCreated(nil, ExistingButton, Name) end
    end
end

function Private:SetupSimulationCraftSkin()
    if not Private.DB.global.AddOnSkins.SimulationCraft then return end

    if S.Initialized and C_AddOns.IsAddOnLoaded("Simulationcraft") then
        SkinSimulationCraft()
    else
        S:AddCallbackForAddon("Simulationcraft", "UnhaltedUI_SimulationCraft", SkinSimulationCraft)
    end
end
