local Private = select(2, ...)
local E = Private.E
local S = E:GetModule("Skins")

local SkinFrame

local function SkinChildren(Frame)
    for _, Child in ipairs({ Frame:GetChildren() }) do
        SkinFrame(Child)
    end
end

local function SkinRows(ScrollBox)
    ScrollBox:ForEachFrame(function(Row)
        SkinFrame(Row)
        -- TableBuilder can add new cells to an existing row when columns change.
        SkinChildren(Row)
    end)
end

local function SkinHeaders(Listing)
    for _, Header in ipairs({ Listing.HeaderContainer:GetChildren() }) do
        if not Header.UnhaltedSkinned then
            Header:DisableDrawLayer("BACKGROUND")
            Header:CreateBackdrop("Transparent")
            Header.UnhaltedSkinned = true
        end
    end
end

local function SkinBagItems(View)
    local LayoutChanged = false
    for Button in View.buttonPool:EnumerateActive() do
        SkinFrame(Button)
    end
    for Group in View.groupPool:EnumerateActive() do
        if Group.paddingBottom ~= 4 then
            Group.paddingBottom = 4
            LayoutChanged = true
        end
        SkinFrame(Group)
    end
    if LayoutChanged then View:UpdateGroupHeights() end
end

local function SkinExportLists(Frame)
    for CheckBox in Frame.checkBoxPool:EnumerateActive() do
        SkinFrame(CheckBox)
    end
end

-- Collectionator uses these same Auctionator widgets. Only traverse the addon
-- panels passed below, keeping Blizzard's Auction House and other addons separate.
SkinFrame = function(Frame)
    if not Frame or Frame.UnhaltedSkinned then return end
    Frame.UnhaltedSkinned = true

    -- Capture children before ElvUI adds its own backdrop frames.
    local Children = { Frame:GetChildren() }
    local Parent = Frame:GetParent()

    if Parent and Parent.ScrollBar == Frame then
        S:HandleTrimScrollBar(Frame)
        return
    elseif Frame:IsObjectType("EditBox") then
        S:HandleEditBox(Frame)
    elseif Frame:IsObjectType("CheckButton") then
        if Parent.RadioButton == Frame then
            S:HandleRadioButton(Frame)
        else
            S:HandleCheckBox(Frame)
            Frame.backdrop:ClearAllPoints()
            Frame.backdrop:Size(16)
            Frame.backdrop:Point("CENTER", Frame)
            Frame:GetCheckedTexture():SetInside(Frame.backdrop)
            Frame:GetDisabledTexture():SetInside(Frame.backdrop)
        end
    elseif Frame:IsObjectType("Button") then
        if Parent.GroupTitle == Frame then
            S:HandleButton(Frame, true)
            Frame.Text:FontTemplate()
            Frame.Text:ClearAllPoints()
            Frame.Text:Point("LEFT", Frame, "LEFT", 4, 0)
            Frame.Text:Point("RIGHT", Frame, "RIGHT", -4, 0)
            Frame.Text:SetJustifyH("LEFT")
        elseif Parent.CloseButton == Frame or Parent.CloseDialog == Frame or Parent.ClearButton == Frame then
            S:HandleCloseButton(Frame)
        elseif Frame.LeftActive or Frame.LeftDisabled then
            Frame:StripTextures()
            S:HandleTab(Frame)
        elseif Frame.SetupMenu then
            S:HandleDropDownBox(Frame, Frame:GetWidth())
        elseif not Frame.IconBorder then
            S:HandleButton(Frame)
        end
    elseif Frame.TitleContainer and Frame.PortraitContainer then
        S:HandlePortraitFrame(Frame)
    elseif Frame.NineSlice or (Frame.Border and Frame.Border.layoutType == "SimplePanelTemplate") then
        Frame:StripTextures()
        if Frame.Border then Frame.Border:StripTextures() end
        Frame:SetTemplate("Transparent")
    end

    if Frame.Icon and Frame.Icon:IsObjectType("Texture") and (Frame.IconBorder or Frame.QualityBorder) then
        S:HandleIcon(Frame.Icon, true)
        local Border = Frame.IconBorder or Frame.QualityBorder
        S:HandleIconBorder(Border, Frame.Icon.backdrop)
        if Frame.EmptySlot then
            Frame.EmptySlot:SetAlpha(0)
            Frame.Icon:SetInside(Frame, 2, 2)
        end
        if Frame.IconSelectedHighlight then
            Frame.IconSelectedHighlight:ClearAllPoints()
            Frame.IconSelectedHighlight:SetAllPoints(Frame.Icon)
            Frame.IconSelectedHighlight:SetTexture(E.media.normTex)
            Frame.IconSelectedHighlight:SetAlpha(0.3)
        end
    end

    if Frame.HeaderContainer and Frame.InitializeTable then
        SkinHeaders(Frame)
        hooksecurefunc(Frame, "InitializeTable", SkinHeaders)
    end

    if Frame.ScrollBox and Frame.ScrollBox.ForEachFrame then
        SkinRows(Frame.ScrollBox)
        hooksecurefunc(Frame.ScrollBox, "Update", SkinRows)
    end

    if Frame.buttonPool and Frame.groupPool then
        SkinBagItems(Frame)
        hooksecurefunc(Frame, "UpdateFromExisting", SkinBagItems)
    end

    if Frame.checkBoxPool and Frame.RefreshLists then
        SkinExportLists(Frame)
        hooksecurefunc(Frame, "RefreshLists", SkinExportLists)
    end

    for _, Child in ipairs(Children) do
        SkinFrame(Child)
    end
