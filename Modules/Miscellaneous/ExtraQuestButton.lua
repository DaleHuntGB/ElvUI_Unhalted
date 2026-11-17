local Private = select(2, ...)
local AB = Private.E:GetModule("ActionBars")

local ButtonSize = 52
local RangeInterval = 0.2
local StyleTexture = "Interface\\ExtraButton\\Default"
local ExtraActionBinding = "EXTRAACTIONBUTTON1"
local White = { r = 1, g = 1, b = 1 }
local Events = { "QUEST_LOG_UPDATE", "SUPER_TRACKING_CHANGED", "BAG_UPDATE_COOLDOWN", "UPDATE_BINDINGS", "PLAYER_TARGET_CHANGED", "PLAYER_REGEN_ENABLED" }
local BossButtonUpdates = { "ExtraButtons_UpdateAlpha", "ExtraButtons_UpdateScale", "ExtraButtons_GlobalFade", "UpdateExtraBindings", "UpdateButtonSettings" }
local VisibilitySnippet = [[
    self:ClearBindings()
    if self:GetAttribute("state-extrabar") == "hide" or not self:GetAttribute("item") then
        self:Hide()
        return
    end
    self:Show()
    for Index = 1, 2 do
        local Key = self:GetAttribute("key" .. Index)
        if Key then self:SetBindingClick(true, Key, self, "LeftButton") end
    end
]]

local RangeTimer = 0

local function UpdateLayout(Button)
    if InCombatLockdown() then return end

    local DB = Private.E.db.actionbar.extraActionButton
    local Holder = Button:GetParent()
    Holder.db = DB
    Holder:SetParent(DB.inheritGlobalFade and AB.fadeParent or Private.E.UIParent)
    Holder:SetSize(ButtonSize * DB.scale, ButtonSize * DB.scale)
    Button:SetScale(DB.scale * Private.E.uiscale)
    Button:SetAlpha(DB.alpha)
    Button.style:SetAlpha(not DB.clean and DB.alpha or 0)

    local Key1, Key2 = GetBindingKey(ExtraActionBinding)
    Button.HotKey:SetText(Key1)
    AB:FixKeybindText(Button)
    AB:FixKeybindColor(Button)

    local Font, FontSize, FontOutline = AB:GetFont(DB.countFont, DB.countFontSize, DB.countFontOutline)
    local CountAnchor = DB.countTextPosition or "BOTTOMRIGHT"
    local CountColour = DB.useCountColor and DB.countColor or AB.db.fontColor
    Button.Count:FontTemplate(Font, FontSize, FontOutline)
    Button.Count:SetTextColor(CountColour.r, CountColour.g, CountColour.b, CountColour.a)
    Button.Count:SetJustifyH(AB:GetTextJustify(CountAnchor))
    Button.Count:ClearAllPoints()
    Button.Count:Point(CountAnchor, DB.countTextXOffset or 0, DB.countTextYOffset or 2)
    Button.Count:SetShown(DB.counttext ~= false)
    RangeTimer = 0

    if Key1 == Button:GetAttribute("key1") and Key2 == Button:GetAttribute("key2") then return end
    Button:SetAttribute("key1", Key1)
    Button:SetAttribute("key2", Key2)
    Button:Execute(VisibilitySnippet)
end

local function UpdateItem(Button)
    local QuestID = C_SuperTrack.GetSuperTrackedQuestID() or 0
    local LogIndex = QuestID > 0 and C_QuestLog.GetLogIndexForQuestID(QuestID)
    local Link, Texture, Charges, ShowWhenComplete = (LogIndex and GetQuestLogSpecialItemInfo or nop)(LogIndex)
    local ItemLink = Texture and (ShowWhenComplete or not C_QuestLog.IsComplete(QuestID)) and Link or nil
    if ItemLink ~= Button:GetAttribute("item") then
        if InCombatLockdown() then return end
        Button:SetAttribute("item", ItemLink)
        Button:Execute(VisibilitySnippet)
    end
    if not ItemLink then return end

    Button.QuestID = QuestID
    Button.icon:SetTexture(Texture)
    Button.Count:SetText(Charges > 1 and Charges or "")
    local Start, Duration, Enable = GetQuestLogSpecialItemCooldown(LogIndex)
    if Private:IsSecret(Start) or not Start then return end
    CooldownFrame_Set(Button.cooldown, Start, Duration, Enable)
end

