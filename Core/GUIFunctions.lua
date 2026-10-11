local Private = select(2, ...)
local ACH = Private.ElvUI.Libs.ACH
Private.GUI = {}
local GUI = Private.GUI

local MediaControls = {font = "SharedMediaFont", sound = "SharedMediaSound", statusbar = "SharedMediaStatusbar"}

local function BindOption(Option, Width, DB, Key, UpdateFunction)
    Option.width = "relative"
    Option.relWidth = Width or 1
    Option.get = function() return DB[Key] end
    Option.set = function(_, Value)
        DB[Key] = Value
        if UpdateFunction then UpdateFunction() end
    end
    return Option
end

function GUI:Toggle(Name, Desc, Order, Width, DB, Key, UpdateFunction)
    local Option = ACH:Toggle(Name, Desc, Order)
    Option.descStyle = "inline"
    return BindOption(Option, Width, DB, Key, UpdateFunction)
end

function GUI:Select(Name, Order, Width, Values, DB, Key, UpdateFunction)
    return BindOption(ACH:Select(Name, nil, Order, Values), Width, DB, Key, UpdateFunction)
end

function GUI:Range(Name, Order, Width, Min, Max, Step, DB, Key, UpdateFunction, IsPercent)
    return BindOption(ACH:Range(Name, nil, Order, {min = Min, max = Max, step = Step, isPercent = IsPercent}), Width, DB, Key, UpdateFunction)
end

function GUI:Input(Name, Order, Width, DB, Key, UpdateFunction)
    return BindOption(ACH:Input(Name or "", nil, Order), Width, DB, Key, UpdateFunction)
end

function GUI:Media(Name, Order, Width, MediaType, DB, Key, UpdateFunction)
    return BindOption(ACH[MediaControls[MediaType]](ACH, Name, nil, Order), Width, DB, Key, UpdateFunction)
end

function GUI:Colour(Name, Order, Width, DB, Key, UpdateFunction)
    local Option = ACH:Color(Name, nil, Order, false)
    Option.width = "relative"
    Option.relWidth = Width or 1
    Option.get = function() return DB[Key][1], DB[Key][2], DB[Key][3] end
    Option.set = function(_, R, G, B)
        DB[Key][1], DB[Key][2], DB[Key][3] = R, G, B
        if UpdateFunction then UpdateFunction() end
    end
    return Option
end

function GUI:Button(Name, Order, Width, Callback, IsDisabled)
    local Option = ACH:Execute(Name .. (IsDisabled and " (Not Loaded)" or ""), nil, Order, Callback)
    Option.width = "relative"
    Option.relWidth = Width or 0.5
    Option.disabled = IsDisabled or false
    return Option
end

function GUI:InlineGroup(Name, Order)
    local Group = ACH:Group("|cFF6080FF" .. Name .. "|r", nil, Order)
    Group.inline = true
    return Group
end

function GUI:DisableOptions(Group, DB, ParentDB)
    for Key, Option in pairs(Group.args) do
        Option.disabled = function()
            return (ParentDB and not ParentDB.Enable) or (Key ~= "Enable" and not DB.Enable)
        end
    end
end

