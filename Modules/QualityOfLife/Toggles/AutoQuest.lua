local Private = select(2, ...)

local function AutoQuestFrame_OnEvent(_, event)
    if not Private.DB.global.QualityOfLife.Toggles.AutoQuest or IsShiftKeyDown() or InCombatLockdown() then return end

    -- Select one quest at a time, then continue when the NPC's quest list returns.
    if event == "GOSSIP_SHOW" then
        for _, Quest in ipairs(C_GossipInfo.GetActiveQuests()) do
            if Quest.isComplete then
                C_GossipInfo.SelectActiveQuest(Quest.questID)
                return
            end
        end
        for _, Quest in ipairs(C_GossipInfo.GetAvailableQuests()) do
            if not Quest.isIgnored then
                C_GossipInfo.SelectAvailableQuest(Quest.questID)
                return
            end
        end
    elseif event == "QUEST_GREETING" then
        for Index = 1, GetNumActiveQuests() do
            local _, IsComplete = GetActiveTitle(Index)
            if IsComplete then
                SelectActiveQuest(Index)
                return
            end
        end
        for Index = 1, GetNumAvailableQuests() do
            local _, _, _, IsIgnored = GetAvailableQuestInfo(Index)
            if not IsIgnored then
                SelectAvailableQuest(Index)
                return
            end
        end
    elseif event == "QUEST_DETAIL" then
        if QuestGetAutoAccept() then
            AcknowledgeAutoAcceptQuest()
        else
            AcceptQuest()
        end
    elseif event == "QUEST_PROGRESS" then
        if IsQuestCompletable() then CompleteQuest() end
    elseif event == "QUEST_COMPLETE" then
        -- Fixed item rewards and item choices both require a manual turn-in.
        if GetNumQuestRewards() > 0 then return end
        local Choices = GetNumQuestChoices()
        for Index = 1, Choices do
            if GetQuestItemInfoLootType("choice", Index) == 0 then return end -- LOOT_LIST_ITEM
        end
        GetQuestReward(Choices > 0 and 1 or 0)
    end
end

function Private:SetupAutoQuest()
    if not Private.AutoQuestFrame then Private.AutoQuestFrame = CreateFrame("Frame") end

    local Frame = Private.AutoQuestFrame
    if Private.DB.global.QualityOfLife.Toggles.AutoQuest then
        Frame:RegisterEvent("GOSSIP_SHOW")
        Frame:RegisterEvent("QUEST_GREETING")
        Frame:RegisterEvent("QUEST_DETAIL")
        Frame:RegisterEvent("QUEST_PROGRESS")
        Frame:RegisterEvent("QUEST_COMPLETE")
        Frame:SetScript("OnEvent", AutoQuestFrame_OnEvent)
    else
        Frame:UnregisterAllEvents()
        Frame:SetScript("OnEvent", nil)
    end
end
