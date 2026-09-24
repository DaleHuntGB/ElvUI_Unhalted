local Private = select(2, ...)
local AceGUI = LibStub("AceGUI-3.0")
local WidgetType = "UnhaltedUIQuickActionList"
local PageSize = 40

Private.QuickActionPages = {}

local function CancelDrag(Widget)
    local Button = Widget.DragButton
    if not Button then return end
    Widget.DragButton, Widget.DragAction, Widget.DropIndex = nil, nil, nil
    Widget.frame:SetScript("OnUpdate", nil)
    Widget.frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    Widget.DropMarker:Hide()
    Button.Icon:StopMovingOrSizing()
    Button.Icon:ClearAllPoints()
    Button.Icon:SetPoint("TOPLEFT", Button, "TOPLEFT")
    Button.Icon:SetFrameStrata(Button:GetFrameStrata())
    Button.Icon:SetAlpha(1)
    Button.Icon.Highlight:Hide()
end

local function UpdateDrag(Frame)
    local Widget = Frame.obj
    if Widget.Disabled or InCombatLockdown() or not Private.DB.global.QuickAction.Enabled then
        CancelDrag(Widget)
        return
    end
    Widget.DropIndex = nil
    Widget.DropMarker:Hide()
    if not Frame:IsMouseOver() then return end
    local Parent = Frame:GetParent()
    while Parent do
        if Parent:IsObjectType("ScrollFrame") and not Parent:IsMouseOver() then return end
        Parent = Parent:GetParent()
    end

    local Target, After, ToIndex
    local Page = Private.QuickActionPages.Items or 1
    if Widget.Previous:IsVisible() and Widget.Previous:IsEnabled() and Widget.Previous:IsMouseOver() then
        Target, After, ToIndex = Widget.Previous, false, (Page - 1) * PageSize
    elseif Widget.Next:IsVisible() and Widget.Next:IsEnabled() and Widget.Next:IsMouseOver() then
        Target, After, ToIndex = Widget.Next, true, Page * PageSize + 1
    else
        local CursorX, CursorY = GetCursorPosition()
        local Scale = Frame:GetEffectiveScale()
        CursorX, CursorY = CursorX / Scale, CursorY / Scale
        local NearestX, NearestY, TargetX
        for _, Button in ipairs(Widget.Buttons) do
            if Button:IsVisible() and Button:IsEnabled() then
                local X, Y = Button:GetCenter()
                local DistanceX, DistanceY = math.abs(CursorX - X), math.abs(CursorY - Y)
                -- Select the row first so empty space at the end of a short row appends to that row.
                if not NearestY or DistanceY < NearestY or (DistanceY == NearestY and DistanceX < NearestX) then
                    Target, TargetX, NearestX, NearestY = Button, X, DistanceX, DistanceY
                end
            end
        end
        if not Target or CursorY < Target:GetBottom() - 3 or CursorY > Target:GetTop() + 3 then return end
        After = CursorX >= TargetX
        ToIndex = Target.Index + (After and 1 or 0)
        if Widget.DragButton.Index < ToIndex then ToIndex = ToIndex - 1 end
    end
    if ToIndex == Widget.DragButton.Index then return end
    Widget.DropIndex = ToIndex
    Widget.DropMarker:ClearAllPoints()
    Widget.DropMarker:SetHeight(Target:GetHeight())
    Widget.DropMarker:SetPoint("CENTER", Target, After and "RIGHT" or "LEFT", After and 3 or -3, 0)
    Widget.DropMarker:Show()
end

local function ActionDragStarted(Button)
    local Widget = Button.Widget
    if Widget.Disabled or Widget.Category ~= "Items" or InCombatLockdown() or not Private.DB.global.QuickAction.Enabled then return end
    CancelDrag(Widget)
    Widget.DragButton = Button
    Widget.DragAction = Private.DB.global.QuickAction.Groups[1].Items[Button.Index]
    Widget.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    GameTooltip:Hide()
    Button.Icon:SetFrameStrata("TOOLTIP")
    Button.Icon:SetAlpha(0.8)
    Button.Icon.Highlight:Hide()
    Button.Icon:StartMoving()
    -- Track midpoint crossings and gaps, which do not fire mouse enter/leave events.
    Widget.frame:SetScript("OnUpdate", UpdateDrag)
    UpdateDrag(Widget.frame)
end

local function ActionDragStopped(Button)
    local Widget = Button.Widget
    if Widget.DragButton ~= Button then return end
    UpdateDrag(Widget.frame)
    local Action, FromIndex, ToIndex = Widget.DragAction, Button.Index, Widget.DropIndex
    CancelDrag(Widget)
    if Widget.Disabled or Widget.Category ~= "Items" or InCombatLockdown() or not Private.DB.global.QuickAction.Enabled then return end

    local Items = Private.DB.global.QuickAction.Groups[1].Items
    if not Action or Items[FromIndex] ~= Action then return end
    if not ToIndex or ToIndex == FromIndex or not Items[ToIndex] then return end

    table.insert(Items, ToIndex, table.remove(Items, FromIndex))
    Private.QuickActionPages.Items = math.floor((ToIndex - 1) / PageSize) + 1
    Private:UpdateQuickActions()
    Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