function GUI:LayoutOptions(DB, UpdateFunction, SizeLimits)
    local Group = GUI:InlineGroup("Layout Options", 10)
    local Args = Group.args
    local HasSpacing = DB.Spacing ~= nil or DB.Layout[5] ~= nil
    local HasGrowthDirection = DB.GrowthDirection ~= nil or DB.Layout[6] ~= nil
    local AnchorWidth = (HasGrowthDirection or DB.AnchorParent ~= nil or DB.Separator ~= nil) and 0.33 or 0.5
    local OffsetWidth = (DB.Scale ~= nil or HasSpacing or DB.Num ~= nil or DB.HoldTime ~= nil or DB.OOCOpacity ~= nil or DB.Height ~= nil) and 0.33 or 0.5

    Args.AnchorFrom = GUI:Select("Anchor From", 1, AnchorWidth, Private.AnchorPoints, DB.Layout, 1, UpdateFunction)
    if DB.AnchorParent ~= nil then
        Args.AnchorParent = GUI:Input("Anchor Parent", 2, 0.33, DB, "AnchorParent", UpdateFunction)
    end
    Args.AnchorTo = GUI:Select("Anchor To", 3, AnchorWidth, Private.AnchorPoints, DB.Layout, 2, UpdateFunction)
    if DB.Separator ~= nil then
        Args.Separator = GUI:Select("Separator", 4, 0.33, Private.Separators, DB, "Separator", UpdateFunction)
    end
    if HasGrowthDirection then
        Args.GrowthDirection = GUI:Select("Growth Direction", 5, 0.33, DB.GrowthDirection ~= nil and {UP = "Up", DOWN = "Down"} or Private.GrowthDirections, DB.GrowthDirection ~= nil and DB or DB.Layout, DB.GrowthDirection ~= nil and "GrowthDirection" or 6, UpdateFunction)
    end
    if DB.Size ~= nil then
        local SizeWidth = (DB.WrapAfter ~= nil or DB.Spacing ~= nil) and 0.33 or 0.5
        Args.Width = GUI:Range("Width", 6, SizeWidth, 0, 3000, 1, DB.Size, 1, UpdateFunction)
        Args.Height = GUI:Range("Height", 7, SizeWidth, 0, 3000, 1, DB.Size, 2, UpdateFunction)
        if SizeLimits then
            Args.Width.min = function() return SizeLimits() end
            Args.Height.min = function() return select(2, SizeLimits()) end
            Args.Width.max = function()
                local MinWidth = SizeLimits()
                return math.max(3000, MinWidth)
            end
            Args.Height.max = function() return math.max(3000, select(2, SizeLimits())) end
        end
    end
    if HasSpacing then
        Args.Spacing = GUI:Range("Spacing", DB.Spacing ~= nil and 8 or 15, 0.33, 0, DB.Spacing ~= nil and 20 or 10, 1, DB.Spacing ~= nil and DB or DB.Layout, DB.Spacing ~= nil and "Spacing" or 5, UpdateFunction)
    end
    if DB.WrapAfter ~= nil then
        Args.WrapAfter = GUI:Range("Wrap After", 9, 0.33, 1, 24, 1, DB, "WrapAfter", UpdateFunction)
    end
    Args.XOffset = GUI:Range("X Offset", 10, OffsetWidth, -3000, 3000, 0.1, DB.Layout, 3, UpdateFunction)
    Args.YOffset = GUI:Range("Y Offset", 11, OffsetWidth, -3000, 3000, 0.1, DB.Layout, 4, UpdateFunction)
    if DB.Num ~= nil then
        Args.Num = GUI:Range("Maximum Bars", 12, 0.33, 1, 40, 1, DB, "Num", UpdateFunction)
    end
    if DB.OOCOpacity ~= nil then
        Args.OOCOpacity = GUI:Range("Opacity: Out of Combat", 13, 0.33, 0, 1, 0.01, DB, "OOCOpacity", UpdateFunction, true)
    end
    if DB.HoldTime ~= nil then
        Args.HoldTime = GUI:Range("Hold Time", 14, 0.33, 0, 5, 0.1, DB, "HoldTime", UpdateFunction)
    end
    if DB.Scale ~= nil then
        Args.Scale = GUI:Range("Scale", 16, 0.33, 0.1, 3, 0.01, DB, "Scale", UpdateFunction, true)
    end
    if DB.Height ~= nil then
        Args.BarHeight = GUI:Range("Height", 17, 0.33, 0, 500, 1, DB, "Height", UpdateFunction)
    end
    return Group
end

function GUI:FontOptions(DB, UpdateFunction, HideLayout)
    local Group = GUI:InlineGroup("Font Options", 11)
    local Args = Group.args
    Args.Font = GUI:Media("Font", 1, 0.33, "font", DB, "Font", UpdateFunction)
    Args.FontSize = GUI:Range("Font Size", 2, 0.33, 6, 72, 1, DB, "FontSize", UpdateFunction)
    Args.FontFlag = GUI:Select("Font Flag", 3, 0.33, Private.FontFlags, DB, "FontFlag", UpdateFunction)
    if DB.Colour ~= nil then
        Args.Colour = GUI:Colour("Colour", 4, 0.5, DB, "Colour", UpdateFunction)
    end
    if DB.ColourByClass ~= nil then
        Args.ColourByClass = GUI:Toggle("Colour by Class", nil, 5, 0.5, DB, "ColourByClass", UpdateFunction)
    end
    if DB.Layout ~= nil and not HideLayout then
        Args.LayoutHeader = ACH:Header("|cFFCCCCCCLayout Options|r", 6)
        Args.AnchorFrom = GUI:Select("Anchor From", 7, 0.5, Private.AnchorPoints, DB.Layout, 1, UpdateFunction)
        Args.AnchorTo = GUI:Select("Anchor To", 8, 0.5, Private.AnchorPoints, DB.Layout, 2, UpdateFunction)
        Args.XOffset = GUI:Range("X Offset", 9, 0.5, -3000, 3000, 0.1, DB.Layout, 3, UpdateFunction)
        Args.YOffset = GUI:Range("Y Offset", 10, 0.5, -3000, 3000, 0.1, DB.Layout, 4, UpdateFunction)
    end
    return Group
