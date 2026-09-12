local Private = select(2, ...)

local MissingRaidBuffs = {}
local ClassesInGroup = {}

local function CreateMissingRaidBuff(auraID)
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

local function HideMissingRaidBuff(auraID)
    if MissingRaidBuffs[auraID] then
        MissingRaidBuffs[auraID]:Hide()
        MissingRaidBuffs[auraID] = nil
    end
end

local function LayoutMissingRaidBuffs()
    local Frames = {}
    for _, BuffFrame in pairs(MissingRaidBuffs) do
        Frames[#Frames + 1] = BuffFrame
    end

    local Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, math.max(#Frames, 1), 1, 0)
    local Anchor = AnchorUtil.CreateAnchor("LEFT", Private.MissingRaidBuffFrame, "LEFT", 0, 0)
    AnchorUtil.GridLayout(Frames, Anchor, Layout)

    Private.MissingRaidBuffFrame:SetSize(#Frames * 50, 48)
    Private.MissingRaidBuffFrame:ClearAllPoints()
    Private.MissingRaidBuffFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 175.1)
    Private.MissingRaidBuffFrame:Show()
end

local function CheckForMissingRaidBuffs()
    for auraID, auraInfo in pairs(Private.RaidBuffs) do
        local hasAura = false

        for _, spellID in ipairs(auraInfo.spellIDs) do
            if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then hasAura = true break end
        end

        if not hasAura and ClassesInGroup[auraInfo.requiredClass] then
            MissingRaidBuffs[auraID] = MissingRaidBuffs[auraID] or CreateMissingRaidBuff(auraID)
        elseif MissingRaidBuffs[auraID] then
            HideMissingRaidBuff(auraID)
        end
    end

    LayoutMissingRaidBuffs()
end

local function FetchGroupMemberClasses()
    wipe(ClassesInGroup)

    local _, playerClass = UnitClass("player")
    if not issecretvalue(playerClass) and playerClass then ClassesInGroup[playerClass] = true end

    local inRaid = IsInRaid()
    local numGroupMembers = inRaid and GetNumGroupMembers() or GetNumSubgroupMembers()
    for i = 1, numGroupMembers do
        local unit = (inRaid and "raid" or "party") .. i
        if UnitExists(unit) then
            local _, unitClass = UnitClass(unit)
            if not issecretvalue(unitClass) and unitClass then ClassesInGroup[unitClass] = true end
        end
    end
end

function Private:SetupMissingRaidBuffs()
    Private.MissingRaidBuffFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Private.MissingRaidBuffFrame:SetSize(1, 1)
    Private.MissingRaidBuffFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 175.1)

    Private:UpdateMissingRaidBuffs()
end

function Private:UpdateMissingRaidBuffs()
    if Private.DB.global.QualityOfLife.Toggles.MissingRaidBuffs then
        Private.MissingRaidBuffFrame:RegisterUnitEvent("UNIT_AURA", "player")
        Private.MissingRaidBuffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Private.MissingRaidBuffFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Private.MissingRaidBuffFrame:RegisterEvent("GROUP_JOINED")
        Private.MissingRaidBuffFrame:RegisterEvent("UNIT_NAME_UPDATE")
        Private.MissingRaidBuffFrame:SetScript("OnEvent", function(_, event, unit)
            if event == "UNIT_NAME_UPDATE" then
                if issecretvalue(unit) or not (unit == "player" or unit:match("^party%d+$") or unit:match("^raid%d+$")) then return end
            end
            if event ~= "UNIT_AURA" then FetchGroupMemberClasses() end
            CheckForMissingRaidBuffs()
        end)
        FetchGroupMemberClasses()
        CheckForMissingRaidBuffs()
    else
        Private.MissingRaidBuffFrame:UnregisterAllEvents()
        Private.MissingRaidBuffFrame:SetScript("OnEvent", nil)
        for auraID in pairs(MissingRaidBuffs) do HideMissingRaidBuff(auraID) end
        Private.MissingRaidBuffFrame:Hide()
    end
end