local function ExtraQuestButton_OnEvent(Button, Event)
    if Event == "PLAYER_TARGET_CHANGED" then
        RangeTimer = 0
    elseif Event == "UPDATE_BINDINGS" then
        UpdateLayout(Button)
    elseif Event == "PLAYER_REGEN_ENABLED" then
        UpdateLayout(Button)
        UpdateItem(Button)
    else
        UpdateItem(Button)
    end
end

local function ExtraQuestButton_OnUpdate(Button, Elapsed)
    RangeTimer = RangeTimer - Elapsed
    if RangeTimer > 0 then return end
    RangeTimer = RangeInterval

    local LogIndex = C_QuestLog.GetLogIndexForQuestID(Button.QuestID)
    local InRange = LogIndex and IsQuestLogSpecialItemInRange(LogIndex)
    if Private:IsSecret(InRange) then return end
    local OutOfRange, isRangeOnText = InRange == 0 and AB.db.noRangeColor, AB.db.useRangeColorText
    local IconColour = not isRangeOnText and OutOfRange or AB.db.usableColor
    local TextColour = isRangeOnText and OutOfRange or White
    Button.icon:SetVertexColor(IconColour.r, IconColour.g, IconColour.b)
    Button.HotKey:SetVertexColor(TextColour.r, TextColour.g, TextColour.b)
end

local function ExtraQuestButton_OnEnter(Button)
    local LogIndex = C_QuestLog.GetLogIndexForQuestID(Button.QuestID)
    if LogIndex then
        GameTooltip_SetDefaultAnchor(GameTooltip, Button)
        GameTooltip:SetQuestLogSpecialItem(LogIndex)
    end
    AB:Bar_OnEnter(Button:GetParent())
    AB:BindUpdate(Button)
end

local function ExtraQuestButton_OnLeave(Button)
    GameTooltip:Hide()
    AB:Bar_OnLeave(Button:GetParent())
end

function Private:SetupExtraQuestButton()
    if not Private.DB.global.Miscellaneous.ExtraQuestButton.Enable or not AB.Initialized then return end

    local Holder = CreateFrame("Frame", "UnhaltedExtraQuestButtonHolder", Private.E.UIParent)
    Holder:SetPoint("BOTTOM", Private.E.UIParent, "BOTTOM", -150, 300)
    Holder:SetSize(ButtonSize, ButtonSize)

    local Button = CreateFrame("Button", "UnhaltedExtraQuestButton", Holder, "SecureActionButtonTemplate, SecureHandlerStateTemplate")
    Button:SetSize(ButtonSize, ButtonSize)
    Button:SetPoint("CENTER")
    Button:SetIgnoreParentScale(true)
    Button:RegisterForClicks("AnyUp", "AnyDown")
    Button:SetAttribute("type", "item")
    Button:SetAttribute("_onstate-extrabar", VisibilitySnippet)
    Button:Hide()
    Button.QuestID = 0
    Button.commandName = ExtraActionBinding

    Button.icon = Button:CreateTexture()
    Button.HotKey = Button:CreateFontString(nil, "OVERLAY", "NumberFontNormalGray")
    Button.Count = Button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    Button.style = Button:CreateTexture()
    Button.style:SetTexture(StyleTexture)
    Button.style:SetSize(256, 128)
    Button.style:SetPoint("CENTER")
    Button.cooldown = CreateFrame("Cooldown", nil, Button, "CooldownFrameTemplate")
    Button.cooldown:SetAllPoints(Button.icon)

    Private.E:RegisterCooldown(Button.cooldown, "bossbutton")
    AB.handledbuttons[Button] = true
    AB:StyleButton(Button, true)
    Button:SetTemplate()

    Button:SetScript("OnEnter", ExtraQuestButton_OnEnter)
    Button:SetScript("OnLeave", ExtraQuestButton_OnLeave)
    Button:SetScript("OnUpdate", ExtraQuestButton_OnUpdate)
    Button:SetScript("OnEvent", ExtraQuestButton_OnEvent)
    for _, Event in ipairs(Events) do Button:RegisterEvent(Event) end
    RegisterStateDriver(Button, "extrabar", "[extrabar] hide; show")

    Private.E:CreateMover(Holder, "UnhaltedExtraQuestButtonMover", "Extra Quest Button", nil, nil, nil, "ALL,ACTIONBARS")
    for _, Method in ipairs(BossButtonUpdates) do
        if AB[Method] then hooksecurefunc(AB, Method, function() UpdateLayout(Button) end) end
    end

    UpdateLayout(Button)
    UpdateItem(Button)
end
