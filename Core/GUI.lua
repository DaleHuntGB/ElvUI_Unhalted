local Private = select(2, ...)
local ACH = Private.ACH

--[[
    ACH:Color(name, desc, order, alpha, width, get, set, disabled, hidden)
    ACH:Description(name, order, fontSize, image, imageCoords, imageWidth, imageHeight, width, hidden)
    ACH:Execute(name, desc, order, func, image, confirm, width, get, set, disabled, hidden)
    ACH:FontFlags(name, desc, order, width, get, set, disabled, hidden)
    ACH:Group(name, desc, order, childGroups, get, set, disabled, hidden, func)
    ACH:Header(name, order, get, set, hidden)
    ACH:Input(name, desc, order, multiline, width, get, set, disabled, hidden, validate)
    ACH:MultiSelect(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
    ACH:Range(name, desc, order, values, width, get, set, disabled, hidden)
    ACH:Select(name, desc, order, values, confirm, width, get, set, disabled, hidden, sortByValue)
    ACH:SharedMediaBackground(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaBorder(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaFont(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaSound(name, desc, order, width, get, set, disabled, hidden)
    ACH:SharedMediaStatusbar(name, desc, order, width, get, set, disabled, hidden)
    ACH:Spacer(order, width, hidden)
    ACH:Toggle(name, desc, order, tristate, confirm, width, get, set, disabled, hidden)
]]

local AutoPurchaseInput = { Item = "", Quantity = 100 }

local function GetAutoPurchaseItemName(Item)
    if type(Item) ~= "number" then return Item end
    return string.format("|T%s:16:16|t %s", C_Item.GetItemIconByID(Item) or 134400, C_Item.GetItemNameByID(Item) or Item)
end

local function RefreshAutoPurchaseItems()
    local ItemsGroup = Private.GUI.args.Miscellaneous.args.AutoPurchase.args.Items
    local SortedItems = {}
    for Item in pairs(Private.DB.global.Miscellaneous.AutoPurchase.Items) do SortedItems[#SortedItems + 1] = Item end
    table.sort(SortedItems, function(A, B) return tostring(A) < tostring(B) end)

    wipe(ItemsGroup.args)
    if #SortedItems == 0 then
        ItemsGroup.args.Empty = ACH:Description("No Items Yet.", 1)
        return
    end

    for Index, Item in ipairs(SortedItems) do
        local Key = tostring(Item)
        ItemsGroup.args[Key .. "Item"] = ACH:Description(function() return GetAutoPurchaseItemName(Item) end, Index * 3 - 2, "medium", nil, nil, nil, nil, "relative")
        ItemsGroup.args[Key .. "Item"].relWidth = 0.5
        ItemsGroup.args[Key .. "Quantity"] = ACH:Range("Quantity", nil, Index * 3 - 1, {min = 1, max = 10000, softMin = 1, softMax = 2000, step = 1, bigStep = 10}, "relative", function() return Private.DB.global.Miscellaneous.AutoPurchase.Items[Item] end, function(_, value) Private.DB.global.Miscellaneous.AutoPurchase.Items[Item] = value end, function() return not Private.DB.global.Miscellaneous.AutoPurchase.Enable end)
        ItemsGroup.args[Key .. "Quantity"].relWidth = 0.4
        ItemsGroup.args[Key .. "Remove"] = ACH:Execute("X", nil, Index * 3, function() Private.DB.global.Miscellaneous.AutoPurchase.Items[Item] = nil RefreshAutoPurchaseItems() Private.E:RefreshGUI() end, nil, nil, "relative", nil, nil, function() return not Private.DB.global.Miscellaneous.AutoPurchase.Enable end)
        ItemsGroup.args[Key .. "Remove"].relWidth = 0.1
    end
end

local function AddAutoPurchaseItem()
    local Input = strtrim(AutoPurchaseInput.Item)
    local Item = C_Item.GetItemInfoInstant(tonumber(Input) or Input) or strlower(Input)
    Private.DB.global.Miscellaneous.AutoPurchase.Items[Item] = AutoPurchaseInput.Quantity
    AutoPurchaseInput.Item = ""
    RefreshAutoPurchaseItems()
    Private.E:RefreshGUI()
end

function Private:SetupGUI()
    Private.GUI = ACH:Group("|cFF6080FFUnhalted|r|cFF808080UI|r", nil, 999, "tree")

    Private.GUI.args.AddOnSkins = ACH:Group("AddOn Skins", nil, 1, "tab")
    Private.GUI.args.AddOnSkins.args.BugSack = ACH:Group("BugSack", nil, 1, "tab", nil, nil, nil, function() return not C_AddOns.IsAddOnLoaded("BugSack") end)

    Private.GUI.args.AddOnSkins.args.BugSack.args.Enable = ACH:Toggle("Enable", "Skins the minimap icon to much the UI, and provides layout options.", 1, nil, nil, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Enable end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Enable = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.Enable.descStyle = "inline"
    Private.GUI.args.AddOnSkins.args.BugSack.args.Enable.relWidth = 1

    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.inline = true

    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[1] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[1] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[2] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[2] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[3] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[3] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Layout[4] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Layout[4] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.AddOnSkins.BugSack.Size[1] end, function(_, value) Private.DB.global.AddOnSkins.BugSack.Size[1] = value Private.DB.global.AddOnSkins.BugSack.Size[2] = value Private:UpdateBugSackSkin() end, function() return not Private.DB.global.AddOnSkins.BugSack.Enable end)
    Private.GUI.args.AddOnSkins.args.BugSack.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts = ACH:Group("Alerts", nil, 2, "tab")

    Private.GUI.args.Alerts.args.Combat = ACH:Group("Combat", nil, 1, "tab")

    Private.GUI.args.Alerts.args.Combat.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.Combat.Enable end, function(_, value) Private.DB.global.Alerts.Combat.Enable = value Private:UpdateCombatAlert() end)
    Private.GUI.args.Alerts.args.Combat.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.Combat.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.Combat.Layout[1] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[1] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.Combat.Layout[2] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[2] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.Combat.Layout[3] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[3] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.Combat.Layout[4] end, function(_, value) Private.DB.global.Alerts.Combat.Layout[4] = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.HoldTime = ACH:Range("Hold Time", "The time that the text will remain on the screen before disappearing.", 5, {min = 0, max = 10, softMin = 0, softMax = 5, step = 0.5}, "relative", function() return Private.DB.global.Alerts.Combat.HoldTime end, function(_, value) Private.DB.global.Alerts.Combat.HoldTime = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.LayoutGroup.args.HoldTime.relWidth = 0.33

    Private.GUI.args.Alerts.args.Combat.args.FontGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.inline = true

    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Alerts.Combat.Text.FontSize end, function(_, value) Private.DB.global.Alerts.Combat.Text.FontSize = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.FontSize.relWidth = 1

    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatText = ACH:Input("Entering Combat: Text", nil, 6, nil, "relative", function() return Private.DB.global.Alerts.Combat.Text.Enter.Text end, function(_, value) Private.DB.global.Alerts.Combat.Text.Enter.Text = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatText.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatColour = ACH:Color("Entering Combat: Colour", nil, 7, false, "relative", function() return unpack(Private.DB.global.Alerts.Combat.Text.Enter.Colour) end, function(_, r, g, b) Private.DB.global.Alerts.Combat.Text.Enter.Colour = {r, g, b} Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.EnterCombatColour.relWidth = 0.5

    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatText = ACH:Input("Exiting Combat: Text", nil, 8, nil, "relative", function() return Private.DB.global.Alerts.Combat.Text.Exit.Text end, function(_, value) Private.DB.global.Alerts.Combat.Text.Exit.Text = value Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatText.relWidth = 0.5
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatColour = ACH:Color("Exiting Combat: Colour", nil, 9, false, "relative", function() return unpack(Private.DB.global.Alerts.Combat.Text.Exit.Colour) end, function(_, r, g, b) Private.DB.global.Alerts.Combat.Text.Exit.Colour = {r, g, b} Private:UpdateCombatAlert() end, function() return not Private.DB.global.Alerts.Combat.Enable end)
    Private.GUI.args.Alerts.args.Combat.args.FontGroup.args.ExitCombatColour.relWidth = 0.5

    Private.GUI.args.Alerts.args.Innervate = ACH:Group("|T136048:18:18|t Innervate", nil, 2, "tab", nil, nil, nil, function() return Private.isForever end)

    Private.GUI.args.Alerts.args.Innervate.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.Innervate.Enable end, function(_, value) Private.DB.global.Alerts.Innervate.Enable = value Private:UpdateInnervateAlert() end)
    Private.GUI.args.Alerts.args.Innervate.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.Innervate.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.Innervate.Layout[1] end, function(_, value) Private.DB.global.Alerts.Innervate.Layout[1] = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.Innervate.Layout[2] end, function(_, value) Private.DB.global.Alerts.Innervate.Layout[2] = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.Innervate.Layout[3] end, function(_, value) Private.DB.global.Alerts.Innervate.Layout[3] = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.Innervate.Layout[4] end, function(_, value) Private.DB.global.Alerts.Innervate.Layout[4] = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 0, max = 64, softMin = 8, softMax = 48, step = 1}, "relative", function() return Private.DB.global.Alerts.Innervate.Size[1] end, function(_, value) Private.DB.global.Alerts.Innervate.Size[1] = value Private.DB.global.Alerts.Innervate.Size[2] = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts.args.Innervate.args.SoundGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.Innervate.args.SoundGroup.inline = true

    Private.GUI.args.Alerts.args.Innervate.args.SoundGroup.args.Sound = ACH:SharedMediaSound("Sound", nil, 1, "relative", function() return Private.DB.global.Alerts.Innervate.Sound end, function(_, value) Private.DB.global.Alerts.Innervate.Sound = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.SoundGroup.args.Sound.relWidth = 0.5
    Private.GUI.args.Alerts.args.Innervate.args.SoundGroup.args.SoundChannel = ACH:Select("Sound Channel", nil, 2, {["Master"] = "Master", ["SFX"] = "SFX", ["Music"] = "Music", ["Ambience"] = "Ambience"}, nil, "relative", function() return Private.DB.global.Alerts.Innervate.SoundChannel end, function(_, value) Private.DB.global.Alerts.Innervate.SoundChannel = value Private:UpdateInnervateAlert() end, function() return not Private.DB.global.Alerts.Innervate.Enable end)
    Private.GUI.args.Alerts.args.Innervate.args.SoundGroup.args.SoundChannel.relWidth = 0.5

    Private.GUI.args.Alerts.args.PowerInfusion = ACH:Group("|T135939:18:18|t Power Infusion", nil, 3, "tab", nil, nil, nil, function() return Private.isForever end)

    Private.GUI.args.Alerts.args.PowerInfusion.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Enable end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Enable = value Private:UpdatePowerInfusionAlert() end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.PowerInfusion.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[1] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[1] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[2] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[2] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[3] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[3] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Layout[4] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Layout[4] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 0, max = 64, softMin = 8, softMax = 48, step = 1}, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Size[1] end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Size[1] = value Private.DB.global.Alerts.PowerInfusion.Size[2] = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.inline = true

    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.Sound = ACH:SharedMediaSound("Sound", nil, 1, "relative", function() return Private.DB.global.Alerts.PowerInfusion.Sound end, function(_, value) Private.DB.global.Alerts.PowerInfusion.Sound = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.Sound.relWidth = 0.5
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.SoundChannel = ACH:Select("Sound Channel", nil, 2, {["Master"] = "Master", ["SFX"] = "SFX", ["Music"] = "Music", ["Ambience"] = "Ambience"}, nil, "relative", function() return Private.DB.global.Alerts.PowerInfusion.SoundChannel end, function(_, value) Private.DB.global.Alerts.PowerInfusion.SoundChannel = value Private:UpdatePowerInfusionAlert() end, function() return not Private.DB.global.Alerts.PowerInfusion.Enable end)
    Private.GUI.args.Alerts.args.PowerInfusion.args.SoundGroup.args.SoundChannel.relWidth = 0.5

    Private.GUI.args.Alerts.args.TimeSpiral = ACH:Group("|T4622479:18:18|t Time Spiral", nil, 4, "tab", nil, nil, nil, function() return Private.isForever end)

    Private.GUI.args.Alerts.args.TimeSpiral.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Enable end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Enable = value Private:UpdateTimeSpiralAlert() end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.Enable.descStyle = "inline"
    Private.GUI.args.Alerts.args.TimeSpiral.args.Enable.relWidth = 1

    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup = ACH:Group("Layout", nil, 2, "tab")
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.inline = true

    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[1] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[1] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[2] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[2] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[3] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[3] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Layout[4] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Layout[4] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.Size = ACH:Range("Size", nil, 5, {min = 0, max = 64, softMin = 8, softMax = 48, step = 1}, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Size[1] end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Size[1] = value Private.DB.global.Alerts.TimeSpiral.Size[2] = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.LayoutGroup.args.Size.relWidth = 0.33

    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup = ACH:Group("Fonts", nil, 3, "tab")
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.inline = true

    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.Sound = ACH:SharedMediaSound("Sound", nil, 1, "relative", function() return Private.DB.global.Alerts.TimeSpiral.Sound end, function(_, value) Private.DB.global.Alerts.TimeSpiral.Sound = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.Sound.relWidth = 0.5
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.SoundChannel = ACH:Select("Sound Channel", nil, 2, {["Master"] = "Master", ["SFX"] = "SFX", ["Music"] = "Music", ["Ambience"] = "Ambience"}, nil, "relative", function() return Private.DB.global.Alerts.TimeSpiral.SoundChannel end, function(_, value) Private.DB.global.Alerts.TimeSpiral.SoundChannel = value Private:UpdateTimeSpiralAlert() end, function() return not Private.DB.global.Alerts.TimeSpiral.Enable end)
    Private.GUI.args.Alerts.args.TimeSpiral.args.SoundGroup.args.SoundChannel.relWidth = 0.5

    Private.GUI.args.Blizzard = ACH:Group("Blizzard", nil, 3, "tab")
    Private.GUI.args.Blizzard.args.Miscellaneous = ACH:Group("Miscellaneous", nil, 0)
    Private.GUI.args.Blizzard.args.Miscellaneous.inline = true
    Private.GUI.args.Blizzard.args.Miscellaneous.args.CleanObjectiveTrackerBanner = ACH:Toggle("Clean-up Point of Interest Banner", "This will position & tidy up the banner that appears when entering a |cFFFFCC00point of interest|r.", 0, nil, nil, "relative", function() return Private.DB.global.Blizzard.CleanObjectiveTrackerBanner end, function(_, value) Private.DB.global.Blizzard.CleanObjectiveTrackerBanner = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.Blizzard.args.Miscellaneous.args.CleanObjectiveTrackerBanner.descStyle = "inline"
    Private.GUI.args.Blizzard.args.Miscellaneous.args.CleanObjectiveTrackerBanner.relWidth = 1
    Private.GUI.args.Blizzard.args.Miscellaneous.args.WorldMapZoneLevels = ACH:Toggle("World Map Zone Levels", "Shows each zone's |cFFFFCC00level range|r below its name on the world map.", 1, nil, nil, "relative", function() return Private.DB.global.Blizzard.WorldMapZoneLevels end, function(_, value) Private.DB.global.Blizzard.WorldMapZoneLevels = value Private.E:StaticPopup_Show("CONFIG_RL") end, nil, function() return not Private.isForever end)
    Private.GUI.args.Blizzard.args.Miscellaneous.args.WorldMapZoneLevels.descStyle = "inline"
    Private.GUI.args.Blizzard.args.Miscellaneous.args.WorldMapZoneLevels.relWidth = 1

    Private.GUI.args.Blizzard.args.UIErrorsFrame = ACH:Group("UIErrorsFrame", nil, 1)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Enable end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Enable = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Enable.relWidth = 0.5

    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Hide = ACH:Toggle("Hide (|cFFCC4040Not Recommended|r)", nil, 2, nil, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Hide end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Hide = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.Hide.relWidth = 0.5

    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup = ACH:Group("Layout", nil, 2)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.inline = true
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[1] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[1] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[2] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[2] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[3] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[3] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.XOffset.relWidth = 0.5
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Blizzard.UIErrorsFrame.Layout[4] end, function(_, value) Private.DB.global.Blizzard.UIErrorsFrame.Layout[4] = value Private:UpdateUIErrorsFrame() end, function() return not Private.DB.global.Blizzard.UIErrorsFrame.Enable end)
    Private.GUI.args.Blizzard.args.UIErrorsFrame.args.LayoutGroup.args.YOffset.relWidth = 0.5

    local HunterColour = RAID_CLASS_COLORS.HUNTER
    Private.GUI.args.Classes = ACH:Group("Classes", nil, 4, "tab", nil, nil, nil, function()
        for _, ClassGroup in pairs(Private.GUI.args.Classes.args) do
            if not (ClassGroup.hidden and ClassGroup.hidden()) then return false end
        end
        return true
    end)

    Private.GUI.args.Classes.args.Hunter = ACH:Group("|TInterface\\Icons\\ClassIcon_Hunter:16:16:0:0:64:64:5:59:5:59|t " .. HunterColour:WrapTextInColorCode("Hunter"), nil, 1, nil, nil, nil, nil, function() return not Private.isForever or Private.E.myclass ~= "HUNTER" end)

    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter = ACH:Group("Ammo Counter", nil, 1)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.inline = true
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Enable end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Enable = value Private:UpdateAmmoCounter() end, nil)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Enable.relWidth = 1

    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout = ACH:Group("Layout", nil, 2)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.inline = true
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Layout[1] end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Layout[1] = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.AnchorFrom.relWidth = 0.33
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.AnchorParent = ACH:Input("Anchor Parent", nil, 2, nil, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.AnchorParent end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.AnchorParent = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.AnchorParent.relWidth = 0.33
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 3, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Layout[2] end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Layout[2] = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.AnchorTo.relWidth = 0.33
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 4, { min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1 }, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Layout[3] end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Layout[3] = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 5, { min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1 }, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Layout[4] end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Layout[4] = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font = ACH:Group("Font", nil, 3)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.inline = true
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.Colour = ACH:Color("Colour", nil, 1, false, "relative", function() return unpack(Private.DB.global.Miscellaneous.AmmoCounter.Text.Colour) end, function(_, r, g, b) Private.DB.global.Miscellaneous.AmmoCounter.Text.Colour = {r, g, b} Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.Colour.relWidth = 0.5
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.FontSize = ACH:Range("Font Size", nil, 2, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Text.FontSize end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Text.FontSize = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.FontSize.relWidth = 0.5
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.BelowThresholdColour = ACH:Color("Below Threshold Colour", nil, 3, false, "relative", function() return unpack(Private.DB.global.Miscellaneous.AmmoCounter.Text.BelowThresholdColour) end, function(_, r, g, b) Private.DB.global.Miscellaneous.AmmoCounter.Text.BelowThresholdColour = {r, g, b} Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.BelowThresholdColour.relWidth = 0.5
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.Threshold = ACH:Range("Threshold", "The ammo count below which the |cFFFFCC00Below Threshold Colour|r is used.", 4, {min = 0, max = 5000, softMin = 0, softMax = 1000, step = 1, bigStep = 10}, "relative", function() return Private.DB.global.Miscellaneous.AmmoCounter.Text.Threshold end, function(_, value) Private.DB.global.Miscellaneous.AmmoCounter.Text.Threshold = value Private:UpdateAmmoCounter() end, function() return not Private.DB.global.Miscellaneous.AmmoCounter.Enable end)
    Private.GUI.args.Classes.args.Hunter.args.AmmoCounter.args.Font.args.Threshold.relWidth = 0.5

    Private.GUI.args.Classes.args.Hunter.args.Toggles = ACH:Group("Toggles", nil, 2)
    Private.GUI.args.Classes.args.Hunter.args.Toggles.inline = true
    Private.GUI.args.Classes.args.Hunter.args.Toggles.args.HighlightOptimalRanks = ACH:Toggle("Highlight Optimal Ranks", "Makes the most mana-efficient rank of each ranked Hunter spell glow in the spellbook.", 1, nil, nil, "full", function() return Private.DB.global.Miscellaneous.Hunter.HighlightOptimalRanks end, function(_, value) Private.DB.global.Miscellaneous.Hunter.HighlightOptimalRanks = value Private:UpdateOptimalRanks() end)
    Private.GUI.args.Classes.args.Hunter.args.Toggles.args.HighlightOptimalRanks.descStyle = "inline"
    Private.GUI.args.Classes.args.Hunter.args.Toggles.args.UseBestFood = ACH:Toggle("Use Best Food when Using |T132165:16:16|t|cFFFFCC00Feed Pet|r", "Feeds your pet the best food in your bags when you press a macro with |cFFFFCC00/click FeedPet|r.", 2, nil, nil, "full", function() return Private.DB.global.Miscellaneous.Hunter.UseBestFood end, function(_, value) Private.DB.global.Miscellaneous.Hunter.UseBestFood = value end)
    Private.GUI.args.Classes.args.Hunter.args.Toggles.args.UseBestFood.descStyle = "inline"

    Private.GUI.args.DamageMeter = ACH:Group("Damage Meter", nil, 5, "tab")

    for i in pairs(Private.DB.global.DamageMeter) do
        Private.GUI.args.DamageMeter.args["Window" .. i] = ACH:Group("Window "..i, nil, i, "tab")
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].Enable end, function(_, value) Private.DB.global.DamageMeter[i].Enable = value Private:UpdateDamageMeters() end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Enable.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.ShowBackdrop = ACH:Toggle("Show Backdrop", nil, 1, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].ShowBackdrop end, function(_, value) Private.DB.global.DamageMeter[i].ShowBackdrop = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.ShowBackdrop.relWidth = 0.5

        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup = ACH:Group("Layout & Positioning", nil, 2, "tab")
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.DamageMeter[i].Layout[1] end, function(_, value) Private.DB.global.DamageMeter[i].Layout[1] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.DamageMeter[i].Layout[2] end, function(_, value) Private.DB.global.DamageMeter[i].Layout[2] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.AnchorTo.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Layout[3] end, function(_, value) Private.DB.global.DamageMeter[i].Layout[3] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.XOffset.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Layout[4] end, function(_, value) Private.DB.global.DamageMeter[i].Layout[4] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.YOffset.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.Width = ACH:Range("Width", nil, 5, {min = 128, max = 1024, softMin = 128, softMax = 512, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Size[1] end, function(_, value) Private.DB.global.DamageMeter[i].Size[1] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.Width.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.Height = ACH:Range("Height", nil, 6, {min = 32, max = 1024, softMin = 32, softMax = 512, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Size[2] end, function(_, value) Private.DB.global.DamageMeter[i].Size[2] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.LayoutGroup.args.Height.relWidth = 0.5

        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows = ACH:Group("Rows & Texts", nil, 2, "tab")
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.Texture = ACH:SharedMediaStatusbar("Texture", nil, 1, "relative", function() return Private.DB.global.DamageMeter[i].Texture end, function(_, value) Private.DB.global.DamageMeter[i].Texture = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.Texture.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.NumOfRows = ACH:Range("Rows", nil, 2, {min = 1, max = 12, softMin = 1, softMax = 8, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Rows end, function(_, value) Private.DB.global.DamageMeter[i].Rows = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.NumOfRows.relWidth = 0.5

        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup = ACH:Group("Text", nil, 3)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.inline = true

        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup = ACH:Group("Name", nil, 1, "tab")
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.ColourByClass = ACH:Toggle("Colour By Class", nil, 1, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].Text.Name_ColourByClass end, function(_, value) Private.DB.global.DamageMeter[i].Text.Name_ColourByClass = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.ColourByClass.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.Colour = ACH:Color("Colour", nil, 2, false, "relative", function() return unpack(Private.DB.global.DamageMeter[i].Text.Name_Colour) end, function(_, r, g, b) Private.DB.global.DamageMeter[i].Text.Name_Colour = {r, g, b} Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or Private.DB.global.DamageMeter[i].Text.Name_ColourByClass end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.Colour.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -Private.DB.global.DamageMeter[i].Size[1], max = Private.DB.global.DamageMeter[i].Size[1], softMin = 0, softMax = Private.DB.global.DamageMeter[i].Size[1], step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Text.Name_XOffset end, function(_, value) Private.DB.global.DamageMeter[i].Text.Name_XOffset = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.XOffset.relWidth = 0.33
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -Private.DB.global.DamageMeter[i].Size[2], max = Private.DB.global.DamageMeter[i].Size[2], softMin = 0, softMax = Private.DB.global.DamageMeter[i].Size[2], step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Text.Name_YOffset end, function(_, value) Private.DB.global.DamageMeter[i].Text.Name_YOffset = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.YOffset.relWidth = 0.33
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 32, softMin = 8, softMax = 24, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Text.Name_FontSize end, function(_, value) Private.DB.global.DamageMeter[i].Text.Name_FontSize = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.NameGroup.args.FontSize.relWidth = 0.33

        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup = ACH:Group("Amount", nil, 2, "tab")
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.ColourByClass = ACH:Toggle("Colour By Class", nil, 1, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].Text.Amount_ColourByClass end, function(_, value) Private.DB.global.DamageMeter[i].Text.Amount_ColourByClass = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.ColourByClass.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.Colour = ACH:Color("Colour", nil, 2, false, "relative", function() return unpack(Private.DB.global.DamageMeter[i].Text.Amount_Colour) end, function(_, r, g, b) Private.DB.global.DamageMeter[i].Text.Amount_Colour = {r, g, b} Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or Private.DB.global.DamageMeter[i].Text.Amount_ColourByClass end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.Colour.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -Private.DB.global.DamageMeter[i].Size[1], max = Private.DB.global.DamageMeter[i].Size[1], softMin = 0, softMax = Private.DB.global.DamageMeter[i].Size[1], step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Text.Amount_XOffset end, function(_, value) Private.DB.global.DamageMeter[i].Text.Amount_XOffset = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.XOffset.relWidth = 0.25
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -Private.DB.global.DamageMeter[i].Size[2], max = Private.DB.global.DamageMeter[i].Size[2], softMin = 0, softMax = Private.DB.global.DamageMeter[i].Size[2], step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Text.Amount_YOffset end, function(_, value) Private.DB.global.DamageMeter[i].Text.Amount_YOffset = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.YOffset.relWidth = 0.25
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 32, softMin = 8, softMax = 24, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].Text.Amount_FontSize end, function(_, value) Private.DB.global.DamageMeter[i].Text.Amount_FontSize = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.FontSize.relWidth = 0.25
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.Format = ACH:Select("Format", nil, 6, Private.MeterAmountFormats, nil, "relative", function() return Private.DB.global.DamageMeter[i].Text.Amount_Format end, function(_, value) Private.DB.global.DamageMeter[i].Text.Amount_Format = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.Rows.args.TextGroup.args.AmountGroup.args.Format.relWidth = 0.25

        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar = ACH:Group("Title Bar", nil, 3, "tab")
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Enable end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Enable = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.Enable.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.ShowBackdrop = ACH:Toggle("Show Backdrop", nil, 2, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.ShowBackdrop end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.ShowBackdrop = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.ShowBackdrop.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.Height = ACH:Range("Height", nil, 3, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Height end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Height = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.Height.relWidth = 0.33
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.XOffset = ACH:Range("X Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.XOffset end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.XOffset = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.XOffset.relWidth = 0.33
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.YOffset = ACH:Range("Y Offset", nil, 5, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.YOffset end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.YOffset = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.YOffset.relWidth = 0.33

        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup = ACH:Group("Text", nil, 6)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.inline = true
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Text.Enable = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.Enable.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.Colour = ACH:Color("Colour", nil, 2, false, "relative", function() return unpack(Private.DB.global.DamageMeter[i].TitleBar.Text.Colour) end, function(_, r, g, b) Private.DB.global.DamageMeter[i].TitleBar.Text.Colour = {r, g, b} Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable or not Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.Colour.relWidth = 0.5

        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup = ACH:Group("Layout", nil, 3)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.inline = true
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[1] end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[1] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable or not Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[2] end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[2] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable or not Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[3] end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[3] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable or not Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.XOffset.relWidth = 0.33
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[4] end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Text.Layout[4] = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable or not Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.YOffset.relWidth = 0.33
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 32, softMin = 8, softMax = 24, step = 1}, "relative", function() return Private.DB.global.DamageMeter[i].TitleBar.Text.FontSize end, function(_, value) Private.DB.global.DamageMeter[i].TitleBar.Text.FontSize = value Private:UpdateWindow(_G["DamageMeter_0"..i], Private.DB.global.DamageMeter[i]) end, function() return not Private.DB.global.DamageMeter[i].Enable or not Private.DB.global.DamageMeter[i].TitleBar.Enable or not Private.DB.global.DamageMeter[i].TitleBar.Text.Enable end)
        Private.GUI.args.DamageMeter.args["Window" .. i].args.TitleBar.args.TextGroup.args.LayoutGroup.args.FontSize.relWidth = 0.33
    end

    Private.GUI.args.ElvUI = ACH:Group("ElvUI", nil, 6, "tab")
    Private.GUI.args.ElvUI.args.EnhancedAnchors = ACH:Group("Enhanced Anchors", nil, 1)
    Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars = ACH:Group("Action Bars", nil, 1, "tab")

    for i = 1, 6 do
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i] = ACH:Group("Bar "..i, nil, i, "tab")
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "full", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable = value Private:UpdateMover(value, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end)

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup = ACH:Group("Layout", nil, 2)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.inline = true
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[1] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[1] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorFrom.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorParent = ACH:Input("Anchor Parent", nil, 3, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[2] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[2] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorParent.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 4, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[3] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[3] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.AnchorTo.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 5, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[4] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[4] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.XOffset.relWidth = 0.5
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 6, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[5] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout[5] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable, "ElvAB_"..i, table.concat(Private.DB.global.ElvUI.Movers["ElvAB_"..i].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.LayoutGroup.args.YOffset.relWidth = 0.5

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.ActionBars.args["ElvAB_"..i].args.SetAsSkyridingVehicleBar = ACH:Execute("Set As Skyriding / Vehicle Bar", "This will set |cFFFFCC00paging|r & |cFFFFCC00visibility|r for this action bar.", 3, function() Private:SetVisibilityConditions("bar" .. i) end, nil, nil, "full", nil, nil, function() return not Private.DB.global.ElvUI.Movers["ElvAB_"..i].Enable end)
    end

    Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames = ACH:Group("Unit Frames", nil, 2, "tab")

    local UnitFrames = {
        [1] = "Player",
        [2] = "Target",
        [3] = "TargetCastbar",
        [4] = "Pet",
        [5] = "Focus"
    }

    local PrettifyUnitFrames = {
        ["Player"] = "Player",
        ["Target"] = "Target",
        ["TargetCastbar"] = "Target Cast Bar",
        ["Pet"] = "Pet",
        ["Focus"] = "Focus"
    }

    for i, unitFrame in ipairs(UnitFrames) do
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"] = ACH:Group(PrettifyUnitFrames[unitFrame], nil, i, "tab")
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "full", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable = value Private:UpdateMover(value, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end)

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup = ACH:Group("Layout", nil, 2)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.inline = true

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[1] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[1] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorFrom.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorParent = ACH:Input("Anchor Parent", nil, 3, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[2] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[2] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorParent.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 4, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[3] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[3] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.AnchorTo.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 5, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[4] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[4] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.XOffset.relWidth = 0.5
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 6, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[5] end, function(_, value) Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout[5] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable, "ElvUF_"..unitFrame.."Mover", table.concat(Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers["ElvUF_"..unitFrame.."Mover"].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.UnitFrames.args["ElvUF_"..unitFrame.."Mover"].args.LayoutGroup.args.YOffset.relWidth = 0.5
    end

    Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous = ACH:Group("Miscellaneous", nil, 3, "tab")

    local MiscellaneousMovers = {
        [1] = "TotemTrackerMover",
    }

    local PrettifyMiscellaneousMovers = {
        ["TotemTrackerMover"] = "Totem Tracker",
    }

    for i, moverName in ipairs(MiscellaneousMovers) do
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName] = ACH:Group(PrettifyMiscellaneousMovers[moverName], nil, i, "tab")
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "full", function() return Private.DB.global.ElvUI.Movers[moverName].Enable end, function(_, value) Private.DB.global.ElvUI.Movers[moverName].Enable = value Private:UpdateMover(value, moverName, table.concat(Private.DB.global.ElvUI.Movers[moverName].Layout, ",")) end)

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup = ACH:Group("Layout", nil, 2)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.inline = true

        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers[moverName].Layout[1] end, function(_, value) Private.DB.global.ElvUI.Movers[moverName].Layout[1] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers[moverName].Enable, moverName, table.concat(Private.DB.global.ElvUI.Movers[moverName].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers[moverName].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.AnchorFrom.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.AnchorParent = ACH:Input("Anchor Parent", nil, 3, nil, "relative", function() return Private.DB.global.ElvUI.Movers[moverName].Layout[2] end, function(_, value) Private.DB.global.ElvUI.Movers[moverName].Layout[2] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers[moverName].Enable, moverName, table.concat(Private.DB.global.ElvUI.Movers[moverName].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers[moverName].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.AnchorParent.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 4, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.ElvUI.Movers[moverName].Layout[3] end, function(_, value) Private.DB.global.ElvUI.Movers[moverName].Layout[3] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers[moverName].Enable, moverName, table.concat(Private.DB.global.ElvUI.Movers[moverName].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers[moverName].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.AnchorTo.relWidth = 0.33
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 5, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers[moverName].Layout[4] end, function(_, value) Private.DB.global.ElvUI.Movers[moverName].Layout[4] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers[moverName].Enable, moverName, table.concat(Private.DB.global.ElvUI.Movers[moverName].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers[moverName].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.XOffset.relWidth = 0.5
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 6, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 0.1}, "relative", function() return Private.DB.global.ElvUI.Movers[moverName].Layout[5] end, function(_, value) Private.DB.global.ElvUI.Movers[moverName].Layout[5] = value Private:UpdateMover(Private.DB.global.ElvUI.Movers[moverName].Enable, moverName, table.concat(Private.DB.global.ElvUI.Movers[moverName].Layout, ",")) end, function() return not Private.DB.global.ElvUI.Movers[moverName].Enable end)
        Private.GUI.args.ElvUI.args.EnhancedAnchors.args.Miscellaneous.args[moverName].args.LayoutGroup.args.YOffset.relWidth = 0.5
    end

    Private.GUI.args.ElvUI.args.Miscellaneous = ACH:Group("Miscellaneous", nil, 2)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.InterruptOnCooldown = ACH:Toggle("Interrupt on Cooldown", "Colours the castbar |cFF808080grey|r when your |cFFFFCC00interrupt|r is on cooldown.", 1, nil, nil, "full", function() return Private.DB.global.ElvUI.InterruptOnCooldown end, function(_, value) Private.DB.global.ElvUI.InterruptOnCooldown = value Private.E:StaticPopup_Show("CONFIG_RL") end, nil, function() return Private.isForever end)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.InterruptOnCooldown.descStyle = "inline"
    Private.GUI.args.ElvUI.args.Miscellaneous.args.LootRollFix = ACH:Toggle( "Fix Loot Roll Alpha", "Correctly applies the alpha to the |cFFFFCC00loot roll|r windows.", 1, nil, nil, "full", function() return Private.DB.global.ElvUI.LootRollFix end, function(_, value) Private.DB.global.ElvUI.LootRollFix = value Private.E:StaticPopup_Show("CONFIG_RL") end )
    Private.GUI.args.ElvUI.args.Miscellaneous.args.LootRollFix.descStyle = "inline"
    Private.GUI.args.ElvUI.args.Miscellaneous.args.RemoveFogOfWar = ACH:Toggle("Remove Fog of War", "Reveals |cFFFFCC00unexplored areas|r on the world map, desaturated.", 1, nil, nil, "full", function() return Private.DB.global.ElvUI.RemoveFogOfWar end, function(_, value) Private.DB.global.ElvUI.RemoveFogOfWar = value Private.E:StaticPopup_Show("CONFIG_RL") end)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.RemoveFogOfWar.descStyle = "inline"

    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture = ACH:Group("Focus Texture", nil, 2, nil, nil, nil, nil, function() return not Private.E.private.nameplates.enable end)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.inline = true
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.args.Enable = ACH:Toggle("Enable", "Overlays a texture on your |cFFFFCC00focus|r nameplate's health bar.", 1, nil, nil, "relative", function() return Private.DB.global.ElvUI.FocusTexture.Enable end, function(_, value) Private.DB.global.ElvUI.FocusTexture.Enable = value Private:UpdateFocusTexture() end)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.args.Enable.relWidth = 0.33
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.args.Texture = ACH:SharedMediaStatusbar("Texture", nil, 2, "relative", function() return Private.DB.global.ElvUI.FocusTexture.Texture end, function(_, value) Private.DB.global.ElvUI.FocusTexture.Texture = value Private:UpdateFocusTexture() end, function() return not Private.DB.global.ElvUI.FocusTexture.Enable end)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.args.Texture.relWidth = 0.33
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.args.Colour = ACH:Color("Colour", nil, 3, true, "relative", function() return unpack(Private.DB.global.ElvUI.FocusTexture.Colour) end, function(_, r, g, b, a) Private.DB.global.ElvUI.FocusTexture.Colour = {r, g, b, a} Private:UpdateFocusTexture() end, function() return not Private.DB.global.ElvUI.FocusTexture.Enable end)
    Private.GUI.args.ElvUI.args.Miscellaneous.args.FocusTexture.args.Colour.relWidth = 0.33

    Private.GUI.args.MinimapStats = ACH:Group("Minimap Stats", nil, 7, "tab")
    Private.GUI.args.MinimapStats.args.Time = ACH:Group("Time", nil, 1)

    Private.GUI.args.MinimapStats.args.Time.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Enable end, function(_, value) Private.DB.global.MinimapStats.Time.Enable = value Private:UpdateTime() end)
    Private.GUI.args.MinimapStats.args.Time.args.Enable.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Time.args.Format = ACH:Select("Format", nil, 2, {["24H"] = "24H", ["12H"] = "12H"}, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Format end, function(_, value) Private.DB.global.MinimapStats.Time.Format = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Format.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Time.args.UpdateInterval = ACH:Range("Update Interval", nil, 3, {min = 1, max = 60, softMin = 1, softMax = 30, step = 1}, "relative", function() return Private.DB.global.MinimapStats.Time.UpdateInterval end, function(_, value) Private.DB.global.MinimapStats.Time.UpdateInterval = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.UpdateInterval.relWidth = 0.33

    Private.GUI.args.MinimapStats.args.Time.args.Layout = ACH:Group("Layout", nil, 4)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[1] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[2] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[3] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.Time.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.Time.Layout[4] = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.Time.args.Font = ACH:Group("Font", nil, 5)
    Private.GUI.args.MinimapStats.args.Time.args.Font.inline = true
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.Colour = ACH:Color("Font Colour", nil, 1, false, "relative", function() return unpack(Private.DB.global.MinimapStats.Time.Colour) end, function(_, r, g, b) Private.DB.global.MinimapStats.Time.Colour = {r, g, b} Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.Colour.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.FontSize = ACH:Range("Font Size", nil, 2, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.Time.FontSize end, function(_, value) Private.DB.global.MinimapStats.Time.FontSize = value Private:UpdateTime() end, function() return not Private.DB.global.MinimapStats.Time.Enable end)
    Private.GUI.args.MinimapStats.args.Time.args.Font.args.FontSize.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.SystemStats = ACH:Group("SystemStats", nil, 2)

    Private.GUI.args.MinimapStats.args.SystemStats.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Enable end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Enable = value Private:UpdateSystemStats() end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Enable.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Format = ACH:Select("Format", nil, 2, { ["FPS_MS"] = "FPS & MS", ["MS"] = "MS", ["FPS"] = "FPS" }, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Format end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Format = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Format.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Seperator = ACH:Select("Seperator", nil, 2, {["•"] = "•", ["||"] = "|", ["-"] = "-"}, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Seperator end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Seperator = value Private:UpdateSystemStats() end, function() return (not Private.DB.global.MinimapStats.SystemStats.Enable) or not (Private.DB.global.MinimapStats.SystemStats.Format == "FPS_MS") end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Seperator.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.UpdateInterval = ACH:Range("Update Interval", nil, 3, {min = 1, max = 60, softMin = 1, softMax = 30, step = 1}, "relative", function() return Private.DB.global.MinimapStats.SystemStats.UpdateInterval end, function(_, value) Private.DB.global.MinimapStats.SystemStats.UpdateInterval = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.UpdateInterval.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout = ACH:Group("Layout", nil, 4)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[1] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[2] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[3] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.SystemStats.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.SystemStats.Layout[4] = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.SystemStats.args.Font = ACH:Group("Font", nil, 5)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.inline = true
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.Colour = ACH:Color("Font Colour", nil, 1, false, "relative", function() return unpack(Private.DB.global.MinimapStats.SystemStats.Colour) end, function(_, r, g, b) Private.DB.global.MinimapStats.SystemStats.Colour = {r, g, b} Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.Colour.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.FontSize = ACH:Range("Font Size", nil, 2, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.SystemStats.FontSize end, function(_, value) Private.DB.global.MinimapStats.SystemStats.FontSize = value Private:UpdateSystemStats() end, function() return not Private.DB.global.MinimapStats.SystemStats.Enable end)
    Private.GUI.args.MinimapStats.args.SystemStats.args.Font.args.FontSize.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.Location = ACH:Group("Location", nil, 3)

    Private.GUI.args.MinimapStats.args.Location.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.Location.Enable end, function(_, value) Private.DB.global.MinimapStats.Location.Enable = value Private:UpdateLocation() end)
    Private.GUI.args.MinimapStats.args.Location.args.Enable.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Location.args.ShowSubZone = ACH:Toggle("Show Sub Zone", nil, 2, nil, nil, "relative", function() return Private.DB.global.MinimapStats.Location.ShowSubZone end, function(_, value) Private.DB.global.MinimapStats.Location.ShowSubZone = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.ShowSubZone.relWidth = 0.5

    Private.GUI.args.MinimapStats.args.Location.args.Layout = ACH:Group("Layout", nil, 3)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[1] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[2] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[3] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.XOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.Location.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.Location.Layout[4] = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.YOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.Location.FontSize end, function(_, value) Private.DB.global.MinimapStats.Location.FontSize = value Private:UpdateLocation() end, function() return not Private.DB.global.MinimapStats.Location.Enable end)
    Private.GUI.args.MinimapStats.args.Location.args.Layout.args.FontSize.relWidth = 0.33

    Private.GUI.args.MinimapStats.args.InstanceDifficulty = ACH:Group("Instance Difficulty", nil, 4)

    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Enable end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Enable = value Private:UpdateInstanceDifficulty() end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Enable.relWidth = 1

    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout = ACH:Group("Layout", nil, 2)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.inline = true
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[1] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[1] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[2] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[2] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetWidth()), softMax = math.floor(Minimap:GetWidth()), step = 1 }, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[3] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[3] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.XOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = math.floor(-Minimap:GetHeight()), softMax = math.floor(Minimap:GetHeight()), step = 1}, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.Layout[4] end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.Layout[4] = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.YOffset.relWidth = 0.33
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MinimapStats.InstanceDifficulty.FontSize end, function(_, value) Private.DB.global.MinimapStats.InstanceDifficulty.FontSize = value Private:UpdateInstanceDifficulty() end, function() return not Private.DB.global.MinimapStats.InstanceDifficulty.Enable end)
    Private.GUI.args.MinimapStats.args.InstanceDifficulty.args.Layout.args.FontSize.relWidth = 0.33

    Private.GUI.args.Miscellaneous = ACH:Group("Miscellaneous", nil, 8, "tab")

    Private.GUI.args.Miscellaneous.args.AutoPurchase = ACH:Group("Auto Purchase", nil, 1, "tab", nil, nil, nil, function() return not Private.isForever end)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.Enable = ACH:Toggle("Enable", "Buys items from vendors until you have the set |cFFFFCC00quantity|r in your bags.", 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.AutoPurchase.Enable end, function(_, value) Private.DB.global.Miscellaneous.AutoPurchase.Enable = value Private:UpdateAutoPurchase() end)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.Enable.descStyle = "inline"
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.Enable.relWidth = 1

    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem = ACH:Group("Add Item", nil, 2)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.inline = true
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.args.Item = ACH:Input("Item", nil, 1, nil, "relative", function() return AutoPurchaseInput.Item end, function(_, value) AutoPurchaseInput.Item = value end, function() return not Private.DB.global.Miscellaneous.AutoPurchase.Enable end)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.args.Item.relWidth = 0.4
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.args.Quantity = ACH:Range("Quantity", nil, 2, {min = 1, max = 10000, softMin = 1, softMax = 2000, step = 1, bigStep = 10}, "relative", function() return AutoPurchaseInput.Quantity end, function(_, value) AutoPurchaseInput.Quantity = value end, function() return not Private.DB.global.Miscellaneous.AutoPurchase.Enable end)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.args.Quantity.relWidth = 0.4
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.args.Add = ACH:Execute("Add", nil, 3, AddAutoPurchaseItem, nil, nil, "relative", nil, nil, function() return not Private.DB.global.Miscellaneous.AutoPurchase.Enable or strtrim(AutoPurchaseInput.Item) == "" end)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.AddItem.args.Add.relWidth = 0.2

    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.Items = ACH:Group("Items", nil, 3)
    Private.GUI.args.Miscellaneous.args.AutoPurchase.args.Items.inline = true

    RefreshAutoPurchaseItems()

    Private.GUI.args.Miscellaneous.args.CombatTimer = ACH:Group("Combat Timer", nil, 3, "tab")
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.Enable end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.Enable = value Private:UpdateCombatTimer() end, nil)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Enable.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.OOCOpacity = ACH:Range("Opacity (Out of Combat)", nil, 2, { min = 0, max = 1, step = 0.01 }, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.OOCOpacity end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.OOCOpacity = value Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.OOCOpacity.relWidth = 0.5

    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout = ACH:Group("Layout", nil, 3)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.inline = true
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.Layout[1] end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.Layout[1] = value Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.Layout[2] end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.Layout[2] = value Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, { min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1 }, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.Layout[3] end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.Layout[3] = value Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, { min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1 }, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.Layout[4] end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.Layout[4] = value Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Font = ACH:Group("Font", nil, 4)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Font.inline = true
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Font.args.Colour = ACH:Color("Colour", nil, 1, true, "relative", function() return unpack(Private.DB.global.Miscellaneous.CombatTimer.Text.Colour) end, function(_, r, g, b, a) Private.DB.global.Miscellaneous.CombatTimer.Text.Colour = {r, g, b, a} Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Font.args.Colour.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Font.args.FontSize = ACH:Range("Font Size", nil, 2, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.CombatTimer.Text.FontSize end, function(_, value) Private.DB.global.Miscellaneous.CombatTimer.Text.FontSize = value Private:UpdateCombatTimer() end, function() return not Private.DB.global.Miscellaneous.CombatTimer.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatTimer.args.Font.args.FontSize.relWidth = 0.5

    Private.GUI.args.Miscellaneous.args.CombatResurrection = ACH:Group("Combat Resurrection", nil, 2, "tab", nil, nil, nil, function() return Private.isForever end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Enable end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Enable = value Private:UpdateCombatResurrection() end, nil)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Enable.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Preview = ACH:Toggle("Preview", nil, 2, nil, nil, "relative", function() return Private.CombatResurrectionPreview end, function(_, value) Private.CombatResurrectionPreview = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Preview.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Format = ACH:Select("Format", nil, 3, Private.CombatResurrectionFormats, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Text.Format end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Text.Format = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Format.relWidth = 0.33

    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout = ACH:Group("Layout", nil, 3)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.inline = true
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Layout[1] end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Layout[1] = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Layout[2] end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Layout[2] = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 4, { min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1 }, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Layout[3] end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Layout[3] = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 5, { min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1 }, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Layout[4] end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Layout[4] = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Layout.args.YOffset.relWidth = 0.5

    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font = ACH:Group("Font", nil, 4)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.inline = true
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.Colour = ACH:Color("Colour", nil, 1, true, "relative", function() return unpack(Private.DB.global.Miscellaneous.CombatResurrection.Text.Colour) end, function(_, r, g, b, a) Private.DB.global.Miscellaneous.CombatResurrection.Text.Colour = {r, g, b, a} Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.Colour.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.AvailableCharges = ACH:Color("Charges (Available)", nil, 2, true, "relative", function() return unpack(Private.DB.global.Miscellaneous.CombatResurrection.Text.Charges[1]) end, function(_, r, g, b, a) Private.DB.global.Miscellaneous.CombatResurrection.Text.Charges[1] = {r, g, b, a} Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.AvailableCharges.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.UnavailableCharges = ACH:Color("Charges (Unavailable)", nil, 3, true, "relative", function() return unpack(Private.DB.global.Miscellaneous.CombatResurrection.Text.Charges[2]) end, function(_, r, g, b, a) Private.DB.global.Miscellaneous.CombatResurrection.Text.Charges[2] = {r, g, b, a} Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.UnavailableCharges.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.FontSize = ACH:Range("Font Size", nil, 4, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.CombatResurrection.Text.FontSize end, function(_, value) Private.DB.global.Miscellaneous.CombatResurrection.Text.FontSize = value Private:UpdateCombatResurrection() end, function() return not Private.DB.global.Miscellaneous.CombatResurrection.Enable end)
    Private.GUI.args.Miscellaneous.args.CombatResurrection.args.Font.args.FontSize.relWidth = 1

    Private.GUI.args.Miscellaneous.args.Crosshair = ACH:Group("Crosshair", nil, 4, "tab")
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Enable end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Enable = value Private:UpdateCrosshair() end, nil)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Enable.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Colour = ACH:Color("Colour", nil, 2, true, "relative", function() return unpack(Private.DB.global.Miscellaneous.Crosshair.Colour) end, function(_, r, g, b, a) Private.DB.global.Miscellaneous.Crosshair.Colour = {r, g, b, a} Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Colour.relWidth = 0.33

    local CrosshairPreviews = {}
    for Key, Crosshair in pairs(Private.Crosshairs) do CrosshairPreviews[Key] = Crosshair.Preview end
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Texture = ACH:Select("Texture", nil, 3, CrosshairPreviews, nil, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Texture end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Texture = value Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Texture.relWidth = 0.33

    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout = ACH:Group("Layout", nil, 4)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.inline = true
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Layout[1] end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Layout[1] = value Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Layout[2] end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Layout[2] = value Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Layout[3] end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Layout[3] = value Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.XOffset.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Layout[4] end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Layout[4] = value Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.YOffset.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.Size = ACH:Range("Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Crosshair.Size[1] end, function(_, value) Private.DB.global.Miscellaneous.Crosshair.Size[1] = value Private.DB.global.Miscellaneous.Crosshair.Size[2] = value Private:UpdateCrosshair() end, function() return not Private.DB.global.Miscellaneous.Crosshair.Enable end)
    Private.GUI.args.Miscellaneous.args.Crosshair.args.Layout.args.Size.relWidth = 0.33

    Private.GUI.args.Miscellaneous.args.CVars = ACH:Group("CVars", nil, 5, "tab")

    Private.GUI.args.Miscellaneous.args.CVars.args.Sync = ACH:Toggle("Sync CVars", "This will |cFFFFCC00sync|r all CVars with all characters on this account.", 1, nil, nil, "full", function() return Private.DB.global.Miscellaneous.CVars.Sync end, function(_, value) Private.DB.global.Miscellaneous.CVars.Sync = value Private:SyncCVars() end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sync.descStyle = "inline"

    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles = ACH:Group("Toggles", nil, 2)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.inline = true

    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FCD = ACH:Toggle("Floating Combat Text: |cFFCC4040Damage|r", nil, 1, nil, nil, "full", function() return C_CVar.GetCVarBool("floatingCombatTextCombatDamage_v2") end, function(_, value) return Private:SetCVar("floatingCombatTextCombatDamage_v2", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FCH = ACH:Toggle("Floating Combat Text: |cFF40CC40Healing|r", nil, 2, nil, nil, "full", function() return C_CVar.GetCVarBool("floatingCombatTextCombatHealing_v2") end, function(_, value) return Private:SetCVar("floatingCombatTextCombatHealing_v2", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.AlwaysSharpen = ACH:Toggle("Always Sharpen", nil, 3, nil, nil, "full", function() return C_CVar.GetCVarBool("ResampleAlwaysSharpen") end, function(_, value) return Private:SetCVar("ResampleAlwaysSharpen", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.ShowTutorials = ACH:Toggle("Tutorials", nil, 4, nil, nil, "full", function() return C_CVar.GetCVarBool("showTutorials") end, function(_, value) return Private:SetCVar("showTutorials", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.ShowNPETutorials = ACH:Toggle("New Player Tutorials", nil, 5, nil, nil, "full", function() return C_CVar.GetCVarBool("showNPETutorials") end, function(_, value) return Private:SetCVar("showNPETutorials", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.ShowHousingTutorials = ACH:Toggle("Housing Tutorials", nil, 6, nil, nil, "full", function() return C_CVar.GetCVarBool("housingTutorialsEnabled") end, function(_, value) return Private:SetCVar("housingTutorialsEnabled", value and "1" or "0") end)

    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group = ACH:Group("Visual Effects", nil, 7)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.inline = true

    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Death = ACH:Toggle("|cFFCCCCCCDeath|r", nil, 1, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxDeath") end, function(_, value) return Private:SetCVar("ffxDeath", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Death.relWidth = 0.2
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Glow = ACH:Toggle("|cFFFFCC00Glow|r", nil, 2, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxGlow") end, function(_, value) return Private:SetCVar("ffxGlow", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Glow.relWidth = 0.2
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_LingeringVenari = ACH:Toggle("|cFF40CCFFLingering Venari|r", nil, 3, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxLingeringVenari") end, function(_, value) return Private:SetCVar("ffxLingeringVenari", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_LingeringVenari.relWidth = 0.2
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Nether = ACH:Toggle("|cFF89FAFDNether|r", nil, 4, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxNether") end, function(_, value) return Private:SetCVar("ffxNether", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Nether.relWidth = 0.2
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Venari = ACH:Toggle("|cFF40CCFFVenari|r", nil, 5, nil, nil, "relative", function() return C_CVar.GetCVarBool("ffxVenari") end, function(_, value) return Private:SetCVar("ffxVenari", value and "1" or "0") end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Toggles.args.FFX_Group.args.FFX_Venari.relWidth = 0.2

    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders = ACH:Group("Sliders", nil, 3)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.inline = true

    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.WTS = ACH:Range("World Text: |cFFCCCCCCScale|r", nil, 1, {min = 0.1, max = 2, softMin = 0.33, softMax = 1, step = 0.01}, "relative", function() return tonumber(C_CVar.GetCVar("WorldTextScale_v2")) end, function(_, value) Private:SetCVar("WorldTextScale_v2", value) end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.WTS.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.RAID_WaterDetail = ACH:Range("Raid: |cFFCCCCCCWater Detail|r", nil, 2, {min = 0, max = 3, softMin = 0, softMax = 3, step = 1}, "relative", function() return tonumber(C_CVar.GetCVar("RAID_WaterDetail")) end, function(_, value) Private:SetCVar("RAID_WaterDetail", value) end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.RAID_WaterDetail.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.RAID_WeatherDensity = ACH:Range("Raid: |cFFCCCCCCWeather Density|r", nil, 3, {min = 0, max = 3, softMin = 0, softMax = 3, step = 1}, "relative", function() return tonumber(C_CVar.GetCVar("RAIDweatherDensity")) end, function(_, value) Private:SetCVar("RAIDweatherDensity", value) end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.RAID_WeatherDensity.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.AutoLootRate = ACH:Range("Auto Loot Rate", "Rate in milliseconds to tick auto loot.", 4, {min = 25, max = 300, softMin = 50, softMax = 150, step = 5}, "relative", function() return tonumber(C_CVar.GetCVar("autoLootRate")) end, function(_, value) Private:SetCVar("autoLootRate", value) end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.AutoLootRate.relWidth = Private.isForever and 0.33 or 0.5
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.SpellQueueWindow = ACH:Range("Spell Queue Window", "Sets how early you can pre-activate/queue a spell in milliseconds.", 5, {min = 25, max = 300, softMin = 50, softMax = 150, step = 5}, "relative", function() return tonumber(C_CVar.GetCVar("SpellQueueWindow")) end, function(_, value) Private:SetCVar("SpellQueueWindow", value) end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.SpellQueueWindow.relWidth = Private.isForever and 0.33 or 0.5
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.CameraDistanceMaxZoomFactor = ACH:Range("Camera Distance", nil, 6, {min = 0.5, max = 4, softMin = 0.5, softMax = 2, step = 0.01}, "relative", function() return tonumber(C_CVar.GetCVar("cameraDistanceMaxZoomFactor")) end, function(_, value) Private:SetCVar("cameraDistanceMaxZoomFactor", value) end, nil, function() return not Private.isForever end)
    Private.GUI.args.Miscellaneous.args.CVars.args.Sliders.args.CameraDistanceMaxZoomFactor.relWidth = 0.33

    Private.GUI.args.Miscellaneous.args.MouseCursor = ACH:Group("Mouse Cursor", nil, 6, "tab")
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Enable end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Enable = value Private:UpdateMouseCursor() end, nil)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Enable.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Colour = ACH:Color("Colour", nil, 2, true, "relative", function() return unpack(Private.DB.global.Miscellaneous.MouseCursor.Colour) end, function(_, r, g, b, a) Private.DB.global.Miscellaneous.MouseCursor.Colour = {r, g, b, a} Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Colour.relWidth = 0.33

    local MouseCursorPreviews = {}
    for Key, MouseCursor in pairs(Private.MouseCursors) do MouseCursorPreviews[Key] = MouseCursor.Preview end
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Texture = ACH:Select("Texture", nil, 3, MouseCursorPreviews, nil, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Texture end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Texture = value Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Texture.relWidth = 0.33

    Private.GUI.args.Miscellaneous.args.MouseCursor.args.LayoutDesc = ACH:Notice("Layout is disabled for this mouse texture. Size, positioning & anchoring has been worked out for you.", 4, true, "medium", "full", function() return not Private.MouseCursors[Private.DB.global.Miscellaneous.MouseCursor.Texture].isAtlas end)

    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout = ACH:Group("Layout", nil, 5)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.inline = true
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Layout[1] end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Layout[1] = value Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable or Private.MouseCursors[Private.DB.global.Miscellaneous.MouseCursor.Texture].isAtlas end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Layout[2] end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Layout[2] = value Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable or Private.MouseCursors[Private.DB.global.Miscellaneous.MouseCursor.Texture].isAtlas end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Layout[3] end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Layout[3] = value Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable or Private.MouseCursors[Private.DB.global.Miscellaneous.MouseCursor.Texture].isAtlas end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.XOffset.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Layout[4] end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Layout[4] = value Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable or Private.MouseCursors[Private.DB.global.Miscellaneous.MouseCursor.Texture].isAtlas end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.YOffset.relWidth = 0.33
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.Size = ACH:Range("Size", nil, 5, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.MouseCursor.Size[1] end, function(_, value) Private.DB.global.Miscellaneous.MouseCursor.Size[1] = value Private.DB.global.Miscellaneous.MouseCursor.Size[2] = value Private:UpdateMouseCursor() end, function() return not Private.DB.global.Miscellaneous.MouseCursor.Enable or Private.MouseCursors[Private.DB.global.Miscellaneous.MouseCursor.Texture].isAtlas end)
    Private.GUI.args.Miscellaneous.args.MouseCursor.args.Layout.args.Size.relWidth = 0.33

    Private.GUI.args.Miscellaneous.args.Navigation = ACH:Group("Navigation", nil, 7, "tab", nil, nil, nil, function() return not Private.isForever end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Enable = ACH:Toggle("Enable", "Guides you to your |cFFFFCC00tracked quest|r or |cFFFFCC00map pin|r with an arrow, its distance and the steps to get there.", 1, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Enable end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Enable = value Private:UpdateNavigation() end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Enable.descStyle = "inline"
    Private.GUI.args.Miscellaneous.args.Navigation.args.Enable.relWidth = 1
    Private.GUI.args.Miscellaneous.args.Navigation.args.FlightPaths = ACH:Toggle("Flight Paths", "Shows your faction's |cFFFFCC00flight paths|r on the world map. The ones you have yet to learn are faded.", 2, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.Navigation.FlightPaths end, function(_, value) Private.DB.global.Miscellaneous.Navigation.FlightPaths = value Private:DrawNavigationMap() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.FlightPaths.relWidth = 0.25
    Private.GUI.args.Miscellaneous.args.Navigation.args.FlightTimer = ACH:Toggle("Flight Timer", "Counts down to landing while you are on a |cFFFFCC00flight path|r. A route you have yet to fly shows an estimate, marked with |cFFFFCC00~|r.", 3, nil, nil, "relative", function() return Private.DB.global.Miscellaneous.Navigation.FlightTimer end, function(_, value) Private.DB.global.Miscellaneous.Navigation.FlightTimer = value Private:UpdateNavigationFlightTimer() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.FlightTimer.relWidth = 0.25

    local NavigationArrowPreviews = {}
    for Key, Arrow in pairs(Private.NavigationArrows) do NavigationArrowPreviews[Key] = Arrow.Preview end
    Private.GUI.args.Miscellaneous.args.Navigation.args.ArrowTexture = ACH:Select("Arrow Texture", nil, 4, NavigationArrowPreviews, nil, "relative", function() return Private.DB.global.Miscellaneous.Navigation.ArrowTexture end, function(_, value) Private.DB.global.Miscellaneous.Navigation.ArrowTexture = value Private:UpdateNavigationArrow() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.ArrowTexture.relWidth = 0.5

    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout = ACH:Group("Layout", nil, 5)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.inline = true
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Layout[1] end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Layout[1] = value Private:UpdateNavigationArrow() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Layout[2] end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Layout[2] = value Private:UpdateNavigationArrow() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Layout[3] end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Layout[3] = value Private:UpdateNavigationArrow() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.XOffset.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Layout[4] end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Layout[4] = value Private:UpdateNavigationArrow() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.YOffset.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.Size = ACH:Range("Arrow Size", nil, 5, {min = 8, max = 128, softMin = 16, softMax = 96, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Size end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Size = value Private:UpdateNavigationArrow() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.Size.relWidth = 0.5
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.FontSize = ACH:Range("Font Size", nil, 6, {min = 8, max = 128, softMin = 8, softMax = 32, step = 1}, "relative", function() return Private.DB.global.Miscellaneous.Navigation.Text.FontSize end, function(_, value) Private.DB.global.Miscellaneous.Navigation.Text.FontSize = value Private:UpdateNavigationArrow() Private:UpdateNavigationFlightTimer() end, function() return not Private.DB.global.Miscellaneous.Navigation.Enable end)
    Private.GUI.args.Miscellaneous.args.Navigation.args.Layout.args.FontSize.relWidth = 0.5

    Private.GUI.args.MythicPlusTimer = ACH:Group("Mythic+ Timer", nil, 9, "tab", nil, nil, nil, function() return Private.isForever end)
    Private.GUI.args.MythicPlusTimer.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.Enable end, function(_, value) Private.DB.global.MythicPlusTimer.Enable = value Private:UpdateMythicPlusTimer() end, nil)
    Private.GUI.args.MythicPlusTimer.args.Enable.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Preview = ACH:Toggle("Preview", nil, 2, nil, nil, "relative", function() return Private.MythicPlusTimerPreview end, function(_, value) Private.MythicPlusTimerPreview = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Preview.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.ShowDeaths = ACH:Toggle("Deaths", nil, 6, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.ShowDeaths end, function(_, value) Private.DB.global.MythicPlusTimer.ShowDeaths = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.ShowDeaths.relWidth = 0.33
    Private.GUI.args.MythicPlusTimer.args.ShowBosses = ACH:Toggle("Boss Objectives", nil, 7, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.ShowBosses end, function(_, value) Private.DB.global.MythicPlusTimer.ShowBosses = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.ShowBosses.relWidth = 0.33
    Private.GUI.args.MythicPlusTimer.args.ShowForces = ACH:Toggle("Enemy Forces", nil, 8, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.ShowForces end, function(_, value) Private.DB.global.MythicPlusTimer.ShowForces = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.ShowForces.relWidth = 0.33

    Private.GUI.args.MythicPlusTimer.args.LayoutGroup = ACH:Group("Layout & Positioning", nil, 9, "tab")
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MythicPlusTimer.Layout[1] end, function(_, value) Private.DB.global.MythicPlusTimer.Layout[1] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MythicPlusTimer.Layout[2] end, function(_, value) Private.DB.global.MythicPlusTimer.Layout[2] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Layout[3] end, function(_, value) Private.DB.global.MythicPlusTimer.Layout[3] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.XOffset.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -1000, softMax = 1000, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Layout[4] end, function(_, value) Private.DB.global.MythicPlusTimer.Layout[4] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.YOffset.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.Width = ACH:Range("Width", nil, 5, {min = 128, max = 1024, softMin = 128, softMax = 512, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Width end, function(_, value) Private.DB.global.MythicPlusTimer.Width = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.Width.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.RowHeight = ACH:Range("Bar Height", nil, 6, {min = 12, max = 64, softMin = 16, softMax = 40, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.RowHeight end, function(_, value) Private.DB.global.MythicPlusTimer.RowHeight = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.LayoutGroup.args.RowHeight.relWidth = 0.5

    Private.GUI.args.MythicPlusTimer.args.Rows = ACH:Group("Rows & Texts", nil, 10, "tab")
    Private.GUI.args.MythicPlusTimer.args.Rows.args.Texture = ACH:SharedMediaStatusbar("Texture", nil, 1, "relative", function() return Private.DB.global.MythicPlusTimer.Texture end, function(_, value) Private.DB.global.MythicPlusTimer.Texture = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.Texture.relWidth = 1

    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup = ACH:Group("Name", nil, 2)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.inline = true
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.FontSize = ACH:Range("Font Size", nil, 1, {min = 8, max = 32, softMin = 8, softMax = 24, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Text.Name_FontSize end, function(_, value) Private.DB.global.MythicPlusTimer.Text.Name_FontSize = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.FontSize.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.Colour = ACH:Color("Colour", nil, 2, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Text.Name_Colour) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Text.Name_Colour = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.Colour.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -100, softMax = 100, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Text.Name_XOffset end, function(_, value) Private.DB.global.MythicPlusTimer.Text.Name_XOffset = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.XOffset.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -50, softMax = 50, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Text.Name_YOffset end, function(_, value) Private.DB.global.MythicPlusTimer.Text.Name_YOffset = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.NameGroup.args.YOffset.relWidth = 0.5

    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup = ACH:Group("Amount", nil, 3)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.inline = true
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.FontSize = ACH:Range("Font Size", nil, 1, {min = 8, max = 32, softMin = 8, softMax = 24, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Text.Amount_FontSize end, function(_, value) Private.DB.global.MythicPlusTimer.Text.Amount_FontSize = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.FontSize.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.Colour = ACH:Color("Colour", nil, 2, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Text.Amount_Colour) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Text.Amount_Colour = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.Colour.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -100, softMax = 100, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Text.Amount_XOffset end, function(_, value) Private.DB.global.MythicPlusTimer.Text.Amount_XOffset = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.XOffset.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -50, softMax = 50, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.Text.Amount_YOffset end, function(_, value) Private.DB.global.MythicPlusTimer.Text.Amount_YOffset = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Rows.args.AmountGroup.args.YOffset.relWidth = 0.5

    Private.GUI.args.MythicPlusTimer.args.TitleBar = ACH:Group("Title Bar", nil, 11, "tab")
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Enable end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Enable = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.Enable.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.ShowBackdrop = ACH:Toggle("Show Backdrop", nil, 2, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.ShowBackdrop end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.ShowBackdrop = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.ShowBackdrop.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.Height = ACH:Range("Height", nil, 3, {min = 8, max = 128, softMin = 12, softMax = 64, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Height end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Height = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.Height.relWidth = 0.33
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.XOffset = ACH:Range("X Offset", nil, 4, {min = -3000, max = 3000, softMin = -100, softMax = 100, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.XOffset end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.XOffset = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.XOffset.relWidth = 0.33
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.YOffset = ACH:Range("Y Offset", nil, 5, {min = -3000, max = 3000, softMin = -100, softMax = 100, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.YOffset end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.YOffset = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.YOffset.relWidth = 0.33

    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup = ACH:Group("Text", nil, 6)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.inline = true
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.Enable = ACH:Toggle("Enable", nil, 1, nil, nil, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.Enable.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.Colour = ACH:Color("Colour", nil, 2, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.TitleBar.Text.Colour) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.TitleBar.Text.Colour = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.Colour.relWidth = 0.5

    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup = ACH:Group("Layout", nil, 3)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.inline = true
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorFrom = ACH:Select("Anchor From", nil, 1, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[1] end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[1] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorFrom.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorTo = ACH:Select("Anchor To", nil, 2, Private.AnchorPoints, nil, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[2] end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[2] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.AnchorTo.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.XOffset = ACH:Range("X Offset", nil, 3, {min = -3000, max = 3000, softMin = -100, softMax = 100, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[3] end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[3] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.XOffset.relWidth = 0.33
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.YOffset = ACH:Range("Y Offset", nil, 4, {min = -3000, max = 3000, softMin = -50, softMax = 50, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[4] end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Text.Layout[4] = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.YOffset.relWidth = 0.33
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.FontSize = ACH:Range("Font Size", nil, 5, {min = 8, max = 32, softMin = 8, softMax = 24, step = 1}, "relative", function() return Private.DB.global.MythicPlusTimer.TitleBar.Text.FontSize end, function(_, value) Private.DB.global.MythicPlusTimer.TitleBar.Text.FontSize = value Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Enable or not Private.DB.global.MythicPlusTimer.TitleBar.Text.Enable end)
    Private.GUI.args.MythicPlusTimer.args.TitleBar.args.TextGroup.args.LayoutGroup.args.FontSize.relWidth = 0.33

    Private.GUI.args.MythicPlusTimer.args.Colours = ACH:Group("Bar Colours", nil, 12, "tab")
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Progress = ACH:Color("Timer / Objectives", nil, 1, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Colours.Progress) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Colours.Progress = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Progress.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Second = ACH:Color("+2", nil, 2, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Colours.Second) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Colours.Second = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Second.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Third = ACH:Color("+3", nil, 3, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Colours.Third) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Colours.Third = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Third.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Complete = ACH:Color("Completed", nil, 4, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Colours.Complete) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Colours.Complete = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Complete.relWidth = 0.5
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Expired = ACH:Color("Over Time", nil, 5, false, "relative", function() return unpack(Private.DB.global.MythicPlusTimer.Colours.Expired) end, function(_, r, g, b) Private.DB.global.MythicPlusTimer.Colours.Expired = {r, g, b} Private:UpdateMythicPlusTimer() end, function() return not Private.DB.global.MythicPlusTimer.Enable end)
    Private.GUI.args.MythicPlusTimer.args.Colours.args.Expired.relWidth = 0.5

    Private.GUI.args.Toggles = ACH:Group("Toggles", nil, 11, "tab")

    local Toggles = {
        [1] = { name = "Auto Delete", desc = "Auto populates |cFFFFCC00delete|r where required.", key = "AutoDelete", requiresReload = false, isRetail = false },
        [2] = { name = "Auto Quest", desc = "Automatically |cFFFFCC00accept|r and |cFFFFCC00turn-in|r quests (skipping low-level ones). Hold |cFFFFCC00SHIFT|r to override.", key = "AutoQuest", requiresReload = false, isRetail = false },
        [3] = { name = "Auto Sign Up", desc = "Automatically accept |cFFFFCC00role|r popups.", key = "AutoSignUp", requiresReload = false, isRetail = true },
        [4] = { name = "Hide Boss Banner", desc = "Hides the popup that appears when a boss is |cFFFFCC00defeated|r.", key = "HideBossBanner", requiresReload = true, isRetail = true },
        [5] = { name = "Hide Loss of Control", desc = "Hides the popup that shows when you are |cFFFFCC00crowd-controlled|r.", key = "HideLossOfControl", requiresReload = true, isRetail = false },
        [6] = { name = "Hide Talking Head", desc = nil, key = "HideTalkingHead", requiresReload = true, isRetail = true },
        [7] = { name = "Skip Cinematics", desc = "Automatically skip |cFFFFCC00seen|r & |cFFFFCC00unseen|r cinematics.", key = "SkipCinematics", requiresReload = true, isRetail = false },
    }

    for i, toggle in ipairs(Toggles) do
        Private.GUI.args.Toggles.args[toggle.name] = ACH:Toggle(toggle.name, toggle.desc, i, nil, nil, "full", function() return Private.DB.global.Toggles[toggle.key] end, function(_, value) Private.DB.global.Toggles[toggle.key] = value if toggle.requiresReload then Private.E:StaticPopup_Show("CONFIG_RL") end end, nil, function() return toggle.isRetail and WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE end)
        Private.GUI.args.Toggles.args[toggle.name].descStyle = "inline"
    end

    Private.GUI.args.Profiles = ACH:Group("Profiles", nil, 10, "tab")
    Private.GUI.args.Profiles.args.BigWigs = ACH:Execute("|TInterface\\AddOns\\BigWigs\\Media\\Icons\\minimap_raid.tga:16:16|t BigWigs", nil, 1, function() Private:ImportBigWigs() Private.E:StaticPopup_Show("CONFIG_RL") end, nil, nil, "relative", nil, nil, nil, function() return not Private:IsAddOnLoaded("BigWigs") end)
    Private.GUI.args.Profiles.args.BigWigs.relWidth = 1
    Private.GUI.args.Profiles.args.ElvUI = ACH:Execute("|TInterface\\AddOns\\ElvUI\\Game\\Shared\\Media\\Textures\\LogoAddon:16:16|t |cFF1784d1ElvUI|r", nil, 2, function() Private:ImportElvUI() end, nil, nil, "relative", nil, nil, nil, function() return not Private:IsAddOnLoaded("ElvUI") end)
    Private.GUI.args.Profiles.args.ElvUI.relWidth = 1
    Private.GUI.args.Profiles.args.Platynator = ACH:Execute("|TInterface\\AddOns\\Platynator\\Assets\\logo.tga:16:16|t Platynator", nil, 3, function() Private:ImportPlatynator() Private.E:StaticPopup_Show("CONFIG_RL") end, nil, nil, "relative", nil, nil, nil, function() return not Private:IsAddOnLoaded("Platynator") end)
    Private.GUI.args.Profiles.args.Platynator.relWidth = 1
    Private.GUI.args.Profiles.args.SkironCooldownManager = ACH:Execute("|TInterface\\AddOns\\SkironCooldownManager\\Media\\Logo.png:16:16|t |cFF4080FFSkiron|r|cFFFFFFFFCooldownManager|r", nil, 4, function() Private:ImportSkironCooldownManager() Private.E:StaticPopup_Show("CONFIG_RL") end, nil, nil, "relative", nil, nil, nil, function() return not Private:IsAddOnLoaded("SkironCooldownManager") end)
    Private.GUI.args.Profiles.args.SkironCooldownManager.relWidth = 1
    Private.GUI.args.Profiles.args.ImportUnhaltedUI = ACH:Execute("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Logo.png:16:16|t |cFF6080FFUnhalted|r|cFF808080UI|r", nil, 5, function() Private:ImportUnhaltedUI() Private.E:StaticPopup_Show("CONFIG_RL") end, nil, nil, "relative", nil, nil, nil, function() return not Private:IsAddOnLoaded("ElvUI_Unhalted") end)
    Private.GUI.args.Profiles.args.ImportUnhaltedUI.relWidth = 1
    Private.GUI.args.Profiles.args.ExportUnhaltedUI = ACH:Execute("|TInterface\\AddOns\\ElvUI_Unhalted\\Media\\Logo.png:16:16|t |cFF6080FFUnhalted|r|cFF808080UI|r (Export)", nil, 6, function() Private:ExportUnhaltedUI() end, nil, nil, "relative", nil, nil, nil, function() return not Private:IsDeveloper() end)
    Private.GUI.args.Profiles.args.ExportUnhaltedUI.relWidth = 1

    if Private.E then Private.E.Options.args.ElvUIAnchors = Private.GUI end
end
