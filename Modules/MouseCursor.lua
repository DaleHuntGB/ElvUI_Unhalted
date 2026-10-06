local Private = select(2, ...)

function Private:SetupMouseCursor()
    local DB = Private.DB.global.MouseCursor

    local MouseCursorFrame = CreateFrame("Frame", nil, UIParent)
    MouseCursorFrame:SetShown(DB.Enable)
    MouseCursorFrame:SetSize(DB.Size[1], DB.Size[2])
    MouseCursorFrame.Anchor = CreateFrame("Frame", nil, UIParent)
    MouseCursorFrame.Anchor:SetSize(DB.Size[1], DB.Size[2])

    MouseCursorFrame.Texture = MouseCursorFrame:CreateTexture(nil, "OVERLAY")
    MouseCursorFrame.Texture:SetAllPoints(MouseCursorFrame)
    MouseCursorFrame.Texture:SetTexture(Private.MouseCursorTextures[DB.Texture])
    MouseCursorFrame.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

    MouseCursorFrame.UpdatePosition = function(MCF)
        local MouseX, MouseY = GetCursorPosition()
        local UIScale = UIParent:GetEffectiveScale()
        MouseCursorFrame.Anchor:ClearAllPoints()
        MouseCursorFrame.Anchor:SetPoint(DB.Layout[2], UIParent, "BOTTOMLEFT", MouseX / UIScale, MouseY / UIScale)
        MouseCursorFrame:ClearAllPoints()
        MouseCursorFrame:SetPoint(DB.Layout[1], MouseCursorFrame.Anchor, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    end

    if DB.Enable then
        MouseCursorFrame:SetScript("OnUpdate", MouseCursorFrame.UpdatePosition)
    end

    Private.MouseCursorFrame = MouseCursorFrame
end

function Private:UpdateMouseCursor()
    local DB = Private.DB.global.MouseCursor
    if Private.MouseCursorFrame then
        Private.MouseCursorFrame:SetShown(DB.Enable)
        Private.MouseCursorFrame:SetSize(DB.Size[1], DB.Size[2])
        Private.MouseCursorFrame.Anchor:SetSize(DB.Size[1], DB.Size[2])
        Private.MouseCursorFrame.Texture:SetTexture(Private.MouseCursorTextures[DB.Texture])
        Private.MouseCursorFrame.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

        if DB.Enable then
            Private.MouseCursorFrame:SetScript("OnUpdate", Private.MouseCursorFrame.UpdatePosition)
        else
            Private.MouseCursorFrame:SetScript("OnUpdate", nil)
        end
    end
end