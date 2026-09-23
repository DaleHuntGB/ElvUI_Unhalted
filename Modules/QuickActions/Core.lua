local Private = select(2, ...)
local UpdateTimer

-- Selection is repeated in the secure click handler. OnUpdate only paints the preview;
-- it never supplies an action or a cursor position to secure execution.
local function UpdateSelection(Frame)
    local X, Y = GetCursorPosition()
    local CenterX, CenterY = Frame:GetParent():GetCenter()
    X, Y = X / Frame:GetEffectiveScale() - CenterX, Y / Frame:GetEffectiveScale() - CenterY
    local Index
    if Frame.Count > 0 and X * X + Y * Y > Frame.DeadZone * Frame.DeadZone then
        Index = math.floor(((math.pi / 2 - math.atan2(Y, X)) % (2 * math.pi)) * Frame.Count / (2 * math.pi) + 0.5) % Frame.Count + 1
    end
    if Frame.Selected == Index then return end
    if Frame.Selected then Frame.Icons[Frame.Selected].Highlight:Hide() end
    Frame.Selected = Index
    if Index then Frame.Icons[Index].Highlight:Show() end
    Frame.Label:SetText(Index and Frame.Icons[Index].Name or Frame.Name)
end

local ClickHandler = [=[
    self:SetAttribute("type", nil)
    local group = self:GetFrameRef("Group1")
    if button == "Cancel" then
        group:Hide()
        return false
    end
    if button ~= "1" or group:GetAttribute("count") == 0 then return false end
    if down then
        group:Hide()
        group:Show()
        group:SetBindingClick(true, "ESCAPE", self:GetName(), "Cancel")
        -- Keep the release routed here even if modifiers are released first.
        local key = group:GetAttribute("key")
        for modifiers = 0, 7 do
            local prefix = (modifiers >= 4 and "ALT-" or "") .. (modifiers % 4 >= 2 and "CTRL-" or "") .. (modifiers % 2 == 1 and "SHIFT-" or "")
            group:SetBindingClick(true, prefix .. key, self:GetName(), button)
        end
        return false
    end
    if not group:IsVisible() then return false end

    local x, y = group:GetMousePosition()
    if x then
        local left, bottom, width, height = group:GetRect()
        local centerX, centerY, centerWidth, centerHeight = self:GetRect()
        centerX, centerY = centerX + centerWidth / 2, centerY + centerHeight / 2
        x, y = x * width + left - centerX, y * height + bottom - centerY
        local deadZone = group:GetAttribute("deadZone")
        if x * x + y * y > deadZone * deadZone then
            local count = group:GetAttribute("count")
            local index = math.floor(((math.pi / 2 - math.atan2(y, x)) % (2 * math.pi)) * count / (2 * math.pi) + 0.5) % count + 1
            local actionType = group:GetAttribute("type" .. index)
            local value = group:GetAttribute("value" .. index)
            if actionType == "mount" then
                self:CallMethod("SummonMount", value)
            elseif actionType then
                self:SetAttribute("type", actionType)
                self:SetAttribute(actionType, value)
            end
        end
    end
    return button, true
]=]

local ClickFinished = [=[
    self:GetFrameRef("Group1"):Hide()
    self:SetAttribute("type", nil)
]=]

function Private:UpdateQuickActionIcon(Icon, Action)
    if Action then
        Icon.Action = Action
        Icon.SpellID = Action.Type == "Spell" and Action.ID or nil
        if Action.Type == "Mount" then Icon.SpellID = select(2, C_MountJournal.GetMountInfoByID(Action.ID)) end
    end
    Action = Icon.Action
    if not Action or not Icon:IsVisible() then return end

    if Icon.SpellID then
        if Action.Type == "Spell" then Icon.Count:SetText(C_Spell.GetSpellDisplayCount(Icon.SpellID)) else Icon.Count:SetText("") end
        local Charges = C_Spell.GetSpellCharges(Icon.SpellID)
        local Duration
        -- isActive is public; charge counts and cooldown times can be secret in combat.
        if Charges and Charges.isActive then
            Duration = C_Spell.GetSpellChargeDuration(Icon.SpellID)
        else
            Duration = C_Spell.GetSpellCooldownDuration(Icon.SpellID)
        end
        if Duration then Icon.Cooldown:SetCooldownFromDurationObject(Duration) else Icon.Cooldown:Clear() end
    elseif Action.Type == "Item" or Action.Type == "Toy" then
        Icon.Count:SetText(Action.Type == "Item" and C_Item.GetItemCount(Action.ID, false, true) or "")
        local Start, Duration, Enabled = C_Item.GetItemCooldown(Action.ID)
        if Enabled then Icon.Cooldown:SetCooldown(Start, Duration) else Icon.Cooldown:Clear() end
    else
        Icon.Count:SetText("")
        Icon.Cooldown:Clear()
    end
end

