local Private = select(2, ...)
local AG = Private.AG
Private.GUI = {}

function Private.GUI:LayoutOptions(ParentContainer, DB, UpdateFunction, SizeLimits)
    local isScalable = DB.Scale ~= nil
    local isSizable = DB.Size ~= nil
    local hasSpacing = DB.Spacing ~= nil or DB.Layout[5] ~= nil
    local hasGrowthDirection = DB.GrowthDirection ~= nil or DB.Layout[6] ~= nil
    local hasNum = DB.Num ~= nil
    local hasHoldTime = DB.HoldTime ~= nil
    local hasAnchorParent = DB.AnchorParent ~= nil
    local hasOOCOpacity = DB.OOCOpacity ~= nil
    local hasWrap = DB.WrapAfter ~= nil
    local hasHeight = DB.Height ~= nil
    local hasSeparator = DB.Separator ~= nil

    local InlineGroup = Private.GUI:CreateInlineGroup(ParentContainer, "Layout Options", "CENTER")

    local AnchorFromDropdown = AG:Create("Dropdown")
    AnchorFromDropdown:SetLabel("Anchor From")
    AnchorFromDropdown:SetList(Private.AnchorPoints)
    AnchorFromDropdown:SetValue(DB.Layout[1])
    AnchorFromDropdown:SetRelativeWidth((hasGrowthDirection and 0.33) or (hasAnchorParent and 0.33) or (hasSeparator and 0.33) or 0.5)
    AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[1] = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(AnchorFromDropdown)

    if hasAnchorParent then
        local AnchorParentEditBox = AG:Create("EditBox")
        AnchorParentEditBox:SetLabel("Anchor Parent")
        AnchorParentEditBox:SetText(DB.AnchorParent or "")
        AnchorParentEditBox:SetRelativeWidth(0.33)
        AnchorParentEditBox:SetCallback("OnEnterPressed", function(_, _, Value) DB.AnchorParent = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(AnchorParentEditBox)
    end

    local AnchorTo = AG:Create("Dropdown")
    AnchorTo:SetLabel("Anchor To")
    AnchorTo:SetList(Private.AnchorPoints)
    AnchorTo:SetValue(DB.Layout[2])
    AnchorTo:SetRelativeWidth((hasGrowthDirection and 0.33) or (hasAnchorParent and 0.33) or (hasSeparator and 0.33) or 0.5)
    AnchorTo:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[2] = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(AnchorTo)

    if hasSeparator then
        local Separator = AG:Create("Dropdown")
        Separator:SetLabel("Separator")
        Separator:SetList(Private.Separators)
        Separator:SetValue(DB.Separator)
        Separator:SetRelativeWidth(0.33)
        Separator:SetCallback("OnValueChanged", function(_, _, Value) DB.Separator = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(Separator)
    end

    if hasGrowthDirection then
        local GrowthDirection = AG:Create("Dropdown")
        GrowthDirection:SetLabel("Growth Direction")
        GrowthDirection:SetList(DB.GrowthDirection ~= nil and {UP = "Up", DOWN = "Down"} or Private.GrowthDirections)
        GrowthDirection:SetValue(DB.GrowthDirection or DB.Layout[6])
        GrowthDirection:SetRelativeWidth(0.33)
        GrowthDirection:SetCallback("OnValueChanged", function(_, _, Value)
            if DB.GrowthDirection ~= nil then DB.GrowthDirection = Value else DB.Layout[6] = Value end
            if UpdateFunction then UpdateFunction() end
        end)
        InlineGroup:AddChild(GrowthDirection)
    end

    if isSizable then
        local MinWidth, MinHeight = 0, 0
        if SizeLimits then MinWidth, MinHeight = SizeLimits() end
        local Width, Height
        local function UpdateSize()
            if UpdateFunction then UpdateFunction() end
            if SizeLimits then
                local WidthLimit, HeightLimit = SizeLimits()
                Width:SetSliderValues(WidthLimit, math.max(3000, WidthLimit), 1)
                Height:SetSliderValues(HeightLimit, math.max(3000, HeightLimit), 1)
            end
            Width:SetValue(DB.Size[1])
            Height:SetValue(DB.Size[2])
        end

        Width = AG:Create("Slider")
        Width:SetLabel("Width")
        Width:SetValue(DB.Size[1])
        Width:SetSliderValues(MinWidth, math.max(3000, MinWidth), 1)
        Width:SetRelativeWidth(((hasWrap or DB.Spacing ~= nil) and 0.33) or 0.5)
        Width:SetCallback("OnValueChanged", function(_, _, Value) DB.Size[1] = Value UpdateSize() end)
        InlineGroup:AddChild(Width)

        Height = AG:Create("Slider")
        Height:SetLabel("Height")
        Height:SetValue(DB.Size[2])
        Height:SetSliderValues(MinHeight, math.max(3000, MinHeight), 1)
        Height:SetRelativeWidth(((hasWrap or DB.Spacing ~= nil) and 0.33) or 0.5)
        Height:SetCallback("OnValueChanged", function(_, _, Value) DB.Size[2] = Value UpdateSize() end)
        InlineGroup:AddChild(Height)
    end

    local Spacing
    if hasSpacing then
        Spacing = AG:Create("Slider")
        Spacing:SetLabel("Spacing")
        Spacing:SetValue(DB.Spacing or DB.Layout[5])
        Spacing:SetSliderValues(0, DB.Spacing ~= nil and 20 or 10, 1)
        Spacing:SetRelativeWidth(0.33)
        Spacing:SetCallback("OnValueChanged", function(_, _, Value)
            if DB.Spacing ~= nil then DB.Spacing = Value else DB.Layout[5] = Value end
            if UpdateFunction then UpdateFunction() end
        end)
        if DB.Spacing ~= nil then InlineGroup:AddChild(Spacing) end
    end

    if hasWrap then
        local WrapAfter = AG:Create("Slider")
        WrapAfter:SetLabel("Wrap After")
        WrapAfter:SetValue(DB.WrapAfter)
        WrapAfter:SetSliderValues(1, 24, 1)
        WrapAfter:SetRelativeWidth(0.33)
        WrapAfter:SetCallback("OnValueChanged", function(_, _, Value) DB.WrapAfter = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(WrapAfter)
    end

    local XOffset = AG:Create("Slider")
    XOffset:SetLabel("X Offset")
    XOffset:SetValue(DB.Layout[3])
    XOffset:SetSliderValues(-3000, 3000, 0.1)
    XOffset:SetRelativeWidth((isScalable and 0.33) or (hasSpacing and 0.33) or (hasNum and 0.33) or (hasHoldTime and 0.33) or (hasOOCOpacity and 0.33) or (hasHeight and 0.33) or 0.5)
    XOffset:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[3] = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(XOffset)

    local YOffset = AG:Create("Slider")
    YOffset:SetLabel("Y Offset")
    YOffset:SetValue(DB.Layout[4])
    YOffset:SetSliderValues(-3000, 3000, 0.1)
    YOffset:SetRelativeWidth((isScalable and 0.33) or (hasSpacing and 0.33) or (hasNum and 0.33) or (hasHoldTime and 0.33) or (hasOOCOpacity and 0.33) or (hasHeight and 0.33) or 0.5)
    YOffset:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[4] = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(YOffset)

    if hasNum then
        local Num = AG:Create("Slider")
        Num:SetLabel("Maximum Bars")
        Num:SetValue(DB.Num)
        Num:SetSliderValues(1, 40, 1)
        Num:SetRelativeWidth(0.33)
        Num:SetCallback("OnValueChanged", function(_, _, Value) DB.Num = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(Num)
    end

    if hasOOCOpacity then
        local OOCOpacity = AG:Create("Slider")
        OOCOpacity:SetLabel("Opacity: Out of Combat")
        OOCOpacity:SetValue(DB.OOCOpacity)
        OOCOpacity:SetSliderValues(0, 1, 0.01)
        OOCOpacity:SetRelativeWidth(0.33)
        OOCOpacity:SetIsPercent(true)
        OOCOpacity:SetCallback("OnValueChanged", function(_, _, Value) DB.OOCOpacity = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(OOCOpacity)
    end

    if hasHoldTime then
        local HoldTime = AG:Create("Slider")
        HoldTime:SetLabel("Hold Time")
        HoldTime:SetValue(DB.HoldTime)
        HoldTime:SetSliderValues(0, 5, 0.1)
        HoldTime:SetRelativeWidth(0.33)
        HoldTime:SetCallback("OnValueChanged", function(_, _, Value) DB.HoldTime = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(HoldTime)
    end

    if hasSpacing and DB.Spacing == nil then InlineGroup:AddChild(Spacing) end

    if isScalable then
        local Scale = AG:Create("Slider")
        Scale:SetLabel("Scale")
        Scale:SetValue(DB.Scale)
        Scale:SetSliderValues(0.1, 3, 0.01)
        Scale:SetRelativeWidth(0.33)
        Scale:SetIsPercent(true)
        Scale:SetCallback("OnValueChanged", function(_, _, Value) DB.Scale = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(Scale)
    end

    if hasHeight then
        local Height = AG:Create("Slider")
        Height:SetLabel("Height")
        Height:SetValue(DB.Height)
        Height:SetSliderValues(0, 500, 1)
        Height:SetRelativeWidth(0.33)
        Height:SetCallback("OnValueChanged", function(_, _, Value) DB.Height = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(Height)
    end

    return InlineGroup
end

function Private.GUI:FontOptions(ParentContainer, DB, UpdateFunction, HideLayout)
    local hasColour = DB.Colour ~= nil
    local hasColourByClass = DB.ColourByClass ~= nil
    local hasPosition = DB.Layout ~= nil and not HideLayout

    local InlineGroup = Private.GUI:CreateInlineGroup(ParentContainer, "Font Options", "CENTER")

    local FontDropdown = AG:Create("LSM30_Font")
    FontDropdown:SetLabel("Font")
    FontDropdown:SetList(Private.LSM:HashTable("font"))
    FontDropdown:SetValue(DB.Font)
    FontDropdown:SetRelativeWidth(0.33)
    FontDropdown:SetCallback("OnValueChanged", function(_, _, Value) FontDropdown:SetValue(Value) DB.Font = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(FontDropdown)

    local FontSize = AG:Create("Slider")
    FontSize:SetLabel("Font Size")
    FontSize:SetValue(DB.FontSize)
    FontSize:SetSliderValues(6, 72, 1)
    FontSize:SetRelativeWidth(0.33)
    FontSize:SetCallback("OnValueChanged", function(_, _, Value) DB.FontSize = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(FontSize)

    local FontFlag = AG:Create("Dropdown")
    FontFlag:SetLabel("Font Flag")
    FontFlag:SetList(Private.FontFlags)
    FontFlag:SetValue(DB.FontFlag)
    FontFlag:SetRelativeWidth(0.33)
    FontFlag:SetCallback("OnValueChanged", function(_, _, Value) DB.FontFlag = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(FontFlag)

    if hasColour then
        Private.GUI:CreateColourPicker(InlineGroup, "Colour", 0.5, DB, "Colour", UpdateFunction)
    end

    if hasColourByClass then
        Private.GUI:CreateToggle(InlineGroup, "Colour by Class", nil, 0.5, DB, "ColourByClass", UpdateFunction)
    end

    if hasPosition then
        Private.GUI:CreateHeading(InlineGroup, "Layout Options")
        local AnchorFromDropdown = AG:Create("Dropdown")
        AnchorFromDropdown:SetLabel("Anchor From")
        AnchorFromDropdown:SetList(Private.AnchorPoints)
        AnchorFromDropdown:SetValue(DB.Layout[1])
        AnchorFromDropdown:SetRelativeWidth(0.5)
        AnchorFromDropdown:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[1] = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(AnchorFromDropdown)

        local AnchorToDropdown = AG:Create("Dropdown")
        AnchorToDropdown:SetLabel("Anchor To")
        AnchorToDropdown:SetList(Private.AnchorPoints)
        AnchorToDropdown:SetValue(DB.Layout[2])
        AnchorToDropdown:SetRelativeWidth(0.5)
        AnchorToDropdown:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[2] = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(AnchorToDropdown)

        local XOffset = AG:Create("Slider")
        XOffset:SetLabel("X Offset")
        XOffset:SetValue(DB.Layout[3])
        XOffset:SetSliderValues(-3000, 3000, 0.1)
        XOffset:SetRelativeWidth(0.5)
        XOffset:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[3] = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(XOffset)

        local YOffset = AG:Create("Slider")
        YOffset:SetLabel("Y Offset")
        YOffset:SetValue(DB.Layout[4])
        YOffset:SetSliderValues(-3000, 3000, 0.1)
        YOffset:SetRelativeWidth(0.5)
        YOffset:SetCallback("OnValueChanged", function(_, _, Value) DB.Layout[4] = Value if UpdateFunction then UpdateFunction() end end)
        InlineGroup:AddChild(YOffset)
    end

    return InlineGroup
end

function Private.GUI:SoundOptions(ParentContainer, DB, UpdateFunction)
    local InlineGroup = Private.GUI:CreateInlineGroup(ParentContainer, "Sound Options", "CENTER")

    local Dropdown = AG:Create("LSM30_Sound")
    Dropdown:SetLabel("Sound")
    Dropdown:SetList(Private.LSM:HashTable("sound"))
    Dropdown:SetValue(DB.Sound)
    Dropdown:SetRelativeWidth(0.5)
    Dropdown:SetCallback("OnValueChanged", function(_, _, Value) Dropdown:SetValue(Value) DB.Sound = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(Dropdown)

    local ChannelDropdown = AG:Create("Dropdown")
    ChannelDropdown:SetLabel("Sound Channel")
    ChannelDropdown:SetList({Master = "Master", SFX = "SFX", Music = "Music", Ambience = "Ambience"})
    ChannelDropdown:SetValue(DB.SoundChannel)
    ChannelDropdown:SetRelativeWidth(0.5)
    ChannelDropdown:SetCallback("OnValueChanged", function(_, _, Value) DB.SoundChannel = Value if UpdateFunction then UpdateFunction() end end)
    InlineGroup:AddChild(ChannelDropdown)

    return InlineGroup
end

function Private.GUI:DamageMeterOptions(ParentContainer, DB, UpdateFunction)
    ParentContainer:SetLayout("Flow")
    local General = Private.GUI:CreateInlineGroup(ParentContainer, "General", "CENTER")
    Private.GUI:CreateToggle(General, "Auto Reset on Mythic Plus", nil, 0.5, Private.DB.global.DamageMeter, "AutoResetOnMythicPlus")
    Private.GUI:CreateToggle(General, "Preview", nil, 0.5, Private, "DamageMeterTestMode", function() Private:SetDamageMeterTestMode(Private.DamageMeterTestMode) end)

    local TabGroup = AG:Create("TabGroup")
    TabGroup:SetLayout("Fill")
    TabGroup:SetFullWidth(true)
    TabGroup:SetFullHeight(true)
    TabGroup:SetTabs({
        { text = "Frame", value = "Frame" },
        { text = "Title Bar", value = "TitleBar" },
        { text = "Rows", value = "Rows" },
    })
    TabGroup:SetCallback("OnGroupSelected", function(_GF, _, Group)
        _GF:ReleaseChildren()
        local ScrollFrame = Private.GUI:CreateScrollFrame(_GF)
        if Group == "Frame" then
            Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, 1, DB, "Enable", function() if UpdateFunction then UpdateFunction() end Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable) end)
            Private.GUI:CreateToggle(ScrollFrame, "Show Backdrop", nil, 0.5, DB, "ShowBackdrop", UpdateFunction)
            Private.GUI:CreateColourPicker(ScrollFrame, "Background Colour", 0.5, DB, "BackgroundColour", UpdateFunction)

            Private.GUI:LayoutOptions(ScrollFrame, DB, UpdateFunction, function() return Private:ClampDamageMeterSize(DB) end)
            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        elseif Group == "TitleBar" then
            Private.GUI:CreateToggle(ScrollFrame, "Enable", nil, 1, DB.TitleBar, "Enable", function() if UpdateFunction then UpdateFunction() end Private.GUI:UpdateGUIState(ScrollFrame, DB.TitleBar.Enable, DB.Enable) end)
            Private.GUI:CreateToggle(ScrollFrame, "Show Backdrop", nil, 0.5, DB.TitleBar, "ShowBackdrop", UpdateFunction)

            local Height = AG:Create("Slider")
            Height:SetLabel("Height")
            Height:SetValue(DB.TitleBar.Height)
            Height:SetSliderValues(10, 60, 1)
            Height:SetRelativeWidth(0.5)
            Height:SetCallback("OnValueChanged", function(_, _, Value) DB.TitleBar.Height = Value if UpdateFunction then UpdateFunction() end end)
            ScrollFrame:AddChild(Height)

            local Icons = Private.GUI:CreateInlineGroup(ScrollFrame, "Icons", "CENTER")
            Private.GUI:CreateToggle(Icons, "Mouseover Icons", nil, 1, DB.TitleBar, "MouseoverIcons", UpdateFunction)
            Private.GUI:CreateToggle(Icons, "Reset Button", nil, 0.5, DB.TitleBar.Icons, "ResetButton", UpdateFunction)
            Private.GUI:CreateToggle(Icons, "Encounters Button", nil, 0.5, DB.TitleBar.Icons, "EncountersButton", UpdateFunction)
            Private.GUI:LayoutOptions(ScrollFrame, {Layout = DB.TitleBar.Layout}, UpdateFunction)

            local TextGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Text", "CENTER")
            Private.GUI:FontOptions(TextGroup, DB.TitleBar.Text, UpdateFunction)

            Private.GUI:UpdateGUIState(ScrollFrame, DB.TitleBar.Enable, DB.Enable)
        elseif Group == "Rows" then
            local Num = AG:Create("Slider")
            Num:SetLabel("Number of Rows")
            Num:SetValue(DB.Rows.Num)
            Num:SetSliderValues(1, 40, 1)
            Num:SetRelativeWidth(0.33)
            Num:SetCallback("OnValueChanged", function(_, _, Value) DB.Rows.Num = Value if UpdateFunction then UpdateFunction() end end)
            ScrollFrame:AddChild(Num)

            local Spacing = AG:Create("Slider")
            Spacing:SetLabel("Spacing")
            Spacing:SetValue(DB.Rows.Spacing)
            Spacing:SetSliderValues(0, 10, 1)
            Spacing:SetRelativeWidth(0.33)
            Spacing:SetCallback("OnValueChanged", function(_, _, Value) DB.Rows.Spacing = Value if UpdateFunction then UpdateFunction() end end)
            ScrollFrame:AddChild(Spacing)

            local Texture = AG:Create("LSM30_Statusbar")
            Texture:SetLabel("Texture")
            Texture:SetList(Private.LSM:HashTable("statusbar"))
            Texture:SetValue(DB.Rows.Texture)
            Texture:SetRelativeWidth(0.33)
            Texture:SetCallback("OnValueChanged", function(_, _, Value) Texture:SetValue(Value) DB.Rows.Texture = Value if UpdateFunction then UpdateFunction() end end)
            ScrollFrame:AddChild(Texture)

            local NameGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Name", "CENTER")
            Private.GUI:FontOptions(NameGroup, DB.Rows.Name, UpdateFunction)

            local AmountGroup = Private.GUI:CreateInlineGroup(ScrollFrame, "Amount", "CENTER")

            local Format = AG:Create("Dropdown")
            Format:SetLabel("Format")
            Format:SetList(Private.MeterAmountFormats)
            Format:SetValue(DB.Rows.Amount.Format)
            Format:SetRelativeWidth(1)
            Format:SetCallback("OnValueChanged", function(_, _, Value) DB.Rows.Amount.Format = Value if UpdateFunction then UpdateFunction() end end)
            AmountGroup:AddChild(Format)

            Private.GUI:FontOptions(AmountGroup, DB.Rows.Amount, UpdateFunction)
            Private.GUI:UpdateGUIState(ScrollFrame, DB.Enable)
        end
        ScrollFrame:DoLayout()
    end)
    TabGroup:SelectTab("Frame")
    ParentContainer:AddChild(TabGroup)
    return TabGroup
end

function Private.GUI:CreateInlineGroup(ParentContainer, Title, JustifyH)
    local InlineGroup = AG:Create("InlineGroup")
    InlineGroup:SetTitle("|cFF6080FF" .. Title .. "|r")
    InlineGroup.titletext:SetJustifyH(JustifyH and JustifyH or "LEFT")
    InlineGroup.titletext:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE, SLUG")
    InlineGroup:SetLayout("Flow")
    InlineGroup:SetFullWidth(true)
    ParentContainer:AddChild(InlineGroup)

    return InlineGroup
end

function Private.GUI:CreateHeading(ParentContainer, Text)
    local Heading = AG:Create("Heading")
    Heading:SetText("|cFFCCCCCC" .. Text .. "|r")
    Heading.label:SetJustifyH("CENTER")
    Heading.label:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE, SLUG")
    Heading:SetFullWidth(true)
    ParentContainer:AddChild(Heading)

    return Heading
end

function Private.GUI:CreateEditBox(ParentContainer, Label, Width, DB, Key, UpdateFunction)
    local EditBox = AG:Create("EditBox")
    EditBox:SetLabel(Label and Label or "")
    EditBox:SetText(DB[Key])
    EditBox:SetCallback("OnTextChanged", function(_, _, Value) DB[Key] = Value if UpdateFunction then UpdateFunction() end end)
    EditBox:SetRelativeWidth(Width and Width or 1)
    ParentContainer:AddChild(EditBox)

    return EditBox
end

function Private.GUI:CreateColourPicker(ParentContainer, Label, Width, DB, Key, UpdateFunction)
    local ColourPicker = AG:Create("ColorPicker")
    ColourPicker:SetLabel(Label)
    ColourPicker:SetColor(DB[Key][1], DB[Key][2], DB[Key][3], 1)
    ColourPicker:SetCallback("OnValueChanged", function(_, _, r, g, b) DB[Key][1] = r DB[Key][2] = g DB[Key][3] = b if UpdateFunction then UpdateFunction() end end)
    ColourPicker:SetRelativeWidth(Width and Width or 1)
    ColourPicker:SetHasAlpha(false)
    ParentContainer:AddChild(ColourPicker)

    return ColourPicker
end

function Private.GUI:CreateScrollFrame(ParentContainer)
    local ScrollFrame = AG:Create("ScrollFrame")
    ScrollFrame:SetFullWidth(true)
    ScrollFrame:SetFullHeight(true)
    ScrollFrame:SetLayout("Flow")
    ParentContainer:AddChild(ScrollFrame)

    return ScrollFrame
end

function Private.GUI:CreateToggle(ParentContainer, Label, Desc, Width, DB, Key, UpdateFunction)
    local Toggle = AG:Create("CheckBox")
    Toggle:SetUserData("IsEnableToggle", Key == "Enable")
    Toggle:SetLabel(Label)
    Toggle:SetDescription(Desc and "|cFFCCCCCC" .. Desc .. "|r" or nil)
    Toggle:SetValue(DB[Key])
    Toggle:SetCallback("OnValueChanged", function(_, _, Value) DB[Key] = Value if UpdateFunction then UpdateFunction() end end)
    Toggle:SetRelativeWidth(Width and Width or 1)
    ParentContainer:AddChild(Toggle)

    return Toggle
end

function Private.GUI:CreateButton(ParentContainer, Label, Width, Callback, IsDisabled)
    local Button = AG:Create("Button")
    Button:SetText(Label .. (IsDisabled and " (Not Loaded)" or ""))
    Button:SetRelativeWidth(Width and Width or 0.5)
    Button:SetHeight(30)
    Button:SetCallback("OnClick", Callback)
    Button:SetDisabled(IsDisabled and IsDisabled or false)
    Button.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE, SLUG")
    Button.text:SetJustifyH("CENTER")
    Button.text:SetJustifyV("MIDDLE")
    Button.text:SetVertexColor(1, 1, 1, 1)
    ParentContainer:AddChild(Button)

    return Button
end

function Private.GUI:UpdateGUIState(ParentContainer, IsEnabled, ParentEnabled)
    local IsDisabled = not IsEnabled or ParentEnabled == false
    for _, Child in ipairs(ParentContainer.children) do
        if Child.SetDisabled then
            if Child:GetUserData("IsEnableToggle") then
                Child:SetDisabled(ParentEnabled == false)
            else
                Child:SetDisabled(IsDisabled)
            end
        end
        if Child.children then Private.GUI:UpdateGUIState(Child, IsEnabled, not IsDisabled) end
    end
end
