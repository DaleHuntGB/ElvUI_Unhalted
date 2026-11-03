local Private = select(2, ...)

function Private:RecordMythicPlusBoss(Frame, EncounterID, Name)
    local Run = Frame.Run
    if not Run or Run.Completed or Private:SecretValue(EncounterID) or not EncounterID then return end
    Private:ReadMythicPlusTime(Frame)
    Run.BossCompletions = Run.BossCompletions or {}
    if not Run.BossCompletions[EncounterID] then
        Run.BossCompletions[EncounterID] = {Name = Name, Time = Run.Elapsed}
    end
    local Completion = Run.BossCompletions[EncounterID]
    for _, Objective in ipairs(Run.Objectives) do
        if Objective.EncounterID == EncounterID then
            Objective.Name = Completion.Name
            Objective.CompletionTime = Completion.Time
            Objective.Complete = true
            Objective.Value = Objective.Maximum
        end
    end
end

function Private:ReadMythicPlusObjectives(Frame)
    local Step = C_ScenarioInfo.GetScenarioStepInfo()
    if not Step or Private:SecretValue(Step.numCriteria) then return end
    Private:ReadMythicPlusTime(Frame)
    local Run = Frame.Run
    local Previous = {}
    for _, Objective in ipairs(Run.Objectives) do Previous[Objective.ID] = Objective end
    local Objectives = {}
    for Index = 1, Step.numCriteria do
        local Info = C_ScenarioInfo.GetCriteriaInfo(Index)
        if Info and not Private:SecretValue(Info.isWeightedProgress) then
            local ID = Info.criteriaID
            if Private:SecretValue(ID) or not ID or ID == 0 then ID = Index end
            local Objective = Previous[ID] or {ID = ID}
            local EncounterID
            if not Private:SecretValue(Info.criteriaType) and Info.criteriaType == 165 and not Private:SecretValue(Info.assetID) then
                EncounterID = Info.assetID
            end
            Objective.EncounterID = EncounterID
            local Completion = EncounterID and Run.BossCompletions and Run.BossCompletions[EncounterID]
            Objective.Name = Info.description
            Objective.Value = Info.quantity
            Objective.Maximum = Info.isWeightedProgress and 100 or Info.totalQuantity
            Objective.Percent = Info.isWeightedProgress
            Objective.Complete = Completion ~= nil or (not Private:SecretValue(Info.completed) and Info.completed)
            if not Objective.Percent then
                if Completion then
                    Objective.Name = Completion.Name
                    Objective.CompletionTime = Completion.Time
                elseif not Private:SecretValue(Objective.Name) then
                    Objective.Name = Objective.Name:gsub("^Defeat%s+", ""):gsub("%s+defeated$", "")
                end
                if Objective.Complete then
                    if not Private:SecretValue(Objective.CompletionTime) and not Objective.CompletionTime and not Private:SecretValue(Run.Elapsed) and not Private:SecretValue(Info.elapsed) and Info.elapsed then
                        Objective.CompletionTime = math.max(0, Run.Elapsed - Info.elapsed)
                    end
                    Objective.Value = Objective.Maximum
                end
            end
            Objectives[#Objectives + 1] = Objective
        end
    end
    if #Objectives > 0 then Frame.Run.Objectives = Objectives end
end

function Private:RenderMythicPlusObjectives(Frame, Data, Index)
    local DB = Frame.MythicPlusDB
    for _, Objective in ipairs(Data.Objectives) do
        if (Objective.Percent and DB.ShowForces) or (not Objective.Percent and DB.ShowBosses) then
            local Row = Frame:GetRow(Index)
            local Colour = Objective.Complete and DB.Colours.Complete or DB.Colours.Progress
            local Maximum = Objective.Maximum
            if not Private:SecretValue(Maximum) and (not Maximum or Maximum <= 0) then Maximum = 1 end
            Row.StatusBar:SetMinMaxValues(0, Maximum)
            Row.StatusBar:SetValue(Objective.Value)
            Row.StatusBar:SetStatusBarColor(unpack(Colour))
            Row.Name_Text:SetText(Objective.Name)
            if Objective.Percent then
                Row.Amount_Text:SetFormattedText("%.1f%%", Objective.Value)
            elseif Objective.Complete and (Private:SecretValue(Objective.CompletionTime) or Objective.CompletionTime ~= nil) then
                if Private:SecretValue(Objective.CompletionTime) then
                    Row.Amount_Text:SetFormattedText("%.0fs", Objective.CompletionTime)
                else
                    Row.Amount_Text:SetText(SecondsToClock(Objective.CompletionTime))
                end
            else
                Row.Amount_Text:SetText("")
            end
            Row:Show()
            Index = Index + 1
        end
    end
    return Index
end
