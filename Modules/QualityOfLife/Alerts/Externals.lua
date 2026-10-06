local Private = select(2, ...)

local ExternalsSpells = {
    [1] = 33206,    -- Pain Suppression
    [2] = 6940,     -- Blessing of Sacrifice
    [3] = 1022,     -- Blessing of Protection
    [4] = 204018,   -- Blessing of Spellwarding
    [5] = 116849,   -- Life Cocoon
    [6] = 47788,    -- Guardian Spirit
    [7] = 102342,   -- Ironbark
    [8] = 357170,   -- Time Dilation
}

local ExternalsSounds = {}

local function ApplyLayout(AuraContainer, AuraContainerAnchor, DB)
    AuraContainerAnchor:ClearAllPoints()
    AuraContainerAnchor:SetSize(DB.Size[1], DB.Size[2])
    AuraContainerAnchor:SetPoint(DB.Layout[1], _G["UIParent"], DB.Layout[2], DB.Layout[3], DB.Layout[4])

    AuraContainer:SetAuraGroupLayout("ExternalsAlert", {
        elementWidth = DB.Size[1],
        elementHeight = DB.Size[2],
        elementSpacing = DB.Layout[5],
    })

    local GrowthDirection = DB.Layout[6]
    local IsVertical = GrowthDirection == "UP" or GrowthDirection == "DOWN"
    local AnchorPoint = GrowthDirection == "LEFT" and "TOPRIGHT" or GrowthDirection == "UP" and "BOTTOMLEFT" or "TOPLEFT"
    AuraContainer:SetFlowLayoutAxis(IsVertical and AnchorUtil.FlowLayoutAxis.Vertical or AnchorUtil.FlowLayoutAxis.Horizontal)
    AuraContainer:SetFlowLayoutAnchorPoint(AnchorPoint)
    AuraContainer:SetFlowLayoutGrowthDirection(
        GrowthDirection == "LEFT" and AnchorUtil.FlowDirection.Left or AnchorUtil.FlowDirection.Right,
        GrowthDirection == "UP" and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
    )
    AuraContainer:ClearAllPoints()
    AuraContainer:SetPoint(AnchorPoint, AuraContainerAnchor, AnchorPoint, 0, 0)
end

function Private:SetupExternalsAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.Externals

    if not Private.ExternalsAlertContainer then
        local AuraContainerAnchor = CreateFrame("Frame", nil, UIParent)
        AuraContainerAnchor:SetSize(DB.Size[1], DB.Size[2])
        AuraContainerAnchor:SetScript("OnEvent", function() Private:UpdateExternalsAlert() end)

        Private.ExternalsAlertAnchor = AuraContainerAnchor

        local AuraContainer = CreateFrame("AuraContainer", "ElvUI_Unhalted_ExternalsAlertContainer", AuraContainerAnchor, "CustomAuraContainerTemplate")
        local IncludeSpellIDs = {}
        for _, SpellID in ipairs(ExternalsSpells) do IncludeSpellIDs[SpellID] = true end

        AuraContainer:AddAuraGroup("ExternalsAlert", "HELPFUL", {
            candidateFilters = { includeSpellIDs = IncludeSpellIDs },
            initializeFrame = function(Aura)
                Aura:EnableMouseMotion(false)
                Aura:SetSize(AuraContainerAnchor:GetSize())

                local Border = Aura:CreateTexture(nil, "BACKGROUND")
                Border:SetAllPoints(Aura)
                Border:SetColorTexture(0, 0, 0, 1)

                local Icon = Aura:CreateTexture(nil, "ARTWORK")
                Icon:SetPoint("TOPLEFT", Aura, "TOPLEFT", 1, -1)
                Icon:SetPoint("BOTTOMRIGHT", Aura, "BOTTOMRIGHT", -1, 1)
                Icon:SetTexCoord(0.03, 0.97, 0.03, 0.97)
                Aura:SetIcon(Icon)

                local Cooldown = CreateFrame("Cooldown", nil, Aura, "CooldownFrameTemplate")
                Cooldown:SetAllPoints(Icon)
                Cooldown:SetDrawSwipe(true)
                Cooldown:SetReverse(true)
                Private.ElvUI:RegisterCooldown(Cooldown)
                Cooldown:SetDrawEdge(false)
                Aura:SetDurationCooldown(Cooldown)
            end,
            maxFrameCount = 5,
        })

        ApplyLayout(AuraContainer, AuraContainerAnchor, DB)
        AuraContainer:SetUnit("player")

        Private.ExternalsAlertContainer = AuraContainer
    end

    Private:UpdateExternalsAlert()
end

function Private:UpdateExternalsAlert()
    local DB = Private.DB.global.QualityOfLife.Alerts.Externals

    local AuraContainerAnchor = Private.ExternalsAlertAnchor
    local AuraContainer = Private.ExternalsAlertContainer
    if not AuraContainer then return end

    AuraContainer:SetEnabled(DB.Enable)
    AuraContainer:SetShown(DB.Enable)

    for SpellID, SoundID in pairs(ExternalsSounds) do
        C_UnitAuras.RemoveAuraSound(SoundID)
        ExternalsSounds[SpellID] = nil
    end

    if DB.Enable then
        for _, SpellID in ipairs(ExternalsSpells) do
            ExternalsSounds[SpellID] = C_UnitAuras.AddAuraSound(
                Enum.UnitAuraSoundTrigger.Added, {
                    unitToken = "player",
                    spellID = SpellID,
                    soundFileName = Private:FetchSound(DB.Sound),
                    outputChannel = DB.SoundChannel,
                }
            )
        end
    end

    Private:UpdatePreviewAlerts()

    for Index = 1, AuraContainer:GetAuraGroupFrameCount("ExternalsAlert") do AuraContainer:GetAuraGroupFrame("ExternalsAlert", Index):SetSize(DB.Size[1], DB.Size[2]) end
    ApplyLayout(AuraContainer, AuraContainerAnchor, DB)
end