local Private = select(2, ...)
local NP = Private.ElvUI:GetModule("NamePlates")
local NameplateTextureOverlayFrame;

local function ConfigureNameplateTextureOverlay(_, Nameplate)
    local Health = Nameplate.Health
    if not Health then return end
    local DB = Private.DB.global.ElvUIEnhancements.NameplateTextureOverlay
    local Texture = Health.UnhaltedTextureOverlay
    if not DB.Enable or not Nameplate.__unit or not Private.ElvUI:UnitIsUnit(Nameplate.__unit, "focus") then if Texture then Texture:Hide() end return end

    if not Texture then
        Texture = Health:CreateTexture(nil, "OVERLAY")
        Texture:SetAllPoints(Health)
        Health.UnhaltedTextureOverlay = Texture
    end

    Texture:SetTexture(Private.LSM:Fetch("statusbar", DB.Texture))
    Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3])
    Texture:SetAlpha(DB.Opacity)
    Texture:Show()
end

function Private:UpdateNameplateTextureOverlay()
    local Enabled = Private.DB.global.ElvUIEnhancements.NameplateTextureOverlay.Enable
    if Enabled and not NameplateTextureOverlayFrame then
        NameplateTextureOverlayFrame = CreateFrame("Frame")
        NameplateTextureOverlayFrame:SetScript("OnEvent", function() Private:UpdateNameplateTextureOverlay() end)
        hooksecurefunc(NP, "UpdatePlate", ConfigureNameplateTextureOverlay)
    end

    if NameplateTextureOverlayFrame then
        if Enabled then
            NameplateTextureOverlayFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
        else
            NameplateTextureOverlayFrame:UnregisterAllEvents()
        end
    end

    if NP.Initialized then
        for Nameplate in pairs(NP.Plates) do ConfigureNameplateTextureOverlay(nil, Nameplate) end
    end
end