end

function Private:SkinAuctionatorFrame(Frame)
    SkinFrame(Frame)
end

function Private:SkinAuctionatorTab(Tab)
    S:HandleTab(Tab)

    local Point, RelativeTo, RelativePoint, _, OffsetY = Tab:GetPoint()
    Tab:ClearAllPoints()
    Tab:Point(Point, RelativeTo, RelativePoint, -5, OffsetY)
end

function Private:RegisterAuctionatorSkin(AddOnName, Skin)
    if not Private.DB.global.AddOnSkins[AddOnName] then return end

    local function LoadSkin()
        if _G.AuctionatorAHFrame then
            _G.AuctionatorAHFrame:HookScript("OnShow", Skin)
            Skin()
        else
            -- Hook before the mixin is copied into the lazily created AH frame.
            hooksecurefunc(AuctionatorAHFrameMixin, "OnShow", Skin)
        end
    end

    if S.Initialized and C_AddOns.IsAddOnLoaded(AddOnName) then
        LoadSkin()
    else
        S:AddCallbackForAddon(AddOnName, "UnhaltedUI_" .. AddOnName, LoadSkin)
    end
end

local NextDialog = 1
local DialogsHooked = false

local function SkinDialogs()
    while _G["AuctionatorDialog" .. NextDialog] do
        SkinFrame(_G["AuctionatorDialog" .. NextDialog])
        NextDialog = NextDialog + 1
    end
end

local function SkinAuctionator()
    if not DialogsHooked then
        for _, Method in ipairs({ "ShowEditBox", "ShowConfirm", "ShowConfirmAlt", "ShowMoney" }) do
            hooksecurefunc(Auctionator.Dialogs, Method, SkinDialogs)
        end
        DialogsHooked = true
        SkinDialogs()
    end

    for _, Name in ipairs({ "Shopping", "Selling", "Cancelling", "Auctionator" }) do
        local Tab = _G["AuctionatorTabs_" .. Name]
        if Tab then Private:SkinAuctionatorTab(Tab) end
    end

    local InfoTab = _G.AuctionatorTabs_Auctionator
    if InfoTab then
        InfoTab:Hide()
        local _, PreviousTab = InfoTab:GetPoint()
        for _, Tab in ipairs(_G.AuctionatorAHTabsContainer.Tabs) do
            local _, RelativeTo = Tab:GetPoint()
            if RelativeTo == InfoTab then
                Tab:ClearAllPoints()
                Tab:Point("TOPLEFT", PreviousTab, "TOPRIGHT", Tab.backdrop and -5 or 3, 0)
            end
        end
    end

    for _, Name in ipairs({
        "AuctionatorShoppingFrame",
        "AuctionatorSellingFrame",
        "AuctionatorCancellingFrame",
        "AuctionatorConfigFrame",
        "AuctionatorBuyItemFrame",
        "AuctionatorBuyCommodityFrame",
    }) do
        SkinFrame(_G[Name])
    end
end

function Private:SetupAuctionatorSkin()
    Private:RegisterAuctionatorSkin("Auctionator", SkinAuctionator)
end
