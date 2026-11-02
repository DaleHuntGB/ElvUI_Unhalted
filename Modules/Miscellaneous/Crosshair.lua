local Private = select(2, ...)

function Private:SetupCrosshair()
    local DB = Private.DB.global.Miscellaneous.Crosshair

    local Crosshair = CreateFrame("Frame", "Crosshair", UIParent)
    Crosshair:SetSize(DB.Size[1], DB.Size[2])
    Crosshair:SetPoint(DB.Layout[1], _G["WorldFrame"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    Crosshair.Texture = Crosshair:CreateTexture(nil, "BACKGROUND")
    Crosshair.Texture:SetAllPoints()
    Crosshair.Texture:SetTexture(Private.Crosshairs[DB.Texture].Path)
    Crosshair.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

    Private.Crosshair = Crosshair

    Crosshair:SetShown(DB.Enable)
end

function Private:UpdateCrosshair()
    local DB = Private.DB.global.Miscellaneous.Crosshair

    Private.Crosshair:ClearAllPoints()
    Private.Crosshair:SetSize(DB.Size[1], DB.Size[2])
    Private.Crosshair:SetPoint(DB.Layout[1], _G["WorldFrame"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    Private.Crosshair.Texture:SetTexture(Private.Crosshairs[DB.Texture].Path)
    Private.Crosshair.Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])

    Private.Crosshair:SetShown(DB.Enable)
end
