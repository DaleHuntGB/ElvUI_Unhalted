local Private = select(2, ...)

local function RegisterBigWigsBarSkin()
    if not BigWigsAPI then return end
    if BigWigsAPI:GetBarStyle("ElvUI_Unhalted") then return end

    local Borders = {}

    BigWigsAPI:RegisterBarStyle("ElvUI_Unhalted", {
        apiVersion = 1,
        version = 1,

        barHeight = 24,
        barSpacing = 1,
        fontSizeNormal = 12,
        fontSizeEmphasized = 12,
        fontOutline = "OUTLINE, SLUG",

        GetStyleName = function()
            return "|cFF6080FFUnhalted|rUI"
        end,

        ApplyStyle = function(Bar)
            local StatusBar = Bar.candyBarBar
            local Icon = Bar.candyBarIconFrame
            local Name = Bar.candyBarLabel
            local Time = Bar.candyBarDuration
            local Border = Bar:Get("ElvUI_Unhalted:Border")
            if not Border then
                Border = table.remove(Borders)
                if not Border then
                    Border = CreateFrame("Frame")
                    Border:EnableMouse(false)
                    for _, Edge in ipairs({"Top", "Bottom", "Left", "Right"}) do Border[Edge] = Border:CreateTexture(nil, "OVERLAY") Border[Edge]:SetColorTexture(0, 0, 0, 1) end
                    Border.Top:SetPoint("TOPLEFT")
                    Border.Top:SetPoint("TOPRIGHT")
                    Border.Bottom:SetPoint("BOTTOMLEFT")
                    Border.Bottom:SetPoint("BOTTOMRIGHT")
                    Border.Left:SetPoint("TOPLEFT")
                    Border.Left:SetPoint("BOTTOMLEFT")
                    Border.Right:SetPoint("TOPRIGHT")
                    Border.Right:SetPoint("BOTTOMRIGHT")
                end
                -- Restore the original appearance when BigWigs changes styles or reuses a bar.
                Border.Texture = StatusBar:GetStatusBarTexture():GetTexture()
                Border.BackgroundTexture = Bar.candyBarBackground:GetTexture()
                Border.BackgroundColour = {Bar.candyBarBackground:GetVertexColor()}
                Border.Font = {Name:GetFont()}
                Border.Shadow = {Name:GetShadowOffset()}
                Border.IconCoords = {Icon:GetTexCoord()}
                Border.WordWrap = Name:CanWordWrap()
                Border.NameAlign = Name:GetJustifyH()
                Border.TimeAlign = Time:GetJustifyH()
                Bar:Set("ElvUI_Unhalted:Border", Border)
            end

            Bar:SetTexture(Private.LSM:Fetch("statusbar", "Blizzard Raid Bar"))
            Bar.candyBarBackground:SetTexture(Private.LSM:Fetch("statusbar", "Blizzard Raid Bar"))
            Bar:SetBackgroundColor(26/255, 26/255, 26/255, 1)
            Bar:SetFont(Private:FetchFont("Friz Quadrata TT"), 12, "OUTLINE, SLUG")
            Bar:SetShadowOffset(0, 0)
            Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

            StatusBar:ClearAllPoints()
            if Bar:IsIconVisible() then
                if Bar:GetIconPosition() == "RIGHT" then
                    StatusBar:SetPoint("TOPLEFT", Bar, "TOPLEFT")
                    StatusBar:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMLEFT", 1, 0)
                else
                    StatusBar:SetPoint("TOPLEFT", Icon, "TOPRIGHT", -1, 0)
                    StatusBar:SetPoint("BOTTOMRIGHT", Bar, "BOTTOMRIGHT")
                end
            else
                StatusBar:SetAllPoints(Bar)
            end

            Time:ClearAllPoints()
            Time:SetPoint("RIGHT", StatusBar, "RIGHT", -3, 0)
            Time:SetSize(12 * 3.5, Bar:GetHeight())
            Time:SetJustifyH("RIGHT")
            Name:ClearAllPoints()
            Name:SetPoint("LEFT", StatusBar, "LEFT", 3, 0)
            Name:SetPoint("RIGHT", Bar:IsTimeVisible() and Time or StatusBar, Bar:IsTimeVisible() and "LEFT" or "RIGHT", -3, 0)
            Name:SetJustifyH("LEFT")
            Name:SetWordWrap(false)

            Border:SetParent(StatusBar)
            Border:SetFrameLevel(StatusBar:GetFrameLevel() + 1)
            Border:SetAllPoints(Bar)
            local Pixel = PixelUtil.GetPixelToUIUnitFactor() / Bar:GetEffectiveScale()
            Border.Top:SetHeight(Pixel)
            Border.Bottom:SetHeight(Pixel)
            Border.Left:SetWidth(Pixel)
            Border.Right:SetWidth(Pixel)
            Border:Show()
        end,

        BarStopped = function(Bar)
            local Border = Bar:Get("ElvUI_Unhalted:Border")
            if not Border then return end

            Bar:SetTexture(Border.Texture)
            Bar.candyBarBackground:SetTexture(Border.BackgroundTexture)
            Bar:SetBackgroundColor(unpack(Border.BackgroundColour))
            Bar:SetFont(unpack(Border.Font))
            Bar:SetShadowOffset(unpack(Border.Shadow))
            Bar.candyBarIconFrame:SetTexCoord(unpack(Border.IconCoords))
            Bar:SetHeight(Bar:GetHeight())
            for _, Text in ipairs({Bar.candyBarLabel, Bar.candyBarDuration}) do
                Text:ClearAllPoints()
                Text:SetSize(0, 0)
                Text:SetPoint("TOPLEFT", Bar.candyBarBar, "TOPLEFT", 2, 0)
                Text:SetPoint("BOTTOMRIGHT", Bar.candyBarBar, "BOTTOMRIGHT", -2, 0)
            end
            Bar.candyBarLabel:SetWordWrap(Border.WordWrap)
            Bar.candyBarLabel:SetJustifyH(Border.NameAlign)
            Bar.candyBarDuration:SetJustifyH(Border.TimeAlign)

            Border:Hide()
            Border:ClearAllPoints()
            Border:SetParent(UIParent)
            Borders[#Borders + 1] = Border
            Bar:Set("ElvUI_Unhalted:Border", nil)
        end,
    })
end

function Private:SetupBigWigsSkin()
    if not Private.DB.global.AddOnSkins.BigWigs.Enable then return end
    if not C_AddOns.IsAddOnLoaded("BigWigs") then return end

    local DB = Private.DB.global.AddOnSkins.BigWigs

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

        DBIcon:Lock("NumyAddonProfiler")
        Button:ClearAllPoints()
        Button:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Button:SetMovable(false)
        Button:SetSize(DB.Size[1], DB.Size[2])

        local SetPoint = Button.SetPoint
        hooksecurefunc(Button, "SetPoint", function()
            local _DB = Private.DB.global.AddOnSkins.BigWigs
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

    local Button = DBIcon:GetMinimapButton("BigWigs")

    if Button then
        SkinButton(Button)
    else
        DBIcon.RegisterCallback("ElvUI_Unhalted_BigWigsSkin", "LibDBIcon_IconCreated", function(_, CreatedButton, Name) if Name ~= "BigWigs" then return end SkinButton(CreatedButton) DBIcon.UnregisterCallback(Private, "LibDBIcon_IconCreated") end)
    end

    RegisterBigWigsBarSkin()

end

function Private:UpdateBigWigsSkin()
    local DB = Private.DB.global.AddOnSkins.BigWigs
    local DBIcon = LibStub("LibDBIcon-1.0", true)
    if not DBIcon then return end

    local Button = DBIcon:GetMinimapButton("BigWigs")

    if Button then
        Button:ClearAllPoints()
        Button:SetPoint(DB.Layout[1], _G["Minimap"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        Button:SetSize(DB.Size[1], DB.Size[2])
    end
end
