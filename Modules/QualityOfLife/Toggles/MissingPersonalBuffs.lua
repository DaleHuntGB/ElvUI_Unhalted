local Private = select(2, ...)

local MissingPersonalBuffs = {}

local function CreateMissingPersonalBuff(auraName, auraIcon)
    local Frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Frame:SetSize(48, 48)
    Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    Frame:SetBackdrop({ bgFile = nil, edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    Frame:SetBackdropBorderColor(0, 0, 0, 1)

    Frame.Icon = Frame:CreateTexture(nil, "OVERLAY")
    Frame.Icon:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
    Frame.Icon:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
    Frame.Icon:SetTexture(auraIcon)
    Frame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
    Frame.Icon:SetDesaturated(true)

    Frame:Show()

    return Frame
end

local function HideMissingPersonalBuff(auraName)
    if MissingPersonalBuffs[auraName] then
        MissingPersonalBuffs[auraName]:Hide()
        MissingPersonalBuffs[auraName] = nil
    end
end

local function LayoutMissingPersonalBuffs()
    local Frames = {}
    for _, BuffFrame in pairs(MissingPersonalBuffs) do
        Frames[#Frames + 1] = BuffFrame
    end

    local Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, math.max(#Frames, 1), 1, 0)
    local Anchor = AnchorUtil.CreateAnchor("LEFT", Private.MissingPersonalBuffFrame, "LEFT", 0, 0)
    AnchorUtil.GridLayout(Frames, Anchor, Layout)

    Private.MissingPersonalBuffFrame:SetSize(#Frames * 50, 48)
    Private.MissingPersonalBuffFrame:ClearAllPoints()
    Private.MissingPersonalBuffFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 224.1)
    Private.MissingPersonalBuffFrame:Show()
end

local function CheckForMissingPersonalBuffs()
    for auraType, auraInfo in pairs(Private.PersonalBuffs) do
        local hasAura = false

        if auraType == "Oils" then
            local enchantInfo = C_PaperDollInfo.GetTemporaryEnchantmentInfo(INVSLOT_MAINHAND); hasAura = enchantInfo ~= nil
        else
            for _, spellName in ipairs(auraInfo.spellNames) do
                if C_UnitAuras.GetAuraDataBySpellName("player", spellName) then hasAura = true break end
            end
        end

        if not hasAura and IsInInstance() then
            MissingPersonalBuffs[auraType] = MissingPersonalBuffs[auraType] or CreateMissingPersonalBuff(auraType, auraInfo.iconID)
        elseif MissingPersonalBuffs[auraType] then
            HideMissingPersonalBuff(auraType)
        end
    end

    LayoutMissingPersonalBuffs()
end

function Private:SetupMissingPersonalBuffs()
    Private.MissingPersonalBuffFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Private.MissingPersonalBuffFrame:SetSize(1, 1)
    Private.MissingPersonalBuffFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 224.1)

    Private:UpdateMissingPersonalBuffs()
end

function Private:UpdateMissingPersonalBuffs()
    if Private.DB.global.QualityOfLife.Toggles.MissingPersonalBuffs then
        Private.MissingPersonalBuffFrame:RegisterUnitEvent("UNIT_AURA", "player")
        Private.MissingPersonalBuffFrame:RegisterUnitEvent("PLAYER_DAMAGE_DONE_MODS", "player")
        Private.MissingPersonalBuffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.MissingPersonalBuffFrame:SetScript("OnEvent", function() CheckForMissingPersonalBuffs() end)
        CheckForMissingPersonalBuffs()
    else
        Private.MissingPersonalBuffFrame:UnregisterAllEvents()
        Private.MissingPersonalBuffFrame:SetScript("OnEvent", nil)
        for auraType in pairs(MissingPersonalBuffs) do HideMissingPersonalBuff(auraType) end
        Private.MissingPersonalBuffFrame:Hide()
    end
end
