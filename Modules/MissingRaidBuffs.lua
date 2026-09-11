local Private = select(2, ...)

local MissingBuffs = {}
local ClassesInGroup = {}

local function CreateMissingBuff(auraID)
    local Frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Frame:SetSize(48, 48)
    Frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    Frame:SetBackdrop({ bgFile = nil, edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    Frame:SetBackdropBorderColor(0, 0, 0, 1)

    Frame.Icon = Frame:CreateTexture(nil, "OVERLAY")
    Frame.Icon:SetPoint("TOPLEFT", Frame, "TOPLEFT", 1, -1)
    Frame.Icon:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", -1, 1)
    Frame.Icon:SetTexture(C_Spell.GetSpellTexture(auraID))
    Frame.Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
    Frame.Icon:SetDesaturated(true)

    Frame:Show()

    return Frame
end

local function HideMissingBuff(auraID)
    if MissingBuffs[auraID] then
        MissingBuffs[auraID]:Hide()
        MissingBuffs[auraID] = nil
    end
end

local function LayoutMissingBuffs()
    local Frames = {}
    for _, BuffFrame in pairs(MissingBuffs) do
        Frames[#Frames + 1] = BuffFrame
    end

    local Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, math.max(#Frames, 1), 1, 0)
    local Anchor = AnchorUtil.CreateAnchor("LEFT", Private.MissingBuffFrame, "LEFT", 0, 0)
    AnchorUtil.GridLayout(Frames, Anchor, Layout)

    Private.MissingBuffFrame:SetSize(#Frames * 50, 48)
    Private.MissingBuffFrame:ClearAllPoints()
    Private.MissingBuffFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 175.1)
    Private.MissingBuffFrame:Show()
end

local function CheckForMissingBuffs()
    for auraID, auraInfo in pairs(Private.RaidBuffs) do
        local hasAura = false

        for _, spellID in ipairs(auraInfo.spellIDs) do
            if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then hasAura = true break end
        end

        if not hasAura and ClassesInGroup[auraInfo.requiredClass] then
            MissingBuffs[auraID] = MissingBuffs[auraID] or CreateMissingBuff(auraID)
        elseif MissingBuffs[auraID] then
            HideMissingBuff(auraID)
        end
    end

    LayoutMissingBuffs()
end

local function FetchGroupMemberClasses()
    wipe(ClassesInGroup)

    local _, playerClass = UnitClass("player")
    ClassesInGroup[playerClass] = true

    local inRaid = IsInRaid()
    local numGroupMembers = inRaid and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, numGroupMembers do
        local unit = (inRaid and "raid" or "party") .. i
        if UnitExists(unit) then
            local _, unitClass = UnitClass(unit)
            ClassesInGroup[unitClass] = true
        end
    end
end

function Private:SetupMissingRaidBuffs()
    Private.MissingBuffFrame = CreateFrame("Frame")

    Private:UpdateMissingRaidBuffs()

    Private.MissingBuffFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Private.MissingBuffFrame:SetSize(1, 1)
    Private.MissingBuffFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 175.1)

end

function Private:UpdateMissingRaidBuffs()
    if Private.DB.global.QualityOfLife.Toggles.MissingRaidBuffs then
        Private.MissingBuffFrame:RegisterUnitEvent("UNIT_AURA", "player")
        Private.MissingBuffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.MissingBuffFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Private.MissingBuffFrame:RegisterEvent("GROUP_JOINED")
        Private.MissingBuffFrame:SetScript("OnEvent", function(_, event) if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "GROUP_JOINED" then FetchGroupMemberClasses() end CheckForMissingBuffs() end)
    else
        Private.MissingBuffFrame:UnregisterAllEvents()
        Private.MissingBuffFrame:SetScript("OnEvent", nil)
    end
end
