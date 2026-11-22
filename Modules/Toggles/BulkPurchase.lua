local Private = select(2, ...)

local function BulkPurchase_AddAmount(Button)
    for _ = StackSplitFrame.split == StackSplitFrame.minSplit and 2 or 1, Button.Amount do _G["StackSplitRightButton_OnClick"]() end
end

function Private:SetupBulkPurchase()
    local BlizzardSplitStack = MerchantItem1.ItemButton.SplitStack
    local SkinsDB = Private.E.private.skins.blizzard
    local isSkinned = SkinsDB.enable and SkinsDB.misc
    local PurchaseFrame = CreateFrame("Frame", nil, StackSplitFrame)
    PurchaseFrame:SetAllPoints(StackSplitFrame)
    PurchaseFrame:Hide()
    PurchaseFrame.Price, PurchaseFrame.StackCount = 0, 1
    for Index, Amount in ipairs({ 20, 50, 100 }) do
        local Button = CreateFrame("Button", nil, PurchaseFrame, "UIPanelButtonTemplate")
        Button:SetSize(40, 22)
        Button:SetPoint("TOPLEFT", PurchaseFrame, "TOPLEFT", 19 + (Index - 1) * 48, -22)
        Button:SetText("+" .. Amount)
        Button:SetScript("OnClick", BulkPurchase_AddAmount)
        Button.Amount = Amount
        if isSkinned then Private.E:GetModule("Skins"):HandleButton(Button) end
    end
    PurchaseFrame.Text = PurchaseFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    PurchaseFrame.Text:SetPoint("CENTER", PurchaseFrame, "TOP", 0, -56)

    local Background = not isSkinned and StackSplitFrame:CreateTexture(nil, "BACKGROUND") or nil
    if Background then
        Background:SetTexture("Interface\\MoneyFrame\\UI-MoneyFrame2")
        Background:SetTexCoord(0, 0.671875, 0, 0.75)
        Background:SetAllPoints(StackSplitFrame)
        Background:Hide()
    end

    local function BulkPurchase_SetShown(Shown)
        PurchaseFrame:SetShown(Shown)
        if Background then Background:SetShown(Shown) end
        StackSplitFrame.LeftButton:SetShown(not Shown)
        StackSplitFrame.RightButton:SetShown(not Shown)
        StackSplitFrame.StackSplitText:SetShown(not Shown)
        if StackSplitFrame.BG then StackSplitFrame.BG:SetShown(not Shown) end
    end

    local function BulkPurchase_SplitStack(Button, Split)
        local Index = Button:GetID()
        local MaxStack = GetMerchantItemMaxStack(Index)
        if Split <= MaxStack then return BlizzardSplitStack(Button, Split) end

        local StackCount = C_MerchantFrame.GetItemInfo(Index).stackCount
        local Chunk = math.max(MaxStack - MaxStack % StackCount, StackCount)
        for Bought = 0, Split - 1, Chunk do BuyMerchantItem(Index, math.min(Chunk, Split - Bought)) end
    end

    local function BulkPurchase_UpdateText()
        if not PurchaseFrame:IsShown() then return end
        PurchaseFrame.Text:SetText(StackSplitFrame.split .. " for " .. GetMoneyString(StackSplitFrame.split / PurchaseFrame.StackCount * PurchaseFrame.Price, true))
    end

    local function BulkPurchase_OnModifiedClick(Button)
        if not Private.DB.global.Toggles.BulkPurchase or MerchantFrame.selectedTab ~= 1 or StackSplitFrame.owner ~= Button or not StackSplitFrame:IsShown() or Button.extendedCost then return end

        local Info = C_MerchantFrame.GetItemInfo(Button:GetID())
        if Info.price <= 0 or (Button.showNonrefundablePrompt and Info.price >= MERCHANT_HIGH_PRICE_COST) then return end

        local Bundles = math.floor(GetMoney() / Info.price)
        local MaxPurchase = (Info.numAvailable >= 0 and math.min(Bundles, Info.numAvailable) or Bundles) * Info.stackCount
        if MaxPurchase > StackSplitFrame.maxStack then StackSplitFrame:UpdateStackSplitFrame(MaxPurchase) end
        PurchaseFrame.Price, PurchaseFrame.StackCount = Info.price, Info.stackCount
        StackSplitFrame:ChooseFrameType(2)
        StackSplitFrame.MultiItemSplitBackground:Hide()
        StackSplitFrame.StackItemCountText:Hide()
        BulkPurchase_SetShown(true)
        BulkPurchase_UpdateText()
    end

    for Index = 1, MERCHANT_ITEMS_PER_PAGE do _G["MerchantItem" .. Index].ItemButton.SplitStack = BulkPurchase_SplitStack end
    hooksecurefunc(StackSplitFrame, "OpenStackSplitFrame", function()
        if PurchaseFrame:IsShown() then BulkPurchase_SetShown(false) end
    end)
    hooksecurefunc(StackSplitFrame, "UpdateStackText", BulkPurchase_UpdateText)
    hooksecurefunc("MerchantItemButton_OnModifiedClick", BulkPurchase_OnModifiedClick)
end
