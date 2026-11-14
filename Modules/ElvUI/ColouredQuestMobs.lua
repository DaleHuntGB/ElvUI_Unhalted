local Private = select(2, ...)
local NP = Private.E:GetModule("NamePlates")
local LineType = Enum.TooltipDataLineType
local RescanDelay = 0.2
local QuestMobs = {}
local HookedHealth = {}
local isRescanQueued = false

local function ScanQuestMob(Unit)
    if IsInInstance() or UnitIsPlayer(Unit) or C_Secrets.ShouldUnitIdentityBeSecret(Unit) then return false end

    local Info = C_TooltipInfo.GetUnit(Unit)
    if not Info then return false end

    local IsOtherPlayer = false
    for _, Line in ipairs(Info.lines) do
        if Line.type == LineType.QuestTitle then
            IsOtherPlayer = false
        elseif Line.type == LineType.QuestPlayer then
            IsOtherPlayer = issecretvalue(Line.leftText) or Line.leftText ~= Private.E.myname
        elseif Line.type == LineType.QuestObjective and not IsOtherPlayer and not issecretvalue(Line.completed) and not Line.completed then
            return true
        end
    end

    return false
end

local function IsQuestMob(Unit)
    local IsQuest = QuestMobs[Unit]
    if IsQuest == nil then
        IsQuest = ScanQuestMob(Unit)
        QuestMobs[Unit] = IsQuest
    end
    return IsQuest
end

local function ColourQuestMob(Frame, _, Unit)
    local DB = Private.DB.global.ElvUI.ColouredQuestMobs
    if not DB.Enable or Frame.__unit ~= Unit or not IsQuestMob(Unit) or UnitIsTapDenied(Unit) then return end

    NP:SetStatusBarColor(Frame.Health, DB.Colour[1], DB.Colour[2], DB.Colour[3])
end

local function HookHealth(_, Nameplate)
    local Health = Nameplate.Health
    if not Health or HookedHealth[Health] then return end
    HookedHealth[Health] = true
    hooksecurefunc(Health, "UpdateColor", ColourQuestMob)
end

local function RefreshQuestMobs()
    wipe(QuestMobs)
    for Plate in pairs(NP.Plates) do
        if Plate:IsVisible() and Plate:IsElementEnabled("Health") then Plate.Health:ForceUpdate() end
    end
end

local function RescanQuestMobs()
    isRescanQueued = false
    for Plate in pairs(NP.Plates) do
        local Unit = Plate.__unit
        if Unit then
            if Plate:IsVisible() and Plate:IsElementEnabled("Health") then
                local wasQuestMob = QuestMobs[Unit] == true
                QuestMobs[Unit] = ScanQuestMob(Unit)
                if QuestMobs[Unit] ~= wasQuestMob then Plate.Health:ForceUpdate() end
            else
                QuestMobs[Unit] = nil
            end
        end
    end
end

local function OnEvent(_, Event, Unit)
    if Event == "NAME_PLATE_UNIT_REMOVED" then
        QuestMobs[Unit] = nil
    elseif not isRescanQueued then
        isRescanQueued = true
        C_Timer.After(RescanDelay, RescanQuestMobs)
    end
end

function Private:SetupColouredQuestMobs()
    if not NP.Initialized then return end

    local EventFrame = CreateFrame("Frame")
    EventFrame:SetScript("OnEvent", OnEvent)
    Private.ColouredQuestMobsEventFrame = EventFrame

    hooksecurefunc(NP, "Update_Health", HookHealth)
    for Plate in pairs(NP.Plates) do HookHealth(nil, Plate) end

    Private:UpdateColouredQuestMobs()
end

function Private:UpdateColouredQuestMobs()
    local EventFrame = Private.ColouredQuestMobsEventFrame
    if not EventFrame then return end

    if Private.DB.global.ElvUI.ColouredQuestMobs.Enable then
        EventFrame:RegisterEvent("QUEST_LOG_UPDATE")
        EventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    else
        EventFrame:UnregisterAllEvents()
    end

    RefreshQuestMobs()
end
