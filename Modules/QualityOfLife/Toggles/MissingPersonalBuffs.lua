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

    Frame.Text = Frame:CreateFontString(nil, "OVERLAY")
    Frame.Text:SetPoint("CENTER", Frame, "CENTER", 0, 0)
    Frame.Text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, SLUG")
    Frame.Text:SetTextColor(1, 1, 1, 1)
    Frame.Text:SetText((auraName == "Source of Magic" and "Source\nOf\nMagic") or (auraName == "Oils" and "Weapon\nOil") or auraName)

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
    local _, _, DifficultyID = GetInstanceInfo()
    if not Private.InstanceIDs[DifficultyID] then
        for auraType in pairs(MissingPersonalBuffs) do HideMissingPersonalBuff(auraType) end
        Private.MissingPersonalBuffFrame:Hide()
        return
    end

    for auraType, auraInfo in pairs(Private.PersonalBuffs) do
        local hasAura = false
        local canCheck = true

        if auraType == "Oils" then
            local specIndex = C_SpecializationInfo.GetSpecialization()
            local specID = specIndex and C_SpecializationInfo.GetSpecializationInfo(specIndex)

            local enchantInfo = C_PaperDollInfo.GetTemporaryEnchantmentInfo(INVSLOT_MAINHAND); hasAura = enchantInfo ~= nil
            if auraInfo.dualWieldSpecIDs[specID] then
                local offhandEnchantInfo = C_PaperDollInfo.GetTemporaryEnchantmentInfo(INVSLOT_OFFHAND); hasAura = hasAura and (offhandEnchantInfo ~= nil)
            end
        elseif auraType == "Source of Magic" then
            canCheck = C_Spell.IsSpellKnown(369459) and not C_Secrets.ShouldSpellAuraBeSecret(369459)
            local healerIsPresent = false
            if canCheck then
                local inRaid = IsInRaid()
                local groupMembers = GetNumGroupMembers()
                for i = 1, groupMembers do
                    local unit = inRaid and ("raid" .. i) or (i == 1 and "player" or ("party" .. (i - 1)))
                    if UnitExists(unit) then
                        local unitRole = UnitGroupRolesAssigned(unit)
                        if not issecretvalue(unitRole) and unitRole == "HEALER" then healerIsPresent = true break end
                    end
                end
            end
            canCheck = canCheck and healerIsPresent
            if canCheck then
                local auraData = C_UnitAuras.GetPlayerAuraBySpellID(369459)
                if issecretvalue(auraData) then canCheck = false
                else
                    hasAura = auraData ~= nil
                end
            end
        else
            for _, spellName in ipairs(auraInfo.spellNames) do
                if C_Secrets.ShouldSpellAuraBeSecret(spellName) then
                    return
                else
                    if issecretvalue(C_UnitAuras.GetAuraDataBySpellName("player", spellName)) then
                        return
                    elseif C_UnitAuras.GetAuraDataBySpellName("player", spellName) then
                        hasAura = true
                        break
                    end
                end
            end
        end

        if canCheck and not hasAura then
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
        Private.MissingPersonalBuffFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Private.MissingPersonalBuffFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
        Private.MissingPersonalBuffFrame:RegisterEvent("SPELLS_CHANGED")
        Private.MissingPersonalBuffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.MissingPersonalBuffFrame:RegisterEvent("WEAPON_ENCHANT_CHANGED")
        Private.MissingPersonalBuffFrame:RegisterEvent("WEAPON_SLOT_CHANGED")
        Private.MissingPersonalBuffFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        Private.MissingPersonalBuffFrame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
        Private.MissingPersonalBuffFrame:SetScript("OnEvent", function(_, event)
            if event == "ADDON_RESTRICTION_STATE_CHANGED" then
                RunNextFrame(function() if Private.DB.global.QualityOfLife.Toggles.MissingPersonalBuffs then CheckForMissingPersonalBuffs() end end)
            else
                CheckForMissingPersonalBuffs()
            end
        end)
        CheckForMissingPersonalBuffs()
    else
        Private.MissingPersonalBuffFrame:UnregisterAllEvents()
        Private.MissingPersonalBuffFrame:SetScript("OnEvent", nil)
        for auraType in pairs(MissingPersonalBuffs) do HideMissingPersonalBuff(auraType) end
        Private.MissingPersonalBuffFrame:Hide()
    end
end
