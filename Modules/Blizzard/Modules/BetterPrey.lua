local Private = select(2, ...)
local HookedContainers = {}
local HookedWidgets = {}
local StageNames = {
    [Enum.PreyHuntProgressState.Cold] = "Cold",
    [Enum.PreyHuntProgressState.Warm] = "Warm",
    [Enum.PreyHuntProgressState.Hot] = "Hot",
    [Enum.PreyHuntProgressState.Final] = "Final",
}
local StageColours = {
    [Enum.PreyHuntProgressState.Cold] = {96/255, 128/255, 1},
    [Enum.PreyHuntProgressState.Warm] = {1, 0.82, 0},
    [Enum.PreyHuntProgressState.Hot] = {1, 0.5, 0},
    [Enum.PreyHuntProgressState.Final] = {204/255, 64/255, 64/255},
}

local function SuppressPreyWidget(Widget)
    if not HookedWidgets[Widget] then
        hooksecurefunc(Widget, "SetAlpha", function(_, Alpha)
            if Private.DB.global.Blizzard.BetterPrey.Enable and Alpha ~= 0 then Widget:SetAlpha(0) end
        end)
        HookedWidgets[Widget] = true
    end

    -- Keep the widget shown so Blizzard can animate it out and release its pool.
    -- The XML fade-in restores alpha directly, bypassing the SetAlpha hook.
    Widget.FadeInAnim:Stop()
    Widget:SetAlpha(0)
    Widget:EnableMouse(false)
    Widget:ClearEffects()
end

function Private:RefreshBetterPrey()
    local Frame = Private.BetterPreyFrame
    if not Frame or not Private.DB.global.Blizzard.BetterPrey.Enable then return end

    local ActiveInfo
    for Container in pairs(UIWidgetManager.registeredWidgetContainers) do
        if not Container.attachedUnit then
            for ID, Widget in pairs(Container.widgetFrames) do
                if Widget.widgetType == Enum.UIWidgetVisualizationType.PreyHuntProgress then
                    SuppressPreyWidget(Widget)
                    local Info = C_UIWidgetManager.GetPreyHuntProgressWidgetVisualizationInfo(ID)
                    if Info and Info.shownState ~= Enum.WidgetShownState.Hidden and Widget:IsVisible() and not Widget.markedForRemove and StageColours[Info.progressState] then
                        ActiveInfo = Info
                    end
                end
            end
        end
    end

    if not ActiveInfo then
        Frame:Hide()
        return
    end

    -- Prey exposes stages, not an exact percentage of hunt progress.
    Frame.Bar:SetValue(ActiveInfo.progressState + 1)
    Frame.Text:SetText(StageNames[ActiveInfo.progressState])
    if Private.DB.global.Blizzard.BetterPrey.ColourByStage then
        Frame.Bar:SetStatusBarColor(unpack(StageColours[ActiveInfo.progressState]))
    else
        Frame.Bar:SetStatusBarColor(unpack(Private.ElvUI.media.rgbvaluecolor))
    end
    Frame:Show()
end

local function HookPreyContainer(_, Container)
    if Container.attachedUnit or HookedContainers[Container] then return end
    HookedContainers[Container] = true
    hooksecurefunc(Container, "ProcessWidget", function(_, _, WidgetType)
        if WidgetType == Enum.UIWidgetVisualizationType.PreyHuntProgress then Private:RefreshBetterPrey() end
    end)
    hooksecurefunc(Container, "ProcessAllWidgets", function() Private:RefreshBetterPrey() end)
    Container:HookScript("OnShow", function() Private:RefreshBetterPrey() end)
    Container:HookScript("OnHide", function() Private:RefreshBetterPrey() end)
    Private:RefreshBetterPrey()
end

function Private:SetupBetterPrey()
    local Frame = Private.BetterPreyFrame
    if not Frame then
        Frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        Frame:SetTemplate()
        Frame:EnableMouse(false)
        Frame:SetScript("OnEvent", function() Private:UpdateBetterPrey() end)
        Frame.Bar = CreateFrame("StatusBar", nil, Frame)
        Frame.Bar:EnableMouse(false)
        Frame.Bar:SetInside(Frame)
        Frame.Bar:SetMinMaxValues(0, 4)
        Frame.Ticks = {}
        for Index = 1, 3 do Frame.Ticks[Index] = Frame.Bar:CreateTexture(nil, "OVERLAY") end
        Frame.Text = Frame.Bar:CreateFontString(nil, "OVERLAY")
        Frame:Hide()
        Private.BetterPreyFrame = Frame

        hooksecurefunc(UIWidgetManager, "OnWidgetContainerRegistered", HookPreyContainer)
        hooksecurefunc(UIWidgetManager, "OnWidgetContainerUnregistered", function() Private:RefreshBetterPrey() end)
        hooksecurefunc(Private.ElvUI, "UpdateMedia", function() Private:UpdateBetterPrey() end)
    end

    Private:UpdateBetterPrey()
    for Container in pairs(UIWidgetManager.registeredWidgetContainers) do HookPreyContainer(nil, Container) end
end

function Private:UpdateBetterPrey()
    local DB = Private.DB.global.Blizzard.BetterPrey
    local Frame = Private.BetterPreyFrame
    if not Frame then Private:SetupBetterPrey() return end

    Frame:UnregisterAllEvents()
    if not DB.Enable then
        Frame:Hide()
        for Container in pairs(UIWidgetManager.registeredWidgetContainers) do
            if not Container.attachedUnit then
                for ID, Widget in pairs(Container.widgetFrames) do
                    if HookedWidgets[Widget] then
                        Widget:SetAlpha(1)
                        Container:ProcessWidget(ID, Widget.widgetType)
                    end
                end
            end
        end
        return
    end

    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Frame:SetSize(math.max(DB.Size[1], 12), math.max(DB.Size[2], 12))
    Frame.Bar:SetStatusBarTexture(Private.ElvUI.media.normTex)
    Frame.Text:SetFont(Private:FetchFont(DB.Text.Font), DB.Text.FontSize, DB.Text.FontFlag)
    Frame.Text:SetTextColor(1, 1, 1)
    Frame.Text:ClearAllPoints()
    Frame.Text:SetPoint(DB.Text.Layout[1], Frame.Bar, DB.Text.Layout[2], DB.Text.Layout[3], DB.Text.Layout[4])
    Frame.Text:SetJustifyH(Private.JustificationH[DB.Text.Layout[1]])
    Frame.Text:SetShown(DB.Text.Enable)
    local Pixel = PixelUtil.GetPixelToUIUnitFactor() / Frame:GetEffectiveScale()
    for Index, Tick in ipairs(Frame.Ticks) do
        Tick:SetColorTexture(unpack(Private.ElvUI.media.bordercolor))
        Tick:ClearAllPoints()
        Tick:SetPoint("TOPLEFT", Frame.Bar, "TOPLEFT", Frame.Bar:GetWidth() * Index / 4 - Pixel / 2, 0)
        Tick:SetPoint("BOTTOMLEFT", Frame.Bar, "BOTTOMLEFT", Frame.Bar:GetWidth() * Index / 4 - Pixel / 2, 0)
        Tick:SetWidth(Pixel)
    end
    Frame:RegisterEvent("UI_SCALE_CHANGED")
    Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    Private:RefreshBetterPrey()
end
