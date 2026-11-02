local Private = select(2, ...)

local AtlasData = {
    [1] = "CENTER",
    [2] = "CENTER",
    [3] = 15,
    [4] = -14,
    [5] = 92
}

function Private:SetupMouseCursor()
    local DB = Private.DB.global.Miscellaneous.MouseCursor

    local MouseCursorFrame = CreateFrame("Frame", nil, UIParent)
    MouseCursorFrame:SetShown(DB.Enable)
    MouseCursorFrame:SetSize(DB.Size[1], DB.Size[2])
    MouseCursorFrame.Anchor = CreateFrame("Frame", nil, UIParent)
    MouseCursorFrame.Anchor:SetSize(DB.Size[1], DB.Size[2])

    MouseCursorFrame.Texture = MouseCursorFrame:CreateTexture(nil, "OVERLAY")
    MouseCursorFrame.Texture:SetAllPoints(MouseCursorFrame)
    if Private.MouseCursors[DB.Texture].isAtlas then
        MouseCursorFrame.Texture:SetAtlas(Private.MouseCursors[DB.Texture].Path)
        MouseCursorFrame:SetSize(AtlasData[5], AtlasData[5])
        MouseCursorFrame.Anchor:SetSize(AtlasData[5], AtlasData[5])
    else
        MouseCursorFrame.Texture:SetTexture(Private.MouseCursors[DB.Texture].Path)
        MouseCursorFrame.Texture:SetTexCoord(0, 1, 0, 1)
    end
    MouseCursorFrame.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

    MouseCursorFrame.UpdatePosition = function(MCF)
        local MouseX, MouseY = GetCursorPosition()
        local UIScale = UIParent:GetEffectiveScale()
        if Private.MouseCursors[DB.Texture].isAtlas then
            MouseCursorFrame.Anchor:ClearAllPoints()
            MouseCursorFrame.Anchor:SetPoint(AtlasData[2], UIParent, "BOTTOMLEFT", MouseX / UIScale, MouseY / UIScale)
            MouseCursorFrame:ClearAllPoints()
            MouseCursorFrame:SetPoint(AtlasData[1], MouseCursorFrame.Anchor, AtlasData[2], AtlasData[3], AtlasData[4])
        else
            MouseCursorFrame.Anchor:ClearAllPoints()
            MouseCursorFrame.Anchor:SetPoint(DB.Layout[2], UIParent, "BOTTOMLEFT", MouseX / UIScale, MouseY / UIScale)
            MouseCursorFrame:ClearAllPoints()
            MouseCursorFrame:SetPoint(DB.Layout[1], MouseCursorFrame.Anchor, DB.Layout[2], DB.Layout[3], DB.Layout[4])
        end
    end

    if DB.Enable then
        MouseCursorFrame:SetScript("OnUpdate", MouseCursorFrame.UpdatePosition)
    end

    Private.MouseCursorFrame = MouseCursorFrame
end

function Private:UpdateMouseCursor()
    local DB = Private.DB.global.Miscellaneous.MouseCursor
    if Private.MouseCursorFrame then
        Private.MouseCursorFrame:SetShown(DB.Enable)
        Private.MouseCursorFrame:SetSize(DB.Size[1], DB.Size[2])
        Private.MouseCursorFrame.Anchor:SetSize(DB.Size[1], DB.Size[2])
        if Private.MouseCursors[DB.Texture].isAtlas then
            Private.MouseCursorFrame.Texture:SetAtlas(Private.MouseCursors[DB.Texture].Path)
            Private.MouseCursorFrame:SetSize(AtlasData[5], AtlasData[5])
            Private.MouseCursorFrame.Anchor:SetSize(AtlasData[5], AtlasData[5])
        else
            Private.MouseCursorFrame.Texture:SetTexture(Private.MouseCursors[DB.Texture].Path)
            Private.MouseCursorFrame.Texture:SetTexCoord(0, 1, 0, 1)
        end
        Private.MouseCursorFrame.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

        if DB.Enable then
            Private.MouseCursorFrame:SetScript("OnUpdate", Private.MouseCursorFrame.UpdatePosition)
        else
            Private.MouseCursorFrame:SetScript("OnUpdate", nil)
        end
    end
end