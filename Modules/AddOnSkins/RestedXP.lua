local Private = select(2, ...)

local Rows = {}

local function AnchorTooltip(Owner)
    GameTooltip:SetOwner(Owner, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetClampRectInsets(0, 0, 0, 0)
    GameTooltip:SetPoint("TOPLEFT", Private.RestedXPGuideFrame, "TOPRIGHT", 1, 0)
end

local function Tooltip_OnLeave()
    GameTooltip:SetClampRectInsets(0, 0, 25, 0)
    GameTooltip_Hide()
end

local function Row_OnEnter(Row)
    AnchorTooltip(Row)
    GameTooltip:AddLine(string.format("Step %d", Row.Step.index), Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b)
    for _, Element in ipairs(Row.Step.elements) do
        if type(Element.text) == "string" and Element.text ~= " " then
            GameTooltip:AddLine(RXP.ReplaceNpcIds(Element.text):gsub("|T.-|t", ""), 1, 1, 1, true)
        end
    end
    GameTooltip:Show()
end

local function AddRow(Index, Text, Alpha, Gap, Step, Header)
    local Row = Rows[Index]
    if not Row then
        Row = CreateFrame("Frame", nil, Private.RestedXPGuideFrame)
        Row:SetScript("OnEnter", Row_OnEnter)
        Row:SetScript("OnLeave", Tooltip_OnLeave)
        Row:SetMouseClickEnabled(false)
        Row.Number = Row:CreateFontString(nil, "OVERLAY")
        Row.Number:SetPoint("TOPLEFT", Row, "TOPLEFT", 0, 0)
        Row.Number:SetJustifyH("RIGHT")
        Row.Number:SetTextColor(0.6, 0.6, 0.6)
        Row.Text = Row:CreateFontString(nil, "OVERLAY")
        Row.Text:SetTextColor(1, 1, 1)
        Row.Lines = CreateFrame("Frame", nil, Row)
        Row.Lines:SetAllPoints()
        local LeftBorder = Row.Lines:CreateTexture(nil, "ARTWORK", nil, 0)
        LeftBorder:SetHeight(Private.E.mult * 5)
        LeftBorder:SetPoint("LEFT", Row, "LEFT", 0, 0)
        LeftBorder:SetPoint("RIGHT", Row.Text, "LEFT", -6, 0)
        LeftBorder:SetColorTexture(0, 0, 0, 1)
        local LeftLine = Row.Lines:CreateTexture(nil, "ARTWORK", nil, 1)
        LeftLine:SetPoint("TOPLEFT", LeftBorder, "TOPLEFT", Private.E.mult, -Private.E.mult)
        LeftLine:SetPoint("BOTTOMRIGHT", LeftBorder, "BOTTOMRIGHT", -Private.E.mult, Private.E.mult)
        LeftLine:SetColorTexture(Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b, 1)
        local RightBorder = Row.Lines:CreateTexture(nil, "ARTWORK", nil, 0)
        RightBorder:SetHeight(Private.E.mult * 5)
        RightBorder:SetPoint("LEFT", Row.Text, "RIGHT", 6, 0)
        RightBorder:SetPoint("RIGHT", Row, "RIGHT", 0, 0)
        RightBorder:SetColorTexture(0, 0, 0, 1)
        local RightLine = Row.Lines:CreateTexture(nil, "ARTWORK", nil, 1)
        RightLine:SetPoint("TOPLEFT", RightBorder, "TOPLEFT", Private.E.mult, -Private.E.mult)
        RightLine:SetPoint("BOTTOMRIGHT", RightBorder, "BOTTOMRIGHT", -Private.E.mult, Private.E.mult)
        RightLine:SetColorTexture(Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b, 1)
        Rows[Index] = Row
    end
    local FontSize = Private.DB.global.AddOnSkins.RestedXP.FontSize
    Private.E:SetFont(Row.Number, Private:FetchFont(Private.E.db.general.font), FontSize, Private.E.db.general.fontStyle)
    Private.E:SetFont(Row.Text, Private:FetchFont(Private.E.db.general.font), FontSize, Private.E.db.general.fontStyle)
    Row.Number:SetText(Step and Step.index .. " •" or "")
    Row.Text:SetText((Text:gsub("|T.-|t", "")))
    Row.Text:SetJustifyH(Header and "CENTER" or "LEFT")
    Row.Lines:SetShown(Header)
    Row:SetAlpha(Alpha)
    Row:SetMouseMotionEnabled(Step ~= nil)
    Row.Gap = Gap
    Row.Step = Step
    Row.Header = Header
end

local function RefreshGuide()
    local GuideFrame = Private.RestedXPGuideFrame
    local Guide = RXP.currentGuide
    local DB = Private.DB.global.AddOnSkins.RestedXP
    local Count, HasCurrentHeader = 0, false

    if not Guide or Guide.empty then
        Count = 1
        AddRow(1, "Right-click to choose a guide.", 1, 0)
    else
        local Level = UnitLevel("player")
        local Progress = RXP.GetGuideProgress()
        local Titles, StepIndex = 0, Progress + 1
        while Titles < DB.Lines and Guide.steps[StepIndex] do
            local Step = Guide.steps[StepIndex]
            if not (Step.completed or Step.hidewindow or Step.level > Level) then
                for _, Element in ipairs(Step.elements) do
                    if Titles < DB.Lines and type(Element.text) == "string" and Element.text ~= " " and not (Element.textOnly or Element.completed or Element.skip) then
                        if Titles == 0 then
                            Count = 1
                            AddRow(1, "|c" .. Private.E.AccentColour .. "Upcoming Steps|r", 1, 0, nil, true)
                        end
                        Count, Titles = Count + 1, Titles + 1
                        AddRow(Count, RXP.ReplaceNpcIds(Element.text), 0.45, 4, Step)
                    end
                end
            end
            StepIndex = StepIndex + 1
        end

        local CurrentStep = Guide.steps[Progress]
        if CurrentStep and not CurrentStep.hidewindow then
            for _, Element in ipairs(CurrentStep.elements) do
                if type(Element.text) == "string" and Element.text ~= " " and (Element.textOnly or not (Element.completed or Element.skip)) then
                    if not HasCurrentHeader then
                        Count = Count + 1
                        HasCurrentHeader = true
                        AddRow(Count, "|c" .. Private.E.AccentColour .. "Current Step|r", 1, 9, nil, true)
                    end
                    Count = Count + 1
                    AddRow(Count, RXP.ReplaceNpcIds(Element.text), 1, 4, CurrentStep)
                end
            end
        end
    end

    local NumberWidth, TextWidest, HeaderWidest = 0, 0, 0
    for Index = 1, Count do
        local Row = Rows[Index]
        if Row.Header then
            HeaderWidest = math.max(HeaderWidest, Row.Text:GetUnboundedStringWidth())
        else
            NumberWidth = math.max(NumberWidth, Row.Number:GetUnboundedStringWidth())
            TextWidest = math.max(TextWidest, Row.Text:GetUnboundedStringWidth())
        end
    end

    local Width = math.min(math.max(HeaderWidest + 56, TextWidest + NumberWidth + 16, 120), 450)
    local Height = 6
    for Index = 1, Count do
        local Row = Rows[Index]
        Height = Height + (Index > 1 and Row.Gap or 0)
        Row.Number:SetWidth(NumberWidth)
        Row.Text:ClearAllPoints()
        if Row.Header then
            Row.Text:SetWidth(0)
            Row.Text:SetPoint("TOP", Row, "TOP", 0, 0)
        else
            local Indent = Row.Step and NumberWidth + 4 or 0
            Row.Text:SetWidth(Width - 12 - Indent)
            Row.Text:SetPoint("TOPLEFT", Row, "TOPLEFT", Indent, 0)
        end
        Row:ClearAllPoints()
        Row:SetPoint("TOPLEFT", GuideFrame, "TOPLEFT", 6, -Height)
        Row:SetSize(Width - 12, Row.Text:GetStringHeight())
        Row:Show()
        Height = Height + Row.Text:GetStringHeight()
    end
    for Index = Count + 1, #Rows do Rows[Index]:Hide() end

    GuideFrame:SetSize(Width, Height + 6)
    GuideFrame:SetShown(Count > 0 and RXP.RXPFrame:IsShown())
end

function Private:SetupRestedXPSkin()
    if not Private.DB.global.AddOnSkins.RestedXP.Enable then return end
    if not C_AddOns.IsAddOnLoaded("RXPGuides") then return end
    if RXP.v2:IsEnabled() then return end

    local RXPFrame = RXP.RXPFrame
    RXPFrame.savePosition = false
    RXPFrame:SetClampedToScreen(false)
    RXPFrame:ClearAllPoints()
    RXPFrame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -3000, -3000)

    local GuideFrame = CreateFrame("Frame", "UnhaltedGuideFrame", UIParent)
    GuideFrame:SetSize(450, 120)
    GuideFrame:SetPoint("TOPLEFT", UIParent, "LEFT", 10, 150)
    GuideFrame:SetFrameStrata("LOW")
    GuideFrame:EnableMouse(true)
    GuideFrame:EnableMouseWheel(true)
    GuideFrame:Hide()
    Private.RestedXPGuideFrame = GuideFrame

    Private.E:CreateMover(GuideFrame, "UnhaltedGuideMover", "RestedXP Guide", nil, nil, nil, nil, nil, nil, true)

    GuideFrame:SetScript("OnMouseWheel", function(_, Delta)
        local Guide = RXP.currentGuide
        if not Guide or Guide.empty then return end
        RXP.SetStep(math.min(math.max(RXP.GetGuideProgress() - Delta, 1), #Guide.steps))
    end)
    GuideFrame:SetScript("OnMouseUp", function(_, Button)
        if Button ~= "RightButton" then return end
        GameTooltip:Hide()
        RXPFrame.DropDownMenu()
    end)
    GuideFrame:SetScript("OnEnter", function(Frame)
        local Guide = RXP.currentGuide
        AnchorTooltip(Frame)
        if Guide and not Guide.empty then
            GameTooltip:AddDoubleLine(Guide.displayname or Guide.name, string.format("%d/%d", RXP.GetGuideProgress(), #Guide.steps), 1, 1, 1, 0.6, 0.6, 0.6)
        end
        GameTooltip:AddDoubleLine("Scroll", "Previous / Next Step", 0.6, 0.6, 0.6, 1, 1, 1)
        GameTooltip:AddDoubleLine("Right-Click", "RestedXP Menu", 0.6, 0.6, 0.6, 1, 1, 1)
        GameTooltip:Show()
    end)
    GuideFrame:SetScript("OnLeave", Tooltip_OnLeave)

    hooksecurefunc(RXPFrame.CurrentStepFrame, "UpdateText", RefreshGuide)
    hooksecurefunc(RXP, "UpdateStepCompletion", RefreshGuide)
    hooksecurefunc(RXP, "LoadGuide", RefreshGuide)
    RXPFrame:HookScript("OnShow", RefreshGuide)
    RXPFrame:HookScript("OnHide", RefreshGuide)
    hooksecurefunc(RXP, "SortTimers", function()
        RXPFrame.BarContainer:ClearAllPoints()
        RXPFrame.BarContainer:SetPoint("TOPLEFT", GuideFrame, "BOTTOMLEFT", 0, -2)
        RXPFrame.BarContainer:SetPoint("TOPRIGHT", GuideFrame, "BOTTOMRIGHT", 0, -2)
    end)

    RXP:SortTimers()
    RefreshGuide()
end

function Private:UpdateRestedXPSkin()
    if not Private.RestedXPGuideFrame then return end
    RefreshGuide()
end
