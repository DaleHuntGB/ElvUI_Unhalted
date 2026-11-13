local Private = select(2, ...)

function Private:UpdateNavigationArrow()
    local NavigationArrow = Private.NavigationArrow
    if not NavigationArrow then return end
    local DB = Private.DB.global.Miscellaneous.Navigation
    local Font, FontStyle = Private:FetchFont(Private.E.db.general.font), Private.E.db.general.fontStyle

    NavigationArrow.Arrow:SetTexture(Private.NavigationArrows[DB.ArrowTexture].Path)
    NavigationArrow:SetSize(DB.Size, DB.Size)
    NavigationArrow:ClearAllPoints()
    NavigationArrow:SetPoint(DB.Layout[1], UIParent, DB.Layout[2], DB.Layout[3], DB.Layout[4])
    Private.E:SetFont(NavigationArrow.Distance, Font, DB.Text.FontSize, FontStyle)
    Private.E:SetFont(NavigationArrow.Steps, Font, DB.Text.FontSize, FontStyle)
end

function Private:CreateNavigationArrow()
    local NavigationArrow = CreateFrame("Frame", "UnhaltedNavigationArrow", UIParent)
    NavigationArrow:Hide()

    NavigationArrow.Arrow = NavigationArrow:CreateTexture(nil, "ARTWORK")
    NavigationArrow.Arrow:SetAllPoints(NavigationArrow)
    NavigationArrow.Arrow:SetVertexColor(Private.E.db.general.valuecolor.r, Private.E.db.general.valuecolor.g, Private.E.db.general.valuecolor.b)

    NavigationArrow.Distance = NavigationArrow:CreateFontString(nil, "OVERLAY")
    NavigationArrow.Distance:SetPoint("TOP", NavigationArrow, "BOTTOM", 0, -3)

    NavigationArrow.Steps = NavigationArrow:CreateFontString(nil, "OVERLAY")
    NavigationArrow.Steps:SetPoint("TOP", NavigationArrow.Distance, "BOTTOM", 0, -3)
    NavigationArrow.Steps:SetJustifyH("CENTER")
    NavigationArrow.Steps:SetSpacing(3)

    Private.NavigationArrow = NavigationArrow
    Private:UpdateNavigationArrow()
end
