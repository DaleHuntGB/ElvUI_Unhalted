local Private = select(2, ...)

function Private:SetupDamageMeters()
    for i in pairs(Private.DB.global.DamageMeter) do
        local DB = Private.DB.global.DamageMeter[i]
        if DB.Enable then
            Private:CreateWindow(DB, i)
        end
    end
end

function Private:UpdateDamageMeters()
    for i in pairs(Private.DB.global.DamageMeter) do
        local DB = Private.DB.global.DamageMeter[i]
        local Frame = _G["DamageMeter_0"..i]
        if Frame then
            Private:UpdateWindow(Frame, DB)
        elseif DB.Enable then
            Private:CreateWindow(DB, i)
        end
    end
end
