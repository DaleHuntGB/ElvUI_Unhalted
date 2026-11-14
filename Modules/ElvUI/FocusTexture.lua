local Private = select(2, ...)
local NP = Private.E:GetModule("NamePlates")
local LSM = Private.LSM
local FocusTextures = {}

local function StyleFocusTexture(Texture)
    local DB = Private.DB.global.ElvUI.FocusTexture
    Texture:SetTexture(LSM:Fetch("statusbar", DB.Texture))
    Texture:SetVertexColor(DB.Colour[1], DB.Colour[2], DB.Colour[3], DB.Colour[4])
end

local function CreateFocusTexture(Health)
    local Texture = Health:CreateTexture(nil, "OVERLAY")
    Texture:SetAllPoints()
    StyleFocusTexture(Texture)
    FocusTextures[Health] = Texture
end

local function GetFocusHealth()
    if not Private.DB.global.ElvUI.FocusTexture.Enable then return end
    local Plate = C_NamePlate.GetNamePlateForUnit("focus")
    return Plate and Plate.unitFrame and Plate.unitFrame.Health
end

local function UpdateFocusTexture()
    local FocusHealth = GetFocusHealth()
    for Health, Texture in pairs(FocusTextures) do Texture:SetShown(Health == FocusHealth) end
    if FocusHealth and not FocusTextures[FocusHealth] then CreateFocusTexture(FocusHealth) end
end

function Private:SetupFocusTexture()
    if not Private.E.private.nameplates.enable then return end

    local EventFrame = CreateFrame("Frame")
    EventFrame:SetScript("OnEvent", UpdateFocusTexture)
    Private.FocusTextureEventFrame = EventFrame
    hooksecurefunc(NP, "UpdatePlateBase", UpdateFocusTexture)

    Private:UpdateFocusTexture()
end

function Private:UpdateFocusTexture()
    local EventFrame = Private.FocusTextureEventFrame
    if not EventFrame then return end

    for _, Texture in pairs(FocusTextures) do StyleFocusTexture(Texture) end

    if Private.DB.global.ElvUI.FocusTexture.Enable then
        EventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    else
        EventFrame:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    end

    UpdateFocusTexture()
end
