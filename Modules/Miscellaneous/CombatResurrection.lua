local Private = select(2, ...)

local function CombatResurrection_OnUpdate(Frame, TimeElapsed)
    Frame.TimeSinceLastUpdate = Frame.TimeSinceLastUpdate + TimeElapsed
    if Frame.TimeSinceLastUpdate < 1 then return end
    Frame.TimeSinceLastUpdate = Frame.TimeSinceLastUpdate % 1

    local ChargeInfo;
    if Frame.InEncounter or Frame.InChallenge then ChargeInfo = C_Spell.GetSpellCharges(20484) end
    local Charges, Remaining = 0, 0
    if ChargeInfo then
        Charges = ChargeInfo.currentCharges
        local ChargeDuration = C_Spell.GetSpellChargeDuration(20484)
        if ChargeDuration and not ChargeDuration:HasSecretValues() then
            Remaining = math.max(0, math.ceil(ChargeDuration:GetRemainingDuration()))
        end
    end

    local Time = string.format("%02d:%02d", math.floor(Remaining / 60), Remaining % 60)
    local ChargeColour = Frame.ChargesCurve:Evaluate(Charges)
    Frame.Text:SetFormattedText(Frame.Format, ChargeColour:GenerateHexColor(), Charges, Time)

    local Width, Height = Frame.Text:GetStringWidth(), Frame.Text:GetStringHeight()
    if not Private:SecretValue(Width) and not Private:SecretValue(Height) then Frame:SetSize(Width, Height) end
end

