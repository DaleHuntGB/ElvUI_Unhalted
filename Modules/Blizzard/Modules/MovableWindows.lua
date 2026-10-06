local Private = select(2, ...)
local Windows = {}
local EventFrame
local NativePanels = {
    CommunitiesFrame = true,
    EditModeManagerFrame = true,
    GameMenuFrame = true,
    MacroFrame = true,
    PlayerSpellsFrame = true,
    SettingsPanel = true,
    TokenFrame = true,
    WarboardQuestChoiceFrame = true,
    WorldMapFrame = true,
}
local AdditionalWindows = {
    "AchievementFrame", "AuctionHouseFrame", "CalendarFrame", "GuildBankFrame",
    "ProfessionsFrame", "ProfessionsCustomerOrdersFrame", "PlayerSpellsFrame",
    "WorldMapFrame", "SettingsPanel", "GameMenuFrame",
}

local function PositionWindow(Frame)
    local Window = Windows[Frame]
    if InCombatLockdown() then return end
    if Frame == WorldMapFrame and Frame:IsMaximized() then return end

    Frame:SetUserPlaced(false)
    if Window.Points then
        Frame:ClearAllPoints()
        for _, Point in ipairs(Window.Points) do Frame:SetPoint(unpack(Point)) end
    elseif Window.Detached then
        local Info = Window.Info
        if Info.checkFit == 1 then UIPanelUpdateScaleForFit(Frame, Info.checkFitExtraWidth or 20, Info.checkFitExtraHeight or 20) end
        local Scale = Frame:GetScale()
        local Y = ClampUIPanelY(Frame, GetUIPanelLayoutAttribute("TOP_OFFSET") + (Info.yoffset or 0), Info.minYOffset, Info.bottomClampOverride)
        Frame:ClearAllPoints()
        if Info.area == "center" or Info.area == "centerOrLeft" then
            Frame:SetPoint("TOP", UIParent, "TOP", Info.centerXOffset or 0, Y / Scale)
        else
            Frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (GetUIPanelLayoutAttribute("LEFT_OFFSET") + (Info.xoffset or 0)) / Scale, Y / Scale)
        end
    end
end

local function StopMovingWindow(Frame)
    local Window = Windows[Frame]
    if not Window.Moving then return end
    Window.Moving = nil
    if InCombatLockdown() then return end
    Frame:StopMovingOrSizing()
    Frame:SetUserPlaced(false)
    Window.Points = {}
    for Index = 1, Frame:GetNumPoints() do Window.Points[Index] = {Frame:GetPoint(Index)} end
end

local function DetachWindow(Frame)
    local Window = Windows[Frame]
    local Info = Window.Info
    if Window.Detached or not Info or NativePanels[Frame:GetName()] or Info.centerFrameSkipAnchoring or Info.neverAllowOtherPanels == 1 then return end
    if Frame:IsShown() or InCombatLockdown() then return end

    SetUIPanelAttribute(Frame, "area", nil)
    Window.Detached = true
    if not tContains(UISpecialFrames, Frame:GetName()) then table.insert(UISpecialFrames, Frame:GetName()) end

    if Frame:IsProtected() then
        local Escape = CreateFrame("Button", nil, Frame, "SecureHandlerShowHideTemplate,SecureHandlerClickTemplate,SecureHandlerStateTemplate")
        Escape:SetFrameRef("window", Frame)
        Escape:SetAttribute("_onclick", [[ self:GetFrameRef("window"):Hide() ]])
        Escape:SetAttribute("_onhide", [[ self:ClearBindings() ]])
        Escape:SetAttribute("_onshow", [[
            if PlayerInCombat() then self:SetBindingClick(true, "ESCAPE", self) end
        ]])
        Escape:SetAttribute("_onstate-combat", [[
            self:ClearBindings()
            if newstate == "combat" and self:IsVisible() then self:SetBindingClick(true, "ESCAPE", self) end
        ]])
        RegisterStateDriver(Escape, "combat", "[combat] combat; normal")
    end
    PositionWindow(Frame)
end

local function RegisterWindow(Frame, Info)
    if not Frame or Frame:IsForbidden() or InCombatLockdown() then return end
    if Info and (Info.area == "full" or Info.neverAllowOtherPanels == 1) then return end
    -- Child panels such as PVPUIFrame must keep their anchors to the containing window.
    local Parent = Frame:GetParent()
    if Parent and UIPanelWindows[Parent:GetName()] then return end
    if Windows[Frame] then if Info then Windows[Frame].Info = Info end DetachWindow(Frame) return end

    Windows[Frame] = {Info = Info}
    Frame:SetMovable(true)
    Frame:SetClampedToScreen(true)

    -- A separate title handle preserves the window's existing mouse and drag scripts.
    local Handle = CreateFrame("Frame", nil, Frame)
    Handle:SetPoint("TOPLEFT", Frame, "TOPLEFT", 36, -2)
    Handle:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", -36, -2)
    Handle:SetHeight(24)
    Handle:SetFrameLevel(Frame:GetFrameLevel() + 10)
    Handle:EnableMouse(true)
    Handle:RegisterForDrag("LeftButton")
    Handle:SetScript("OnDragStart", function()
        if InCombatLockdown() or Frame == WorldMapFrame and Frame:IsMaximized() then return end
        local Window = Windows[Frame]
        Frame:StartMoving()
        Frame:SetUserPlaced(false)
        Window.Moving = true
    end)
    Handle:SetScript("OnDragStop", function() StopMovingWindow(Frame) end)
    Frame:HookScript("OnHide", function() StopMovingWindow(Frame) if Windows[Frame].Info and not Windows[Frame].Detached and not NativePanels[Frame:GetName()] then C_Timer.After(0, function() DetachWindow(Frame) end) end end)
    Frame:HookScript("OnShow", function() if Windows[Frame].Detached or Windows[Frame].Points then PositionWindow(Frame) end end)
    DetachWindow(Frame)
end

function Private:SetupMovableWindows()
    if EventFrame then return end
    EventFrame = CreateFrame("Frame")
    EventFrame:SetScript("OnEvent", function(_, Event, Interaction)
        if InCombatLockdown() then return end
        if Event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE" then if Interaction == Enum.PlayerInteractionType.Gossip then HideUIPanel(GossipFrame) elseif Interaction == Enum.PlayerInteractionType.QuestGiver then HideUIPanel(QuestFrame) end return end
        for Name, Info in pairs(UIPanelWindows) do RegisterWindow(_G[Name], Info) end
        for _, Name in ipairs(AdditionalWindows) do RegisterWindow(_G[Name], UIPanelWindows[Name]) end
    end)
    for _, Event in ipairs({"ADDON_LOADED", "PLAYER_REGEN_ENABLED", "PLAYER_INTERACTION_MANAGER_FRAME_HIDE"}) do EventFrame:RegisterEvent(Event) end
    hooksecurefunc("RegisterUIPanel", function(Frame, Info) RegisterWindow(Frame, Info) end)
    for _, Function in ipairs({"UpdateUIPanelPositions", "RestoreUIPanelArea"}) do
        hooksecurefunc(Function, function()
            for Frame, Window in pairs(Windows) do
                if Window.Points and not Window.Moving and Frame:IsShown() then PositionWindow(Frame) end
            end
        end)
    end
    EventFrame:GetScript("OnEvent")(EventFrame)
end
