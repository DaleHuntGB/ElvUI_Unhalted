local Private = select(2, ...)

local function TitleBar_OnEnter(DMTitleBar)
    DMTitleBar:SetBackdropColor(0.3, 0.3, 0.3, 1)
    GameTooltip:SetOwner(DMTitleBar, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOMLEFT", DMTitleBar, "TOPLEFT", 0, 1)
    GameTooltip:ClearLines()
    GameTooltip:AddDoubleLine("Left-Click: ", "Toggle Overall / Current Session", 0.6, 0.6, 0.6, 1, 1, 1)
    GameTooltip:AddDoubleLine("Right-Click: ", "Open Menu", 0.6, 0.6, 0.6, 1, 1, 1)
    GameTooltip:AddDoubleLine("Middle-Click: ", "Reset", 0.6, 0.6, 0.6, 1, 1, 1)
    GameTooltip:Show()
end

local function TitleBar_OnLeave(DMTitleBar)
    DMTitleBar:SetBackdropColor(unpack(Private.DB.global.DamageMeter[1].BackgroundColour))
    GameTooltip:Hide()
end

local function DamageMeterMenu(DMFrame, rootDescription)
    local DMCategories = {
        { Name = DAMAGE_METER_CATEGORY_DAMAGE, Types = {Enum.DamageMeterType.DamageDone, Enum.DamageMeterType.Dps, Enum.DamageMeterType.DamageTaken, Enum.DamageMeterType.AvoidableDamageTaken, Enum.DamageMeterType.EnemyDamageTaken} },
        { Name = DAMAGE_METER_CATEGORY_HEALING, Types = {Enum.DamageMeterType.HealingDone, Enum.DamageMeterType.Hps, Enum.DamageMeterType.Absorbs} },
        { Name = DAMAGE_METER_CATEGORY_ACTIONS, Types = {Enum.DamageMeterType.Interrupts, Enum.DamageMeterType.Dispels, Enum.DamageMeterType.Deaths} },
    }

    for _, Category in ipairs(DMCategories) do
        local Menu = rootDescription:CreateButton(Category.Name)
        for _, MeterType in ipairs(Category.Types) do
            Menu:CreateRadio(Private.MeterTypes[MeterType],
                function(value) return DMFrame.DB.MeterType == value end,
                function(value) Private:SetDamageMeterType(DMFrame, value) end,
            MeterType)
        end
    end
end

local function EncounterMenu(DMFrame, rootDescription)
    local Sessions = C_DamageMeter.GetAvailableCombatSessions()
    for _, Session in ipairs(Sessions) do
        local Name = Session.name ~= "" and Session.name or DAMAGE_METER_COMBAT_NUMBER:format(Session.sessionID)
        if Session.durationSeconds then Name = ("%s [%s]"):format(Name, SecondsToClock(Session.durationSeconds)) end
        rootDescription:CreateRadio(Name,
            function(value) return DMFrame.EncounterSegment and DMFrame.EncounterSegment.sessionID == value.sessionID end,
            function(value) Private:SetEncounter(value) end,
        Session)
    end
    rootDescription:CreateRadio(DAMAGE_METER_CURRENT_SESSION,
        function() return not DMFrame.EncounterSegment and DMFrame.SessionType == Enum.DamageMeterSessionType.Current end,
        function() Private:SetEncounter(nil)
    end)
end

local function TitleBar_OnClick(DMTitleBar, Button)
    local DMFrame = DMTitleBar:GetParent()
    if Button == "LeftButton" then
        Private:SetDamageMeterType(DMFrame, DMFrame.DB.MeterType, DMFrame.SessionType == Enum.DamageMeterSessionType.Current and Enum.DamageMeterSessionType.Overall or Enum.DamageMeterSessionType.Current)
    elseif Button == "RightButton" then
        local RootDescription = MenuUtil.CreateRootMenuDescription(MenuVariants.GetDefaultContextMenuMixin())
        Menu.PopulateDescription(DamageMeterMenu, DMFrame, RootDescription)
        Menu.GetManager():OpenMenu(DMFrame, RootDescription, AnchorUtil.CreateAnchor("BOTTOMLEFT", DMTitleBar, "TOPLEFT", -1, -4))
    elseif Button == "MiddleButton" then
        C_DamageMeter.ResetAllCombatSessions()
        if Private.DamageMeterDrilldown then
            Private.DamageMeterDrilldown:Hide()
        end
    end
end

function Private:CreateDamageMeter(DMFrameName, DB)
    if not DB.Enabled then return end

    local DM = CreateFrame("Frame", DMFrameName, UIParent, "BackdropTemplate")
    DM.SessionType = DB.SessionType
    DM.Bars = {}
    DM.ScrollOffset = 0
    DM:EnableMouseWheel(true)
    DM:SetScript("OnMouseWheel", function(DMFrame, Delta) DMFrame.ScrollOffset = DMFrame.ScrollOffset - Delta; Private:PopulateDamageMeterBars(DMFrame, DMFrame.DB) end)

    DM.TitleBar = CreateFrame("Frame", nil, DM, "BackdropTemplate")
    DM.TitleBar:EnableMouse(true)
    DM.TitleBar:SetScript("OnEnter", TitleBar_OnEnter)
    DM.TitleBar:SetScript("OnLeave", TitleBar_OnLeave)
    DM.TitleBar:SetScript("OnMouseDown", TitleBar_OnClick)

    DM.Title = DM.TitleBar:CreateFontString(nil, "OVERLAY")
    DM.Title:SetJustifyH("LEFT")
    DM.Title:SetJustifyV("MIDDLE")

    DM.TitleBar.ResetButton = CreateFrame("Button", nil, DM.TitleBar)
    DM.TitleBar.ResetButton:SetSize(DB.TitleBar.Height * 0.7, DB.TitleBar.Height * 0.7)
    DM.TitleBar.ResetButton:SetPoint("RIGHT", DM.TitleBar, "RIGHT", -3, 0)
    DM.TitleBar.ResetButton:SetNormalTexture("Interface\\AddOns\\ElvUI_Unhalted\\Media\\DamageMeter\\Reset.png")
    DM.TitleBar.ResetButton:SetHighlightTexture("Interface\\AddOns\\ElvUI_Unhalted\\Media\\DamageMeter\\Reset_Highlight.png", "BLEND")
    DM.TitleBar.ResetButton:SetScript("OnClick", function() C_DamageMeter.ResetAllCombatSessions() end)

    DM.TitleBar.EncountersButton = CreateFrame("Button", nil, DM.TitleBar)
    DM.TitleBar.EncountersButton:SetSize(DB.TitleBar.Height * 0.5, DB.TitleBar.Height * 0.7)
    DM.TitleBar.EncountersButton:SetPoint("RIGHT", DM.TitleBar.ResetButton, "LEFT", -3, 0)
    DM.TitleBar.EncountersButton:SetNormalTexture("Interface\\AddOns\\ElvUI_Unhalted\\Media\\DamageMeter\\Encounters.png")
    DM.TitleBar.EncountersButton:SetHighlightTexture("Interface\\AddOns\\ElvUI_Unhalted\\Media\\DamageMeter\\Encounters_Highlight.png", "BLEND")
    DM.TitleBar.EncountersButton:SetScript("OnClick", function(Button)
        if not C_DamageMeter.IsDamageMeterAvailable() then return end
        local RootDescription = MenuUtil.CreateRootMenuDescription(MenuVariants.GetDefaultContextMenuMixin())
        Menu.PopulateDescription(EncounterMenu, DM, RootDescription)
        Menu.GetManager():OpenMenu(Button, RootDescription, AnchorUtil.CreateAnchor("BOTTOMRIGHT", DM.TitleBar, "TOPRIGHT", 1, -4))
    end)

    Private:LayoutDamageMeter(DM, DB)

    return DM
end

function Private:LayoutDamageMeter(DM, DB)
    DM.DB = DB
    DM:SetSize(DB.Size[1], DB.Size[2])
    DM:ClearAllPoints()
    DM:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    if DB.ShowBackdrop then
        DM:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
        DM:SetBackdropColor(unpack(DB.BackgroundColour))
        DM:SetBackdropBorderColor(0, 0, 0, 1)
    else
        DM:SetBackdrop(nil)
    end

    DM.TitleBar:SetSize(DB.Size[1], DB.TitleBar.Height)
    DM.TitleBar:ClearAllPoints()
    DM.TitleBar:SetPoint("BOTTOMLEFT", DM, "TOPLEFT", 0, 1)
    DM.TitleBar:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    DM.TitleBar:SetBackdropColor(unpack(DB.BackgroundColour))
    DM.TitleBar:SetBackdropBorderColor(0, 0, 0, 1)
    DM.TitleBar:SetShown(DB.TitleBar.Enabled)

    DM.Title:SetFont(Private.LSM:Fetch("font", DB.TitleBar.Font[1]), DB.TitleBar.Font[2], DB.TitleBar.Font[3])
    DM.Title:SetTextColor(unpack(DB.TitleBar.Colour))
    DM.Title:ClearAllPoints()
    DM.Title:SetPoint(DB.TitleBar.Layout[1], DM.TitleBar, DB.TitleBar.Layout[2], DB.TitleBar.Layout[3], DB.TitleBar.Layout[4])
    DM.Title:SetText(Private.MeterTypes[DB.MeterType])

    Private:LayoutDamageMeterBars(DM, DB)
end
