local Private = select(2, ...)
local SocketHelper, EventFrame, HideTimer, Transaction

local function HideGemPopup()
    if HideTimer then HideTimer:Cancel() HideTimer = nil end
    if SocketHelper.Glow.Style then
        Private.ElvUI.Libs.CustomGlow.HideOverlayGlow(SocketHelper.Glow, SocketHelper.Glow.Style)
        SocketHelper.Glow.Style = nil
    end
    SocketHelper.Glow:Hide()
    SocketHelper.Popup:Hide()
    SocketHelper.Popup.Target = nil
    SocketHelper.Popup.TargetButton = nil
    SocketHelper.Popup.Hovered = nil
end

local function QueueHidePopup()
    if HideTimer then HideTimer:Cancel() HideTimer = nil end
    HideTimer = C_Timer.NewTimer(0.15, function()
        HideTimer = nil
        local Popup = SocketHelper.Popup
        if not Popup.TargetButton or (not Popup.TargetButton:IsMouseOver() and not (Popup.Hovered and Popup.Hovered:IsMouseOver())) then HideGemPopup() end
    end)
end

local function FinishSocketing(Error)
    local Pending = Transaction
    if not Pending then return end
    Transaction = nil
    Pending.Timer:Cancel()
    C_ItemSocketInfo.CloseSocketInfo()
    if Pending.NativeFrame then Pending.NativeFrame:RegisterEvent("SOCKET_INFO_UPDATE") end
    GameEvent.RegisterInternalEvent("SOCKET_INFO_UPDATE", GameEvent.HandleSocketInfoUpdate)
    if Pending.PickedUp then ClearCursor() end
    if Error then UIErrorsFrame:AddMessage(Error, 1, 0.2, 0.2) end
    Private:UpdateSocketHelper()
end

local function CreateGemButton(Parent)
    local Button = CreateFrame("Button", nil, Parent, "BackdropTemplate")
    Button:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    Button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
    Button:GetHighlightTexture():SetAlpha(0.15)
    Button.Icon = Button:CreateTexture(nil, "ARTWORK")
    Button.Icon:SetPoint("TOPLEFT", 1, -1)
    Button.Icon:SetPoint("BOTTOMRIGHT", -1, 1)
    Button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    return Button
end

