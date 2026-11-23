local Private = select(2, ...)

local JournalDungeons = {}

local function OpenDungeon(Dungeon)
    Private.DungeonJournal:Show()
    Private.DungeonJournal:SelectDungeon(Dungeon)
end

local function CreateDungeonMenu(Icon, RootDescription)
    for _, Dungeon in ipairs(Icon.Portal.Dungeons) do RootDescription:CreateButton(Dungeon.Name, OpenDungeon, Dungeon) end
end

local function PortalIcon_OnClick(Icon)
    local Dungeons = Icon.Portal.Dungeons
    if #Dungeons == 1 then OpenDungeon(Dungeons[1]) return end
    MenuUtil.CreateContextMenu(Icon, CreateDungeonMenu)
end

local function PortalIcon_OnEnter(Icon)
    GameTooltip:SetOwner(Icon, "ANCHOR_RIGHT")
    local PlayerLevel = UnitLevel("player")
    for Index = 4, #Icon.Portal do
        local Name = Icon.Portal[Index]
        local Dungeon = JournalDungeons[Name]
        if Dungeon and not Dungeon.Raid then
            local Levels = Dungeon.Levels
            local Colour = GetQuestDifficultyColor(math.min(math.max(PlayerLevel, Levels[1]), Levels[2]))
            GameTooltip:AddDoubleLine(Name, string.format("Level %d-%d", Levels[1], Levels[2]), 1, 1, 1, Colour.r, Colour.g, Colour.b)
        else
            GameTooltip:AddDoubleLine(Name, RAID, 1, 1, 1, NORMAL_FONT_COLOR:GetRGB())
        end
    end
    if #Icon.Portal.Dungeons > 0 then GameTooltip_AddInstructionLine(GameTooltip, "Click to open in the Dungeon Journal.") end
    GameTooltip:Show()
end

function Private:UpdateInstancePortals()
    local Pool = Private.InstancePortalIcons
    Pool:ReleaseAll()

    local DB = Private.DB.global.Miscellaneous.Navigation
    if not DB.Enable or not DB.InstancePortals.Enable or not WorldMapFrame:IsShown() then return end
    local MapID = WorldMapFrame:GetMapID()
    if not MapID then return end

    local Overlay = Private.InstancePortalOverlay
    local Width, Height = Overlay:GetWidth(), Overlay:GetHeight()
    local IconSize = Private.DB.global.Miscellaneous.Navigation.InstancePortals.IconSize / WorldMapFrame:GetCanvas():GetScale()
    for _, Portal in ipairs(Private.InstancePortals) do
        local Position = Portal.Positions[MapID]
        if Position then
            local Icon = Pool:Acquire()
            if not Icon.Texture then
                Icon.Texture = Icon:CreateTexture(nil, "OVERLAY")
                Icon.Texture:SetAllPoints(Icon)
                Icon:SetScript("OnClick", PortalIcon_OnClick)
                Icon:SetScript("OnEnter", PortalIcon_OnEnter)
                Icon:SetScript("OnLeave", GameTooltip_Hide)
            end
            Icon.Portal = Portal
            Icon.Texture:SetAtlas(Portal.Atlas)
            Icon:SetMouseClickEnabled(#Portal.Dungeons > 0)
            Icon:SetSize(IconSize, IconSize)
            Icon:SetPoint("CENTER", Overlay, "TOPLEFT", Position[1] * Width, -Position[2] * Height)
            Icon:Show()
        end
    end
end

local function ResizeInstancePortals()
    local IconSize = Private.DB.global.Miscellaneous.Navigation.InstancePortals.IconSize / WorldMapFrame:GetCanvas():GetScale()
    for Icon in Private.InstancePortalIcons:EnumerateActive() do Icon:SetSize(IconSize, IconSize) end
end

function Private:SetupInstancePortals()
    for _, Dungeon in ipairs(Private.DungeonJournalData) do JournalDungeons[Dungeon.Name] = Dungeon end
    for _, Portal in ipairs(Private.InstancePortals) do
        local ZoneMapID, X, Y = Portal[1], Portal[2] / 100, Portal[3] / 100
        local ContinentMapID = C_Map.GetMapInfo(ZoneMapID).parentMapID
        local Left, Right, Top, Bottom = C_Map.GetMapRectOnMap(ZoneMapID, ContinentMapID)
        Portal.Positions = { [ZoneMapID] = { X, Y }, [ContinentMapID] = { Left + X * (Right - Left), Top + Y * (Bottom - Top) } }
        Portal.Dungeons = {}
        Portal.Atlas = "Raid"
        for Index = 4, #Portal do
            local Dungeon = JournalDungeons[Portal[Index]]
            if Dungeon then
                Portal.Dungeons[#Portal.Dungeons + 1] = Dungeon
                if not Dungeon.Raid then Portal.Atlas = "Dungeon" end
            end
        end
    end

    local Canvas = WorldMapFrame:GetCanvas()
    local Overlay = CreateFrame("Frame", nil, Canvas)
    Overlay:SetAllPoints(Canvas)
    Overlay:SetFrameLevel(WorldMapFrame:GetPinFrameLevelsManager():GetValidFrameLevel("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE"))
    Private.InstancePortalOverlay = Overlay
    Private.InstancePortalIcons = CreateUnsecuredFramePool("Button", Overlay)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", Private.UpdateInstancePortals)
    hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ResizeInstancePortals)
    WorldMapFrame:HookScript("OnShow", Private.UpdateInstancePortals)
end
