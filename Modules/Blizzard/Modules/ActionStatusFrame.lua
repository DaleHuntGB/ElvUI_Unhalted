local Private = select(2, ...)

function Private:SetupActionStatusFrame()
    local DB = Private.DB.global.Blizzard.ActionStatus
    local AST = _G["ActionStatus"].Text

    if AST then
        AST:SetFont(Private:FetchFont(DB.Font), DB.FontSize, DB.FontFlag)
        AST:ClearAllPoints()
        AST:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        AST:SetShadowColor(0, 0, 0, 0)
        AST:SetShadowOffset(0, 0)
        AST:SetAlpha(DB.Enable and 1 or 0)
    end

end

function Private:UpdateActionStatusFrame()
    local DB = Private.DB.global.Blizzard.ActionStatus
    local AS = _G["ActionStatus"]
    local AST = _G["ActionStatus"].Text

    if AST then
        AST:SetFont(Private:FetchFont(DB.Font), DB.FontSize, DB.FontFlag)
        AST:ClearAllPoints()
        AST:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])
        AST:SetShadowColor(0, 0, 0, 0)
        AST:SetShadowOffset(0, 0)
        AST:SetAlpha(DB.Enable and 1 or 0)

        AS:DisplayMessage(Private.AddOnName .. ": " .. "Sample Text...")
    end

end