local function ShowBagGems(TargetButton)
    if InCombatLockdown() or Transaction or not Private.DB.global.QualityOfLife.Toggles.SocketHelper then return end
    local Gems, ByID = {}, {}
    for Bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
            local Info = C_Container.GetContainerItemInfo(Bag, Slot)
            if Info and select(6, C_Item.GetItemInfoInstant(Info.itemID)) == Enum.ItemClass.Gem then
                local Gem = ByID[Info.itemID]
                if not Gem then
                    Gem = {ItemID = Info.itemID, Name = Info.itemName, Icon = Info.iconFileID, Quality = Info.quality, Count = 0}
                    ByID[Info.itemID] = Gem
                    Gems[#Gems + 1] = Gem
                end
                Gem.Count = Gem.Count + Info.stackCount
                if not Info.isLocked then Gem.Bag = Bag end
            end
        end
    end
    table.sort(Gems, function(A, B)
        if A.Name == B.Name then return A.ItemID < B.ItemID end
        return A.Name < B.Name
    end)
    if #Gems == 0 then HideGemPopup() return end
    if HideTimer then HideTimer:Cancel() HideTimer = nil end
    local Popup = SocketHelper.Popup
    local Target = TargetButton.Socket
    Popup.Target = Target
    Popup.TargetButton = TargetButton
    local Size = SocketHelper.GemSize
    local Rows = math.min(#Gems, 5)
    Popup:ClearAllPoints()
    Popup:SetPoint("BOTTOM", TargetButton, "TOP", 0, 1)
    Popup:SetSize(Size, Rows * (Size + 1) - 1)
    Popup.Content:SetSize(Size, #Gems * (Size + 1) - 1)
    Popup.Scroll:SetVerticalScroll((#Gems - Rows) * (Size + 1))
    for Index, Button in ipairs(Popup.Buttons) do if Index > #Gems then Button:Hide() end end
    for Index, Gem in ipairs(Gems) do
        local Button = Popup.Buttons[Index]
        if not Button then
            Button = CreateGemButton(Popup.Content)
            Button:SetMotionScriptsWhileDisabled(true)
            Button:ClearHighlightTexture()
            Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
            Button.Highlight:SetAllPoints()
            Button.Highlight:SetTexture("Interface\\Buttons\\WHITE8X8")
            Button.Highlight:SetAlpha(0.15)
            Button.Highlight:Hide()
            Button.Count = Button:CreateFontString(nil, "OVERLAY")
            Button.Count:FontTemplate(nil, 10, "OUTLINE")
            Button.Count:SetPoint("CENTER")
            Button:SetScript("OnClick", function(Self)
                if InCombatLockdown() or Transaction or not Private.DB.global.QualityOfLife.Toggles.SocketHelper then return end
                local Target = SocketHelper.Popup.Target
                if not Target or GetInventoryItemLink("player", Target.SlotID) ~= Target.ItemLink then HideGemPopup() return end
                if GetCursorInfo() then UIErrorsFrame:AddMessage("Clear your cursor before socketing a gem.", 1, 0.2, 0.2) return end
                if ItemSocketingFrame and ItemSocketingFrame:IsShown() then
                    UIErrorsFrame:AddMessage("Close the socketing window before using Socket Helper.", 1, 0.2, 0.2)
                    return
                end

                -- Resolve the bag position again: sorting or moving a stack can invalidate the popup's data.
                local Gem = Self.Gem
                local BagID, SlotID
                for Bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
                    for Slot = 1, C_Container.GetContainerNumSlots(Bag) do
                        local Info = C_Container.GetContainerItemInfo(Bag, Slot)
                        if Info and Info.itemID == Gem.ItemID and not Info.isLocked then BagID, SlotID = Bag, Slot end
                    end
                end
                if not BagID or Target.GemID == Gem.ItemID then return end

                local Pending = {ItemLink = Target.ItemLink, OldGem = select(2, C_Item.GetItemGem(Target.ItemLink, Target.Index))}
                Transaction = Pending
                Pending.Timer = C_Timer.NewTimer(5, function() FinishSocketing("Gem socketing did not complete. Please try again.") end)
                -- Own the native socketing session until it succeeds, fails, or is cancelled.
                -- The game dispatcher would otherwise open its left-hand panel and close the character frame.
                GameEvent.UnregisterInternalEvent("SOCKET_INFO_UPDATE")
                if ItemSocketingFrame and ItemSocketingFrame:IsEventRegistered("SOCKET_INFO_UPDATE") then
                    Pending.NativeFrame = ItemSocketingFrame
                    ItemSocketingFrame:UnregisterEvent("SOCKET_INFO_UPDATE")
                end
                HideGemPopup()
                SocketInventoryItem(Target.SlotID)
                if Transaction ~= Pending then return end
                if C_ItemSocketInfo.GetNumSockets() < Target.Index then FinishSocketing("That socket is no longer available.") return end

                C_Container.PickupContainerItem(BagID, SlotID)
                local CursorType, CursorID = GetCursorInfo()
                if Transaction ~= Pending then
                    if CursorType == "item" and CursorID == Gem.ItemID then ClearCursor() end
                    return
                end
                if CursorType ~= "item" or CursorID ~= Gem.ItemID then FinishSocketing("That gem is no longer available.") return end
                Pending.PickedUp = true
                C_ItemSocketInfo.ClickSocketButton(Target.Index)
                if Transaction ~= Pending then return end
                local Link = C_ItemSocketInfo.GetNewSocketLink(Target.Index)
                if not Link or C_Item.GetItemInfoInstant(Link) ~= Gem.ItemID then
                    FinishSocketing("That gem cannot be placed in this socket.")
                    return
                end
                Pending.NewGem = Link
                ClearCursor()
                Pending.PickedUp = nil
                if C_ItemSocketInfo.GetSocketItemBoundTradeable() and C_ItemSocketInfo.HasBoundGemProposed() then
                    C_Item.EndBoundTradeable("gem")
                else
                    C_ItemSocketInfo.AcceptSockets()
                end
            end)
            Button:SetScript("OnEnter", function(Self)
                Self.Highlight:Show()
                Popup.Hovered = Self
                if HideTimer then HideTimer:Cancel() HideTimer = nil end
            end)
            Button:SetScript("OnLeave", function(Self)
                Self.Highlight:Hide()
                if Popup.Hovered == Self then Popup.Hovered = nil end
                QueueHidePopup()
            end)
            Button:SetScript("OnHide", function(Self) Self.Highlight:Hide() end)
            Popup.Buttons[Index] = Button
        end
        Button.Gem = Gem
        Button:ClearAllPoints()
        Button:SetSize(Size, Size)
        Button:SetPoint("BOTTOM", 0, (Index - 1) * (Size + 1))
        Button.Icon:SetTexture(Gem.Icon)
        Button.Icon:SetDesaturated(not Gem.Bag)
        local R, G, B = Private.ElvUI:GetItemQualityColor(Gem.Quality)
        Button:SetBackdropBorderColor(R, G, B, 1)
        Button.Count:SetText(Gem.Count > 1 and Gem.Count or "")
        Button:SetEnabled(Gem.Bag ~= nil and Target.GemID ~= Gem.ItemID)
        Button:Show()
    end
    Popup:Show()
end

local function RefreshSockets()
    if not SocketHelper:IsVisible() or InCombatLockdown() or Transaction then return end
    local Sockets = {}
    SocketHelper.WaitingForItems = nil
    for SlotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
        local ItemLink = GetInventoryItemLink("player", SlotID)
        if ItemLink then
            local ItemID = C_Item.GetItemInfoInstant(ItemLink)
            if not C_Item.IsItemDataCachedByID(ItemID) then
                SocketHelper.WaitingForItems = true
                C_Item.RequestLoadItemDataByID(ItemID)
            else
                for Index = 1, C_Item.GetItemNumSockets(ItemLink) do
                    local GemID = C_Item.GetItemGemID(ItemLink, Index)
                    if GemID and not C_Item.IsItemDataCachedByID(GemID) then
                        SocketHelper.WaitingForItems = true
                        C_Item.RequestLoadItemDataByID(GemID)
                    end
                    Sockets[#Sockets + 1] = {SlotID = SlotID, Index = Index, ItemLink = ItemLink, GemID = GemID}
                end
            end
        end
    end
    for _, Button in ipairs(SocketHelper.Buttons) do Button:Hide() end
    local Width = SocketHelper:GetWidth()
    local Size = math.max(18, math.min(24, math.floor((Width - math.max(0, #Sockets - 1)) / math.max(1, #Sockets))))
    local Columns = math.max(1, math.floor((Width + 1) / (Size + 1)))
    local Rows = math.ceil(#Sockets / Columns)
    SocketHelper.GemSize = Size
    SocketHelper:SetHeight(math.max(Size, Rows * (Size + 1) - 1))
    for Index, Socket in ipairs(Sockets) do
        local Button = SocketHelper.Buttons[Index]
        if not Button then
            Button = CreateGemButton(SocketHelper)
            Button:SetScript("OnEnter", function(Self)
                if InCombatLockdown() or Transaction or not Private.DB.global.QualityOfLife.Toggles.SocketHelper then return end
                HideGemPopup()
                ShowBagGems(Self)
                local Glow = SocketHelper.Glow
                for _, Slot in ipairs({PaperDollItemsFrame:GetChildren()}) do
                    if Slot:GetID() == Self.Socket.SlotID then
                        Glow:ClearAllPoints()
                        Glow:SetAllPoints(Slot)
                        Glow:SetFrameLevel(Slot:GetFrameLevel() + 1)
                        Glow.Style = Private.ElvUI.db.general.customGlow.style
                        Glow:Show()
                        Private.ElvUI.Libs.CustomGlow.ShowOverlayGlow(Glow)
                        break
                    end
                end
            end)
            Button:SetScript("OnLeave", QueueHidePopup)
            SocketHelper.Buttons[Index] = Button
        end
        Button.Socket = Socket
        Button:ClearAllPoints()
        Button:SetSize(Size, Size)
        Button:SetPoint("BOTTOMRIGHT", -((Index - 1) % Columns) * (Size + 1), math.floor((Index - 1) / Columns) * (Size + 1))
        if Socket.GemID then
            Button.Icon:SetTexture(C_Item.GetItemIconByID(Socket.GemID))
        else
            Button.Icon:SetAtlas("socket-prismatic-background")
        end
        local Quality = Socket.GemID and select(3, C_Item.GetItemInfo(Socket.GemID))
        local R, G, B = Private.ElvUI:GetItemQualityColor(Quality)
        Button:SetBackdropBorderColor(R, G, B, 1)
        Button:Show()
    end
end

function Private:UpdateSocketHelper()
    local Enabled = Private.DB.global.QualityOfLife.Toggles.SocketHelper
    if not EventFrame and not Enabled then return end
    if not EventFrame then
        EventFrame = CreateFrame("Frame")
        EventFrame:SetScript("OnEvent", function(_, Event, _, Success)
            if Transaction then
                if Event == "SOCKET_INFO_BIND_CONFIRM" or Event == "SOCKET_INFO_REFUNDABLE_CONFIRM" then
                    C_ItemSocketInfo.CompleteSocketing()
                elseif Event == "SOCKET_INFO_SUCCESS" or Event == "SOCKET_INFO_CLOSE" then
                    if Event == "SOCKET_INFO_SUCCESS" then
                        Private:PrettyPrint(string.format("Gem Swapped from %s to %s on %s", Transaction.OldGem or "Empty Socket", Transaction.NewGem, Transaction.ItemLink))
                    end
                    FinishSocketing()
                elseif Event == "SOCKET_INFO_FAILURE" then
                    FinishSocketing("Gem socketing failed.")
                elseif Event == "PLAYER_REGEN_DISABLED" then
                    FinishSocketing()
                end
            elseif Event == "BAG_UPDATE_DELAYED" then
                local Popup = SocketHelper.Popup
                if Popup:IsShown() then
                    if Popup.TargetButton:IsMouseOver() or (Popup.Hovered and Popup.Hovered:IsMouseOver()) then ShowBagGems(Popup.TargetButton) else HideGemPopup() end
                end
            elseif Event == "ITEM_DATA_LOAD_RESULT" then
                if SocketHelper.WaitingForItems and Success then RefreshSockets() end
            elseif Event == "PLAYER_EQUIPMENT_CHANGED" or Event == "UNIT_INVENTORY_CHANGED" then
                HideGemPopup()
                RefreshSockets()
            elseif Event == "PLAYER_REGEN_DISABLED" then
                HideGemPopup()
            else
                Private:UpdateSocketHelper()
            end
        end)
    end
    if not Enabled and Transaction then FinishSocketing() return end
    if InCombatLockdown() then EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") return end
    EventFrame:UnregisterAllEvents()
    if not Enabled then if SocketHelper then SocketHelper:Hide() end return end
    if not CharacterStatsPane then EventFrame:RegisterEvent("ADDON_LOADED") return end
    if not SocketHelper then
        SocketHelper = CreateFrame("Frame", nil, CharacterStatsPane)
        SocketHelper:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -2, 2)
        SocketHelper:SetSize(CharacterStatsPane:GetWidth(), 24)
        SocketHelper.Buttons = {}
        SocketHelper:SetScript("OnShow", RefreshSockets)
        SocketHelper:SetScript("OnHide", HideGemPopup)
        SocketHelper:SetScript("OnSizeChanged", function(Self, Width)
            if Width > 0 and Width ~= Self.LastWidth then Self.LastWidth = Width RefreshSockets() end
        end)
        SocketHelper.Glow = CreateFrame("Frame", nil, SocketHelper)
        SocketHelper.Glow:Hide()
        local Popup = CreateFrame("Frame", nil, SocketHelper)
        SocketHelper.Popup = Popup
        Popup:SetFrameStrata("DIALOG")
        Popup:EnableMouse(true)
        Popup:SetScript("OnEnter", function(Self)
            Popup.Hovered = Self
            if HideTimer then HideTimer:Cancel() HideTimer = nil end
        end)
        Popup:SetScript("OnLeave", function(Self)
            if Popup.Hovered == Self then Popup.Hovered = nil end
            QueueHidePopup()
        end)
        Popup.Buttons = {}
        Popup.Scroll = CreateFrame("ScrollFrame", nil, Popup)
        Popup.Scroll:SetPoint("TOPLEFT")
        Popup.Scroll:SetPoint("BOTTOMRIGHT")
        Popup.Scroll:EnableMouse(true)
        Popup.Scroll:SetScript("OnEnter", Popup:GetScript("OnEnter"))
        Popup.Scroll:SetScript("OnLeave", Popup:GetScript("OnLeave"))
        Popup.Scroll:EnableMouseWheel(true)
        Popup.Scroll:SetScript("OnMouseWheel", function(Self, Delta)
            Self:SetVerticalScroll(math.max(0, math.min(Self:GetVerticalScroll() - Delta * (SocketHelper.GemSize + 1), math.max(0, Popup.Content:GetHeight() - Self:GetHeight()))))
        end)
        Popup.Content = CreateFrame("Frame", nil, Popup.Scroll)
        Popup.Scroll:SetScrollChild(Popup.Content)
        Popup:Hide()
        SocketHelper:Hide()
        Private.SocketHelperFrame = SocketHelper
        CharacterStatsPane:HookScript("OnShow", function() Private:UpdateSocketHelper() end)
        CharacterStatsPane:HookScript("OnSizeChanged", function() Private:UpdateSocketHelper() end)
    end
    SocketHelper:SetWidth(CharacterStatsPane:GetWidth())
    SocketHelper:Show()
    for _, Event in ipairs({"PLAYER_EQUIPMENT_CHANGED", "BAG_UPDATE_DELAYED", "ITEM_DATA_LOAD_RESULT", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "SOCKET_INFO_BIND_CONFIRM", "SOCKET_INFO_REFUNDABLE_CONFIRM", "SOCKET_INFO_SUCCESS", "SOCKET_INFO_FAILURE", "SOCKET_INFO_CLOSE"}) do
        EventFrame:RegisterEvent(Event)
    end
    EventFrame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
    RefreshSockets()
end