local function CombatResurrection_OnEvent(Frame, Event)
    local DB = Private.DB.global.Miscellaneous.CombatResurrection
    if not DB.Enable then return end

    if Event == "ENCOUNTER_START" then
        Frame.InEncounter = true
    elseif Event == "ENCOUNTER_END" then
        Frame.InEncounter = false
    elseif Event == "CHALLENGE_MODE_START" then
        Frame.InChallenge = true
    elseif Event == "CHALLENGE_MODE_RESET" or Event == "CHALLENGE_MODE_COMPLETED" then
        Frame.InChallenge = false
    elseif Event == "PLAYER_ENTERING_WORLD" or Event == "ZONE_CHANGED_NEW_AREA" or Event == "PLAYER_DIFFICULTY_CHANGED" then
        Frame.InEncounter = C_InstanceEncounter.IsEncounterInProgress()
        Frame.InChallenge = not Private.isForever and C_ChallengeMode.IsChallengeModeActive()
        Frame:ClearAllPoints()
        Frame:SetPoint(DB.Layout[1], _G[DB.AnchorParent] or UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    local Active = (Frame.InEncounter or Frame.InChallenge) and GetNumGroupMembers() > 1
    local Shown = Private.CombatResurrectionPreview or Active
    Frame:SetShown(Shown)
    Frame:SetScript("OnUpdate", Active and CombatResurrection_OnUpdate or nil)
    Frame.TimeSinceLastUpdate = 0
    if Shown then CombatResurrection_OnUpdate(Frame, 1) end
end

function Private:SetupCombatResurrection()
    local DB = Private.DB.global.Miscellaneous.CombatResurrection

    if not Private.CombatResurrectionFrame then
        local Frame = CreateFrame("Frame", "CombatResurrectionFrame", UIParent)
        Frame:SetSize(1, 1)
        Frame:Hide()
        Frame.Text = Frame:CreateFontString(nil, "OVERLAY")
        Frame.Text:SetWordWrap(false)
        Private.CombatResurrectionFrame = Frame
    end

    local Frame = Private.CombatResurrectionFrame
    Frame.TimeSinceLastUpdate = 0
    Frame.InEncounter, Frame.InChallenge = false, false

    DB.Text.Format = DB.Text.Format:gsub("%%d", "%%s")
    Frame.Format = DB.Text.Format:gsub("%%s", "|c%%s%%s|r", 1)
    Frame.ChargesCurve = Frame.ChargesCurve or C_CurveUtil.CreateColorCurve()
    Frame.ChargesCurve:SetType(Enum.LuaCurveType.Step)
    Frame.ChargesCurve:ClearPoints()
    Frame.ChargesCurve:AddPoint(0, CreateColor(unpack(DB.Text.Charges[2])))
    Frame.ChargesCurve:AddPoint(1, CreateColor(unpack(DB.Text.Charges[1])))
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], _G[DB.AnchorParent] or UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])

    Private.E:SetFont(Frame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
    Frame.Text:ClearAllPoints()
    Frame.Text:SetPoint(DB.Layout[1], Frame, DB.Layout[1], 0, 0)
    Frame.Text:SetJustifyH(Private.JustificationH[DB.Layout[1]])
    Frame.Text:SetTextColor(DB.Text.Colour[1], DB.Text.Colour[2], DB.Text.Colour[3], DB.Text.Colour[4] or 1)
    Frame.Text:SetFormattedText(Frame.Format, Frame.ChargesCurve:Evaluate(0):GenerateHexColor(), 0, "00:00")
    Frame:SetSize(Frame.Text:GetStringWidth(), Frame.Text:GetStringHeight())

    if DB.Enable then
        Frame:RegisterEvent("ENCOUNTER_START")
        Frame:RegisterEvent("ENCOUNTER_END")
        Frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        Frame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
        if not Private.isForever then
            Frame:RegisterEvent("CHALLENGE_MODE_START")
            Frame:RegisterEvent("CHALLENGE_MODE_RESET")
            Frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        end
        Frame:SetScript("OnEvent", CombatResurrection_OnEvent)
    end
end

function Private:UpdateCombatResurrection()
    local DB = Private.DB.global.Miscellaneous.CombatResurrection
    local Frame = Private.CombatResurrectionFrame
    if not Frame then return end

    DB.Text.Format = DB.Text.Format:gsub("%%d", "%%s")
    Frame.Format = DB.Text.Format:gsub("%%s", "|c%%s%%s|r", 1)
    Frame.ChargesCurve = Frame.ChargesCurve or C_CurveUtil.CreateColorCurve()
    Frame.ChargesCurve:SetType(Enum.LuaCurveType.Step)
    Frame.ChargesCurve:ClearPoints()
    Frame.ChargesCurve:AddPoint(0, CreateColor(unpack(DB.Text.Charges[2])))
    Frame.ChargesCurve:AddPoint(1, CreateColor(unpack(DB.Text.Charges[1])))
    Frame:ClearAllPoints()
    Frame:SetPoint(DB.Layout[1], _G[DB.AnchorParent] or UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])

    Private.E:SetFont(Frame.Text, Private:FetchFont(Private.E.db.general.font), DB.Text.FontSize, Private.E.db.general.fontStyle)
    Frame.Text:ClearAllPoints()
    Frame.Text:SetPoint(DB.Layout[1], Frame, DB.Layout[1], 0, 0)
    Frame.Text:SetJustifyH(Private.JustificationH[DB.Layout[1]])
    Frame.Text:SetTextColor(DB.Text.Colour[1], DB.Text.Colour[2], DB.Text.Colour[3], DB.Text.Colour[4] or 1)

    local Active = (Frame.InEncounter or Frame.InChallenge) and GetNumGroupMembers() > 1
    local Shown = DB.Enable and (Private.CombatResurrectionPreview or Active)
    Frame:SetShown(Shown)
    if Shown then
        Frame.TimeSinceLastUpdate = 0
        CombatResurrection_OnUpdate(Frame, 1)
    end

    if DB.Enable then
        Frame:RegisterEvent("ENCOUNTER_START")
        Frame:RegisterEvent("ENCOUNTER_END")
        Frame:RegisterEvent("GROUP_ROSTER_UPDATE")
        Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        Frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        Frame:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
        if not Private.isForever then
            Frame:RegisterEvent("CHALLENGE_MODE_START")
            Frame:RegisterEvent("CHALLENGE_MODE_RESET")
            Frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        end
        Frame:SetScript("OnEvent", CombatResurrection_OnEvent)
    else
        Frame:UnregisterEvent("ENCOUNTER_START")
        Frame:UnregisterEvent("ENCOUNTER_END")
        Frame:UnregisterEvent("GROUP_ROSTER_UPDATE")
        Frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        Frame:UnregisterEvent("PLAYER_DIFFICULTY_CHANGED")
        if not Private.isForever then
            Frame:UnregisterEvent("CHALLENGE_MODE_START")
            Frame:UnregisterEvent("CHALLENGE_MODE_RESET")
            Frame:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        end
        Frame:SetScript("OnEvent", nil)
        Frame:SetScript("OnUpdate", nil)
        Frame.InEncounter, Frame.InChallenge = false, false
        Frame.TimeSinceLastUpdate = 0
        Frame:Hide()
    end
end
