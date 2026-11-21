local Private = select(2, ...)

local AtlasData = {
    [1] = "CENTER",
    [2] = "CENTER",
    [3] = 15,
    [4] = -14,
    [5] = 92
}

local function UpdatePosition(MouseCursorFrame)
    local MouseX, MouseY = GetCursorPosition()
    if MouseX == MouseCursorFrame.CursorX and MouseY == MouseCursorFrame.CursorY then return end
    MouseCursorFrame.CursorX, MouseCursorFrame.CursorY = MouseX, MouseY
    local UIScale = UIParent:GetEffectiveScale()
    MouseCursorFrame:SetPoint(MouseCursorFrame.Point, UIParent, "BOTTOMLEFT", MouseX / UIScale + MouseCursorFrame.OffsetX, MouseY / UIScale + MouseCursorFrame.OffsetY)
end

function Private:SetupMouseCursor()
    local MouseCursorFrame = CreateFrame("Frame", nil, UIParent)
    MouseCursorFrame.Texture = MouseCursorFrame:CreateTexture(nil, "OVERLAY")
    MouseCursorFrame.Texture:SetAllPoints(MouseCursorFrame)
    Private.MouseCursorFrame = MouseCursorFrame

    Private:UpdateMouseCursor()
end

function Private:UpdateMouseCursor()
    local DB = Private.DB.global.Miscellaneous.MouseCursor
    local MouseCursorFrame = Private.MouseCursorFrame
    local Cursor = Private.MouseCursors[DB.Texture]
    local Layout = Cursor.isAtlas and AtlasData or DB.Layout

    if Cursor.isAtlas then
        MouseCursorFrame.Texture:SetAtlas(Cursor.Path)
        MouseCursorFrame:SetSize(AtlasData[5], AtlasData[5])
    else
        MouseCursorFrame.Texture:SetTexture(Cursor.Path)
        MouseCursorFrame.Texture:SetTexCoord(0, 1, 0, 1)
        MouseCursorFrame:SetSize(DB.Size[1], DB.Size[2])
    end
    MouseCursorFrame.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

    MouseCursorFrame:ClearAllPoints()
    MouseCursorFrame.Point, MouseCursorFrame.OffsetX, MouseCursorFrame.OffsetY = Layout[1], Layout[3], Layout[4]
    MouseCursorFrame.CursorX, MouseCursorFrame.CursorY = -1, -1
    MouseCursorFrame:SetScript("OnUpdate", DB.Enable and UpdatePosition or nil)
    MouseCursorFrame:SetShown(DB.Enable)
end
