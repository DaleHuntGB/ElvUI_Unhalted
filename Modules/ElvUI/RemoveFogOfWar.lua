local Private = select(2, ...)
local ExploredOverlays = {}

local function RevealOverlays(Pin)
    local Pool = Private.FogOfWarPool
    Pool:ReleaseAll()

    local Map = Pin:GetMap()
    local MapID = Map:GetMapID()
    if Private:IsSecret(MapID) or not MapID then return end
    local Overlays = Private.FogOfWarOverlays[C_Map.GetMapArtID(MapID)]
    if not Overlays then return end

    wipe(ExploredOverlays)
    local Explored = C_MapExplorationInfo.GetExploredMapTextures(MapID)
    if Explored then
        for _, Info in ipairs(Explored) do
            local FileDataID = Info.fileDataIDs[1]
            if FileDataID then ExploredOverlays[FileDataID] = true end
        end
    end

    local Layer = C_Map.GetMapArtLayers(MapID)[Map:GetCanvasContainer():GetCurrentLayerIndex()]
    local TileWidth, TileHeight = Layer.tileWidth, Layer.tileHeight

    for _, Overlay in ipairs(Overlays) do
        if not ExploredOverlays[Overlay[5]] then
            local Width, Height, OffsetX, OffsetY = Overlay[1], Overlay[2], Overlay[3], Overlay[4]
            local Columns, Rows = math.ceil(Width / TileWidth), math.ceil(Height / TileHeight)
            for Row = 1, Rows do
                local PixelHeight, FileHeight = Private:GetOverlayTileSize(Row, Rows, Height, TileHeight)
                for Column = 1, Columns do
                    local PixelWidth, FileWidth = Private:GetOverlayTileSize(Column, Columns, Width, TileWidth)
                    local Texture = Pool:Acquire()
                    Texture:SetSize(PixelWidth, PixelHeight)
                    Texture:SetTexCoord(0, PixelWidth / FileWidth, 0, PixelHeight / FileHeight)
                    Texture:SetPoint("TOPLEFT", OffsetX + TileWidth * (Column - 1), -(OffsetY + TileHeight * (Row - 1)))
                    Texture:SetTexture(Overlay[4 + (Row - 1) * Columns + Column], nil, nil, "TRILINEAR")
                    Texture:SetDesaturated(true)
                    Texture:Show()
                end
            end
        end
    end
end

function Private:SetupRemoveFogOfWar()
    if not Private.DB.global.ElvUI.RemoveFogOfWar then return end

    Private.FogOfWarOverlays = Private:UnpackData(Private.isForever and "FogOfWar_Forever" or "FogOfWar_Retail")
    for Pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
        Private.FogOfWarPool = CreateUnsecuredTexturePool(Pin, Pin.dataProvider:GetDrawLayer())
        hooksecurefunc(Pin, "RefreshOverlays", RevealOverlays)
    end
end
