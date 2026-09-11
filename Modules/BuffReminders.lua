local Private = select(2, ...)

local BuffReminders = {}
local ClassesInGroup = {}

local function CreateBuffReminder(auraID)
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

    Frame:Show()

    return Frame
end

local function HideBuffReminder(auraID)
    if BuffReminders[auraID] then
        BuffReminders[auraID]:Hide()
        BuffReminders[auraID] = nil
    end
end

local function LayoutBuffReminders()
    local Frames = {}
    for _, BuffFrame in pairs(BuffReminders) do
        Frames[#Frames + 1] = BuffFrame
    end

    local Layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, math.max(#Frames, 1), 1, 0)
    local Anchor = AnchorUtil.CreateAnchor("LEFT", Private.BuffReminderContainerFrame, "LEFT", 0, 0)
    AnchorUtil.GridLayout(Frames, Anchor, Layout)

    Private.BuffReminderContainerFrame:SetSize(#Frames * 50, 48)
    Private.BuffReminderContainerFrame:ClearAllPoints()
    Private.BuffReminderContainerFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 175.1)
    Private.BuffReminderContainerFrame:Show()
end

local function CheckForMissingBuffs()
    for auraID, auraInfo in pairs(Private.RaidBuffs) do
        local hasAura = false

        for _, spellID in ipairs(auraInfo.spellIDs) do
            if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then hasAura = true break end
        end

        if not hasAura and ClassesInGroup[auraInfo.requiredClass] then
            BuffReminders[auraID] = BuffReminders[auraID] or CreateBuffReminder(auraID)
        elseif BuffReminders[auraID] then
            HideBuffReminder(auraID)
        end
    end

    LayoutBuffReminders()
end

local function FetchGroupMemberClasses()
    wipe(ClassesInGroup)

    if not IsInGroup() then return end

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

function Private:SetupBuffReminders()
    local EventFrame = CreateFrame("Frame")
    EventFrame:RegisterUnitEvent("UNIT_AURA", "player")
    EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("GROUP_JOINED")
    EventFrame:SetScript("OnEvent", function(_, event) if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "GROUP_JOINED" then FetchGroupMemberClasses() end CheckForMissingBuffs() end)

    Private.BuffReminderContainerFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Private.BuffReminderContainerFrame:SetSize(1, 1)
    Private.BuffReminderContainerFrame:SetPoint("CENTER", UIParent, "CENTER", -0.1, 175.1)
end