function Private:CreateQuickActionIcon(Parent)
    local Icon = CreateFrame("Frame", nil, Parent, "BackdropTemplate")
    Icon:Hide()
    Icon:EnableMouse(false)
    Icon:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    Icon:SetBackdropColor(20/255, 20/255, 20/255, 1)
    Icon:SetBackdropBorderColor(0, 0, 0, 1)
    Icon.Texture = Icon:CreateTexture(nil, "ARTWORK")
    Icon.Texture:SetPoint("TOPLEFT", 1, -1)
    Icon.Texture:SetPoint("BOTTOMRIGHT", -1, 1)
    Icon.Texture:SetTexCoord(0.03, 0.97, 0.03, 0.97)
    Icon.Cooldown = CreateFrame("Cooldown", nil, Icon, "CooldownFrameTemplate")
    Icon.Cooldown:EnableMouse(false)
    Icon.Cooldown:SetAllPoints(Icon.Texture)
    Icon.Cooldown:SetDrawSwipe(true)
    Icon.Cooldown:SetDrawEdge(false)
    Icon.Cooldown:SetDrawBling(false)
    Icon.Cooldown:SetHideCountdownNumbers(false)
    Private.E:RegisterCooldown(Icon.Cooldown)
    local Overlay = CreateFrame("Frame", nil, Icon)
    Overlay:EnableMouse(false)
    Overlay:SetAllPoints(Icon)
    Overlay:SetFrameLevel(Icon.Cooldown:GetFrameLevel() + 1)
    Icon.Count = Overlay:CreateFontString(nil, "OVERLAY")
    Icon.Count:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    Icon.Count:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", -2, 2)
    Icon.Count:SetJustifyH("RIGHT")
    Icon.Highlight = Overlay:CreateTexture(nil, "ARTWORK")
    Icon.Highlight:SetAllPoints(Icon.Texture)
    Icon.Highlight:SetColorTexture(1, 1, 1, 0.3)
    Icon.Highlight:Hide()
    Icon:SetScript("OnEvent", function(Frame) Private:UpdateQuickActionIcon(Frame) end)
    Icon:SetScript("OnShow", function(Frame)
        Frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        Frame:RegisterEvent("SPELL_UPDATE_CHARGES")
        Frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
        Frame:RegisterEvent("BAG_UPDATE_DELAYED")
        Private:UpdateQuickActionIcon(Frame)
    end)
    Icon:SetScript("OnHide", function(Frame)
        Frame:UnregisterAllEvents()
        Frame.Count:SetText("")
        Frame.Cooldown:Clear()
    end)
    return Icon
end