end

local function ActionClicked(Button, MouseButton)
    local Widget = Button.Widget
    if Widget.Disabled or InCombatLockdown() then return end
    if Widget.Category == "Items" then
        if MouseButton ~= "RightButton" then return end
        table.remove(Private.DB.global.QuickAction.Groups[1].Items, Button.Index)
        Private:UpdateQuickActions()
        Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
    elseif MouseButton == "LeftButton" then
        Private:AddQuickAction(Button.Action)
    end
end

local Methods = {
    OnAcquire = function(self)
        self.Category = nil
        self.Entries = {}
        self:SetWidth(200)
        self:SetHeight(24)
        self.Disabled = false
    end,
    OnRelease = function(self)
        CancelDrag(self)
        for _, Button in ipairs(self.Buttons) do
            Button:Hide()
            Button.Action = nil
            Button.Icon.Action, Button.Icon.SpellID = nil, nil
        end
        self.Entries, self.Category = nil, nil
    end,
    SetText = function() end, -- Each action has its own title.
    SetDisabled = function(self, Disabled)
        self.Disabled = Disabled
        if self.Category then self:Layout() end
    end,
    OnWidthSet = function(self, Width)
        if self.Width == Width then return end
        self.Width = Width
        if self.Category then self:Layout() end
    end,
    SetCustomData = function(self, Category)
        self.Category = Category
        self.Entries = {}
        local Added = {}
        for _, Action in ipairs(Private.DB.global.QuickAction.Groups[1].Items) do
            Added[Action.Type .. Action.ID] = true
            if Category == "Items" then
                local Name, Icon = Private:GetQuickActionInfo(Action)
                table.insert(self.Entries, { Type = Action.Type, ID = Action.ID, Name = Name, Icon = Icon })
            end
        end
        if Category ~= "Items" then
            local Search = Private.QuickActionSearch or ""
            for _, Action in ipairs(Private:CollectQuickActions(Category)) do
                if not Added[Action.Type .. Action.ID] and (Search == "" or (Action.Name or ""):lower():find(Search, 1, true) or tostring(Action.ID):find(Search, 1, true)) then
                    table.insert(self.Entries, Action)
                end
            end
        end
        self:Layout()
    end,
    Layout = function(self)
        CancelDrag(self)
        local Pages = math.max(1, math.ceil(#self.Entries / PageSize))
        local Page = math.min(Private.QuickActionPages[self.Category] or 1, Pages)
        Private.QuickActionPages[self.Category] = Page
        local Start = (Page - 1) * PageSize
        local Count = math.min(PageSize, #self.Entries - Start)
        local Width = self.Width or 200
        local Columns = math.max(1, math.floor(Width / 48))
        local Catalogue = self.Category ~= "Items"
        local Height = 0
        for Index = 1, Count do
            local Button = self.Buttons[Index]
            if not Button then
                Button = CreateFrame("Button", nil, self.frame)
                Button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                Button:RegisterForDrag("LeftButton")
                Button.Widget = self
                Button.Icon = Private:CreateQuickActionIcon(Button)
                Button.Icon:SetMovable(true)
                Button.Icon:SetSize(42, 42)
                Button.Icon:SetPoint("TOPLEFT")
                Button.Title = Button:CreateFontString(nil, "OVERLAY")
                Button.Title:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
                Button.Title:SetJustifyH("LEFT")
                Button.Title:SetWordWrap(true)
                Button.Title:SetPoint("LEFT", Button, "LEFT", 50, 0)
                Button:SetScript("OnClick", ActionClicked)
                Button:SetScript("OnDragStart", ActionDragStarted)
                Button:SetScript("OnDragStop", ActionDragStopped)
                Button:SetScript("OnEnter", function(Frame)
                    if Frame.Widget.DragButton then return end
                    if Frame:IsEnabled() then Frame.Icon.Highlight:Show() end
                    GameTooltip:SetOwner(Frame, "ANCHOR_RIGHT")
                    GameTooltip:SetText(Frame.Name)
                    GameTooltip:AddLine(Frame.Widget.Category == "Items" and "Drag to reorder. Right-click to remove." or "Click to add to the menu.", 1, 1, 1)
                    if Frame.Widget.Category == "Items" and #Frame.Widget.Entries > PageSize then
                        GameTooltip:AddLine("Drop on a page arrow to move to that page.", 1, 1, 1)
                    end
                    GameTooltip:Show()
                end)
                Button:SetScript("OnLeave", function(Frame)
                    Frame.Icon.Highlight:Hide()
                    GameTooltip:Hide()
                end)
                Button:SetScript("OnHide", function(Frame)
                    if GameTooltip:GetOwner() == Frame then GameTooltip:Hide() end
                end)
                self.Buttons[Index] = Button
            end
            local Action = self.Entries[Start + Index]
            Button.Action, Button.Index = Action, Start + Index
            local Name, Icon = Action.Name, Action.Icon
            if not Name then Name, Icon = Private:GetQuickActionInfo(Action) end
            Button.Name = Name
            Button.Icon.Texture:SetTexture(Icon or 134400)
            Private:UpdateQuickActionIcon(Button.Icon, Action)
            Button.Icon.Highlight:Hide()
            Button:SetEnabled(not self.Disabled)
            Button:SetAlpha(self.Disabled and 0.4 or 1)
            Button.Title:SetShown(Catalogue)
            Button:ClearAllPoints()
            if Catalogue then
                Button.Title:SetWidth(math.max(1, Width - 54))
                Button.Title:SetText(Name)
                local RowHeight = math.max(42, Button.Title:GetStringHeight() + 8)
                Button:SetSize(Width, RowHeight)
                Button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -Height)
                Height = Height + RowHeight + 8
            else
                Button:SetSize(42, 42)
                Button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", ((Index - 1) % Columns) * 48, -math.floor((Index - 1) / Columns) * 48)
            end
            Button:Show()
            Button.Icon:Show()
        end
        for Index = Count + 1, #self.Buttons do self.Buttons[Index]:Hide() end
        self.Previous:SetShown(Pages > 1)
        self.Next:SetShown(Pages > 1)
        self.Previous:SetEnabled(not self.Disabled and Page > 1)
        self.Next:SetEnabled(not self.Disabled and Page < Pages)
        self.Status:SetText(Count == 0 and (self.Category == "Items" and "No actions added." or "No matching actions available to add.") or (Pages > 1 and (Page .. " / " .. Pages) or ""))
        if not Catalogue then Height = math.ceil(math.min(#self.Entries, PageSize) / Columns) * 48 end
        self:SetHeight(Height + ((Pages > 1 or Count == 0) and 24 or 0))
    end,
}

local function Constructor()
    local Frame = CreateFrame("Frame", nil, UIParent)
    Frame:Hide()
    local Widget = { type = WidgetType, frame = Frame, Buttons = {} }
    Frame:SetScript("OnHide", function() CancelDrag(Widget) end)
    Frame:SetScript("OnEvent", function() CancelDrag(Widget) end)
    for Name, Method in pairs(Methods) do Widget[Name] = Method end
    Widget.DropMarker = CreateFrame("Frame", nil, Frame)
    Widget.DropMarker:EnableMouse(false)
    Widget.DropMarker:SetFrameLevel(Frame:GetFrameLevel() + 5)
    Widget.DropMarker:SetWidth(2)
    local MarkerTexture = Widget.DropMarker:CreateTexture(nil, "OVERLAY")
    MarkerTexture:SetAllPoints()
    MarkerTexture:SetColorTexture(1, 1, 1, 0.8)
    Widget.DropMarker:Hide()
    for _, Direction in ipairs({ "Previous", "Next" }) do
        local Button = CreateFrame("Button", nil, Frame, "BackdropTemplate")
        Button:SetSize(32, 20)
        Button:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        Button:SetBackdropColor(20/255, 20/255, 20/255, 1)
        Button:SetBackdropBorderColor(0, 0, 0, 1)
        local Text = Button:CreateFontString(nil, "OVERLAY")
        Text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        Text:SetPoint("CENTER")
        Text:SetText(Direction == "Previous" and "<" or ">")
        Button:SetPoint("BOTTOM", Frame, "BOTTOM", Direction == "Previous" and -64 or 64, 0)
        Button:SetScript("OnClick", function()
            if Widget.Disabled or InCombatLockdown() then return end
            Private.QuickActionPages[Widget.Category] = Private.QuickActionPages[Widget.Category] + (Direction == "Previous" and -1 or 1)
            Widget:Layout()
            if Widget.parent then
                Widget.parent:DoLayout()
                if Widget.Category ~= "Items" and Widget.parent.type == "ScrollFrame" then Widget.parent:SetScroll(0) end
            end
        end)
        Widget[Direction] = Button
    end
    Widget.Status = Frame:CreateFontString(nil, "OVERLAY")
    Widget.Status:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    Widget.Status:SetPoint("BOTTOM", Frame, "BOTTOM", 0, 3)
    return AceGUI:RegisterAsWidget(Widget)
end

AceGUI:RegisterWidgetType(WidgetType, Constructor, 7)
