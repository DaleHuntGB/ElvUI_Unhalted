local Private = select(2, ...)

local RefreshEvents = { "QUEST_LOG_UPDATE", "SUPER_TRACKING_CHANGED" }
local KillPathColour, TalkPathColour = { 1, 0.35, 0.29 }, { 1, 0.82, 0 }

local QuestieDB = Private:GetQuestieDB()
local Placed, DrawnPaths = {}, {}
local IconSize = 0
local isRefreshQueued = false

local function SizeIcon(Icon, Size)
    Icon:SetSize(Size, Size)
    Icon.Mask:SetSize(Size * 0.8, Size * 0.8)
    Icon.Badge:SetSize(Size * 0.8, Size * 0.8)
end

local function AddSource(Icon, Name, Rate)
    if not Name then return end
    for Index = 1, #Icon.Sources do
        if Icon.Sources[Index] == Name then
            Icon.Rates[Index] = math.max(Icon.Rates[Index], Rate)
            return
        end
    end
    Icon.Sources[#Icon.Sources + 1] = Name
    Icon.Rates[#Icon.Rates + 1] = Rate
end

local function ObjectiveIcon_OnEnter(Icon)
    GameTooltip:SetOwner(Icon, "ANCHOR_RIGHT")
    local Colour = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(Icon.QuestID))
    GameTooltip:SetText(C_QuestLog.GetTitleForQuestID(Icon.QuestID) or "", Colour.r, Colour.g, Colour.b)
    local Objective = C_QuestLog.GetQuestObjectives(Icon.QuestID)[Icon.Index]
    if Objective then GameTooltip:AddLine(Objective.text, 1, 1, 1, true) end
    for Index = 1, #Icon.Sources do
        local Rate = Icon.Rates[Index]
        if Rate > 0 then
            GameTooltip:AddDoubleLine(Icon.Sources[Index], Rate .. "%", 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine(Icon.Sources[Index], 0.7, 0.7, 0.7)
        end
    end
    GameTooltip:Show()
end

local function DrawPaths(NpcID, Npc, MapID)
    local Paths = Npc[4][MapID]
    if not Paths or DrawnPaths[NpcID] or not Private.DB.global.Miscellaneous.Navigation.QuestObjectives.PatrolPaths then return end
    DrawnPaths[NpcID] = true

    local Overlay = Private.QuestObjectiveOverlay
    local Width, Height = Overlay:GetWidth(), Overlay:GetHeight()
    local Colour = Npc[3] and TalkPathColour or KillPathColour
    for _, Path in ipairs(Paths) do
        for Point = 3, #Path, 2 do
            local Line = Private.QuestObjectivePaths:Acquire()
            Line:SetStartPoint("TOPLEFT", Overlay, Path[Point - 2] / 100 * Width, -Path[Point - 1] / 100 * Height)
            Line:SetEndPoint("TOPLEFT", Overlay, Path[Point] / 100 * Width, -Path[Point + 1] / 100 * Height)
            Line:SetThickness(2)
            Line:SetColorTexture(Colour[1], Colour[2], Colour[3], 0.75)
            Line:Show()
        end
    end
end

local function PlaceIcons(Points, Texture, QuestID, Index, Name, Rate)
    if not Points then return end
    local Overlay = Private.QuestObjectiveOverlay
    local Width, Height = Overlay:GetWidth(), Overlay:GetHeight()
    local isSymbol = type(Texture) == "string"
    for Point = 1, #Points, 2 do
        local X, Y = Points[Point], Points[Point + 1]
        local Merged = false
        for Other = 1, #Placed do
            local Icon = Placed[Other]
            local DeltaX, DeltaY = (Icon.X - X) * 10.02, (Icon.Y - Y) * 6.68
            if DeltaX * DeltaX + DeltaY * DeltaY <= 625 then
                AddSource(Icon, Name, Rate)
                Merged = true
                break
            end
        end
        if not Merged then
            local Icon = Private.QuestObjectiveIcons:Acquire()
            if not Icon.Badge then
                Icon.Mask = Icon:CreateMaskTexture()
                Icon.Mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                Icon.Mask:SetPoint("CENTER")
                Icon.Badge = Icon:CreateTexture(nil, "ARTWORK")
                Icon.Badge:SetPoint("CENTER")
                Icon.Badge:AddMaskTexture(Icon.Mask)
                Icon.Ring = Icon:CreateTexture(nil, "OVERLAY")
                Icon.Ring:SetAtlas("Garr_FollowerPortrait_Ring")
                Icon.Ring:SetAllPoints(Icon)
                Icon.Symbol = Icon:CreateTexture(nil, "ARTWORK")
                Icon.Symbol:SetAllPoints(Icon)
                Icon.Sources, Icon.Rates = {}, {}
                Icon:EnableMouseMotion(true)
                Icon:SetScript("OnEnter", ObjectiveIcon_OnEnter)
                Icon:SetScript("OnLeave", GameTooltip_Hide)
            end
            wipe(Icon.Sources)
            wipe(Icon.Rates)
            Icon.X, Icon.Y, Icon.QuestID, Icon.Index = X, Y, QuestID, Index
            AddSource(Icon, Name, Rate)
            Icon.Symbol:SetShown(isSymbol)
            Icon.Badge:SetShown(not isSymbol)
            Icon.Ring:SetShown(not isSymbol)
            if isSymbol then
                Icon.Symbol:SetAtlas(Texture)
            else
                Icon.Badge:SetTexture(Texture)
                Icon.Badge:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
            SizeIcon(Icon, IconSize)
            Icon:SetPoint("CENTER", Overlay, "TOPLEFT", X / 100 * Width, -Y / 100 * Height)
            Icon:Show()
            Placed[#Placed + 1] = Icon
        end
    end
end

local function DrawQuestObjectives()
    Private.QuestObjectiveIcons:ReleaseAll()
    Private.QuestObjectivePaths:ReleaseAll()
    wipe(DrawnPaths)
    if not Private.DB.global.Miscellaneous.Navigation.Enable or not WorldMapFrame:IsShown() then return end

    local MapID = WorldMapFrame:GetMapID()
    if not MapID then return end

    local QuestID = C_SuperTrack.GetSuperTrackedQuestID()
    local Entries = QuestID and QuestID > 0 and Private:GetQuestieObjectives(QuestID)
    if not Entries then return end

    IconSize = Private.DB.global.Miscellaneous.Navigation.QuestObjectives.IconSize / WorldMapFrame:GetCanvas():GetScale()
    for Index, Objective in ipairs(C_QuestLog.GetQuestObjectives(QuestID)) do
        local Entry = Entries[Index]
        if Entry and not Objective.finished then
            wipe(Placed)
            local Kind = Entry[1]
            if Kind == 3 then
                local Item = Private:GetQuestieItem(Entry[2])
                local Texture = C_Item.GetItemIconByID(Entry[2]) or 134400
                local DropSources = Item[1]
                for Source = 1, #DropSources, 2 do
                    local Npc = Private:GetQuestieNpc(DropSources[Source])
                    DrawPaths(DropSources[Source], Npc, MapID)
                    PlaceIcons(Npc[2][MapID], Texture, QuestID, Index, Npc[1], DropSources[Source + 1])
                end
                for _, ObjectID in ipairs(Item[2]) do
                    local Object = Private:GetQuestieObject(ObjectID)
                    PlaceIcons(Object[2][MapID], Texture, QuestID, Index, Object[1], 0)
                end
            elseif Kind == 4 then
                PlaceIcons(Entry[2][MapID], "xmarksthespot", QuestID, Index, nil, 0)
            elseif Kind == 1 then
                for Source = 2, #Entry do
                    local Npc = Private:GetQuestieNpc(Entry[Source])
                    DrawPaths(Entry[Source], Npc, MapID)
                    PlaceIcons(Npc[2][MapID], Npc[3] and "crosshair_speak_64" or "dungeonskull", QuestID, Index, Npc[1], 0)
                end
            elseif Kind == 2 then
                for Source = 2, #Entry do
                    local Object = Private:GetQuestieObject(Entry[Source])
                    PlaceIcons(Object[2][MapID], "mechagon-projects", QuestID, Index, Object[1], 0)
                end
            end
        end
    end
end

local function ResizeQuestObjectives()
    local Size = Private.DB.global.Miscellaneous.Navigation.QuestObjectives.IconSize / WorldMapFrame:GetCanvas():GetScale()
    for Icon in Private.QuestObjectiveIcons:EnumerateActive() do SizeIcon(Icon, Size) end
end

local function RefreshQuestObjectives()
    isRefreshQueued = false
    DrawQuestObjectives()
end

local function OnEvent()
    if isRefreshQueued then return end
    isRefreshQueued = true
    C_Timer.After(0.2, RefreshQuestObjectives)
end

local function WorldMap_OnShow()
    if not Private.DB.global.Miscellaneous.Navigation.Enable then return end
    for _, Event in ipairs(RefreshEvents) do Private.QuestObjectiveOverlay:RegisterEvent(Event) end
    DrawQuestObjectives()
end

local function WorldMap_OnHide()
    Private.QuestObjectiveOverlay:UnregisterAllEvents()
end

function Private:SetupQuestObjectives()
    if not Private.DB.global.Miscellaneous.Navigation.QuestObjectives.Enable or not QuestieDB then return end

    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_DIG_SITE"))
    Overlay:SetScript("OnEvent", OnEvent)
    Private.QuestObjectiveOverlay = Overlay
    Private.QuestObjectiveIcons = CreateUnsecuredFramePool("Frame", Overlay)
    Private.QuestObjectivePaths = CreateUnsecuredRegionPoolInstance(nil, function() return Overlay:CreateLine(nil, "ARTWORK") end)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", DrawQuestObjectives)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeQuestObjectives)
    WorldMapFrame:HookScript("OnShow", WorldMap_OnShow)
    WorldMapFrame:HookScript("OnHide", WorldMap_OnHide)
end

function Private:UpdateQuestObjectives()
    if Private.QuestObjectiveIcons then DrawQuestObjectives() end
end