end

function GUI:SoundOptions(DB, UpdateFunction)
    local Group = GUI:InlineGroup("Sound Options", 11)
    Group.args.Sound = GUI:Media("Sound", 1, 0.5, "sound", DB, "Sound", UpdateFunction)
    Group.args.SoundChannel = GUI:Select("Sound Channel", 2, 0.5, {Master = "Master", SFX = "SFX", Music = "Music", Ambience = "Ambience"}, DB, "SoundChannel", UpdateFunction)
    return Group
end

function GUI:DamageMeterOptions(DB, Order)
    local Update = function() Private:UpdateDamageMeter() end
    local Group = ACH:Group("Window #" .. Order, nil, Order, "tab")
    local General = GUI:InlineGroup("General", 1)
    General.args.AutoResetOnMythicPlus = GUI:Toggle("Auto Reset on Mythic Plus", nil, 1, 0.5, Private.DB.global.DamageMeter, "AutoResetOnMythicPlus")
    General.args.Preview = GUI:Toggle("Preview", nil, 2, 0.5, Private, "DamageMeterTestMode", function() Private:SetDamageMeterTestMode(Private.DamageMeterTestMode) end)
    Group.args.General = General

    local Frame = ACH:Group("Frame", nil, 2)
    Frame.args.Enable = GUI:Toggle("Enable", nil, 1, 1, DB, "Enable", Update)
    Frame.args.ShowBackdrop = GUI:Toggle("Show Backdrop", nil, 2, 0.5, DB, "ShowBackdrop", Update)
    Frame.args.BackgroundColour = GUI:Colour("Background Colour", 3, 0.5, DB, "BackgroundColour", Update)
    Frame.args.LayoutOptions = GUI:LayoutOptions(DB, Update, function() return Private:ClampDamageMeterSize(DB) end)
    GUI:DisableOptions(Frame, DB)
    Group.args.Frame = Frame

    local TitleBar = ACH:Group("Title Bar", nil, 3)
    TitleBar.args.Enable = GUI:Toggle("Enable", nil, 1, 1, DB.TitleBar, "Enable", Update)
    TitleBar.args.ShowBackdrop = GUI:Toggle("Show Backdrop", nil, 2, 0.5, DB.TitleBar, "ShowBackdrop", Update)
    TitleBar.args.Height = GUI:Range("Height", 3, 0.5, 10, 60, 1, DB.TitleBar, "Height", Update)
    local Icons = GUI:InlineGroup("Icons", 4)
    Icons.args.MouseoverIcons = GUI:Toggle("Mouseover Icons", nil, 1, 1, DB.TitleBar, "MouseoverIcons", Update)
    Icons.args.ResetButton = GUI:Toggle("Reset Button", nil, 2, 0.5, DB.TitleBar.Icons, "ResetButton", Update)
    Icons.args.EncountersButton = GUI:Toggle("Encounters Button", nil, 3, 0.5, DB.TitleBar.Icons, "EncountersButton", Update)
    TitleBar.args.Icons = Icons
    TitleBar.args.LayoutOptions = GUI:LayoutOptions({Layout = DB.TitleBar.Layout}, Update)
    local Text = GUI:InlineGroup("Text", 11)
    Text.args.FontOptions = GUI:FontOptions(DB.TitleBar.Text, Update)
    TitleBar.args.Text = Text
    GUI:DisableOptions(TitleBar, DB.TitleBar, DB)
    Group.args.TitleBar = TitleBar

    local Rows = ACH:Group("Rows", nil, 4)
    Rows.args.Num = GUI:Range("Number of Rows", 1, 0.33, 1, 40, 1, DB.Rows, "Num", Update)
    Rows.args.Spacing = GUI:Range("Spacing", 2, 0.33, 0, 10, 1, DB.Rows, "Spacing", Update)
    Rows.args.Texture = GUI:Media("Texture", 3, 0.33, "statusbar", DB.Rows, "Texture", Update)
    local Name = GUI:InlineGroup("Name", 4)
    Name.args.FontOptions = GUI:FontOptions(DB.Rows.Name, Update)
    Rows.args.Name = Name
    local Amount = GUI:InlineGroup("Amount", 5)
    Amount.args.Format = GUI:Select("Format", 1, 1, Private.MeterAmountFormats, DB.Rows.Amount, "Format", Update)
    Amount.args.FontOptions = GUI:FontOptions(DB.Rows.Amount, Update)
    Rows.args.Amount = Amount
    GUI:DisableOptions(Rows, DB)
    Group.args.Rows = Rows
    return Group
end