function Private:UpdateQuickActions()
    if InCombatLockdown() then
        Private.QuickActionsPending = true
        Private.QuickActionsEvents:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    Private.QuickActionsPending = nil
    local DB = Private.DB.global.QuickAction
    local Handler = Private.QuickActionsHandler
    if Handler then
        ClearOverrideBindings(Handler)
        Handler:SetAttribute("type", nil)
        Handler.Group:Hide()
        Handler.Group:SetAttribute("count", 0)
    end
    if not DB.Enabled then return end

    if not Handler then
        Handler = CreateFrame("Button", "UnhaltedUIQuickActions", UIParent, "SecureActionButtonTemplate,SecureHandlerBaseTemplate")
        Handler:SetSize(1, 1)
        Handler:EnableMouse(false)
        Handler:RegisterForClicks("AnyDown", "AnyUp")
        Handler:SetAttribute("useOnKeyDown", false)
        Handler:SetAttribute("checkselfcast", true)
        Handler:SetAttribute("checkfocuscast", true)
        Handler.SummonMount = function(_, MountID)
            if not InCombatLockdown() then C_MountJournal.SummonByID(MountID) end
        end
        SecureHandlerWrapScript(Handler, "OnClick", Handler, ClickHandler, ClickFinished)
        Private.QuickActionsHandler = Handler
    end
    Handler:ClearAllPoints()
    Handler:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])

    local Data = DB.Groups[1]
    local Group = Handler.Group
    if not Group then
        Group = CreateFrame("Frame", nil, Handler, "SecureHandlerShowHideTemplate")
        Group:Hide()
        Group:SetAllPoints(UIParent)
        Group:SetFrameStrata("DIALOG")
        Group:EnableMouse(false)
        Group:SetAttribute("_onhide", "self:ClearBindings()")
        Group.Icons = {}
        Group.Label = Group:CreateFontString(nil, "OVERLAY")
        Group.Label:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
        Group.Label:SetTextColor(96/255, 128/255, 255/255)
        Group.Label:SetJustifyH("CENTER")
        Group:SetScript("OnUpdate", UpdateSelection)
        Group:HookScript("OnShow", function(Frame) Frame.Label:SetText(Frame.Name) end)
        Group:HookScript("OnHide", function(Frame)
            if Frame.Selected then Frame.Icons[Frame.Selected].Highlight:Hide() end
            Frame.Selected = nil
        end)
        Handler:SetFrameRef("Group1", Group)
        Handler.Group = Group
    end
    Group.Name, Group.Count = "Quick Actions", #Data.Items
    Group.DeadZone = math.max(DB.Size[1], DB.Size[2]) * 0.65
    Group:SetAttribute("count", Group.Count)
    Group:SetAttribute("deadZone", Group.DeadZone)
    Group:SetAttribute("key", Data.Keybind:gsub("ALT%-", ""):gsub("CTRL%-", ""):gsub("SHIFT%-", ""))
    local AngleStep = 2 * math.pi / math.max(2, Group.Count)
    local IconDiagonal = math.sqrt(DB.Size[1]^2 + DB.Size[2]^2)
    local Radius = math.max(80, Group.DeadZone + IconDiagonal / 2 + 8, (IconDiagonal + 8) / (2 * math.sin(AngleStep / 2)))
    Group.Label:ClearAllPoints()
    Group.Label:SetPoint("BOTTOM", Handler, "CENTER", 0, Radius + DB.Size[2] / 2 + 8)
    Group.Label:SetWidth(Radius * 2 + DB.Size[1])
    Group.Label:SetText(Group.Name)
    for _, Icon in ipairs(Group.Icons) do Icon:Hide() end
    for Index, Action in ipairs(Data.Items) do
        local Icon = Group.Icons[Index]
        if not Icon then
            Icon = Private:CreateQuickActionIcon(Group)
            Group.Icons[Index] = Icon
        end
        local Name, Texture, ActionType, Value = Private:GetQuickActionInfo(Action)
        Icon.Name = Name
        Icon.Texture:SetTexture(Texture)
        Private:UpdateQuickActionIcon(Icon, Action)
        Icon:SetSize(DB.Size[1], DB.Size[2])
        Icon:ClearAllPoints()
        local Angle = math.pi / 2 - (Index - 1) * AngleStep
        Icon:SetPoint("CENTER", Handler, "CENTER", math.cos(Angle) * Radius, math.sin(Angle) * Radius)
        Icon:Show()
        Group:SetAttribute("type" .. Index, ActionType)
        Group:SetAttribute("value" .. Index, Value)
    end
    if Data.Keybind ~= "" and Group.Count > 0 then
        SetOverrideBindingClick(Handler, true, Data.Keybind, Handler:GetName(), "1")
    end
end

function Private:SetupQuickActions()
    if UpdateTimer then
        UpdateTimer:Cancel()
        UpdateTimer = nil
    end
    if not Private.QuickActionsEvents then
        local Events = CreateFrame("Frame")
        Events:SetScript("OnEvent", function(_, Event, ID, Success)
            if Event == "PLAYER_REGEN_DISABLED" then
                Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                return
            end
            if Event == "PLAYER_REGEN_ENABLED" then
                if Private.QuickActionsPending then Private:SetupQuickActions() end
                Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
                return
            end
            if Event == "ITEM_DATA_LOAD_RESULT" or Event == "SPELL_DATA_LOAD_RESULT" then
                local Pending = Event == "ITEM_DATA_LOAD_RESULT" and Private.QuickActionPendingItems or Private.QuickActionPendingSpells
                if not Pending or not Pending[ID] then return end
                Pending[ID] = nil
                if not Success then return end
                if Event == "ITEM_DATA_LOAD_RESULT" then
                    Private.QuickActionCatalog.Item, Private.QuickActionCatalog.Toy = nil, nil
                else
                    Private.QuickActionCatalog.Spell = nil
                end
            end
            if Event == "SPELLS_CHANGED" then Private.QuickActionCatalog.Spell = nil end
            -- Spellbook and data-load events can arrive in batches.
            if Event ~= "PLAYER_ENTERING_WORLD" then
                if not UpdateTimer then
                    UpdateTimer = C_Timer.NewTimer(0.1, function()
                        UpdateTimer = nil
                        Private:UpdateQuickActions()
                        if not InCombatLockdown() then Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI") end
                    end)
                end
                return
            end
            Private:UpdateQuickActions()
            if not InCombatLockdown() then
                Private.E.Libs.AceConfigRegistry:NotifyChange("ElvUI")
            end
        end)
        Private.QuickActionsEvents = Events
    end
    local Events = Private.QuickActionsEvents
    Events:UnregisterAllEvents()
    if Private.DB.global.QuickAction.Enabled then
        Events:RegisterEvent("PLAYER_ENTERING_WORLD")
        Events:RegisterEvent("PLAYER_REGEN_DISABLED")
        Events:RegisterEvent("PLAYER_REGEN_ENABLED")
        Events:RegisterEvent("SPELLS_CHANGED")
        Events:RegisterEvent("ITEM_DATA_LOAD_RESULT")
        Events:RegisterEvent("SPELL_DATA_LOAD_RESULT")
    end
    Private:UpdateQuickActions()
end
