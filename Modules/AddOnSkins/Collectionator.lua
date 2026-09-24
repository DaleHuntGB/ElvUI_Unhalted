local Private = select(2, ...)

local function SkinPanel(Frame)
    if not Frame or Frame.UnhaltedSkinned then return end
    Private:SkinAuctionatorFrame(Frame)

    local PreviousButton = Frame.TMogButton
    for _, Name in ipairs({ "PetButton", "ToyButton", "DecorButton", "MountButton", "RecipeButton" }) do
        local Button = Frame[Name]
        Button:ClearAllPoints()
        Button:Point("TOPLEFT", PreviousButton, "TOPRIGHT", 4, 0)
        PreviousButton = Button
    end

    Frame.FullScanButton:Point("TOPRIGHT", Frame, "TOPRIGHT", 0, 24)
    Frame.OptionsButton:ClearAllPoints()
    Frame.OptionsButton:Point("TOPRIGHT", Frame.FullScanButton, "TOPLEFT", -4, 0)

    local PreviousOption
    for _, Name in ipairs({ "CharacterOnly", "UniquesOnly", "IncludeCollected", "IncludeCrafted" }) do
        local Option = Frame.TMogView[Name]
        Option:Height(24)
        if PreviousOption then
            Option:ClearAllPoints()
            Option:Point("TOPLEFT", PreviousOption, "BOTTOMLEFT", 0, 0)
            Option:Point("TOPRIGHT", PreviousOption, "BOTTOMRIGHT", 0, 0)
        end

        local CheckBox = Option.CheckBox
        CheckBox:Size(24)
        CheckBox.Label:ClearAllPoints()
        CheckBox.Label:Point("LEFT", CheckBox.backdrop, "RIGHT", 6, 0)
        PreviousOption = Option
    end
end

local function SkinCollectionator()
    for _, Name in ipairs({ "Collecting", "Collecting(s)" }) do
        local Tab = _G["AuctionatorTabs_" .. Name]
        if Tab then Private:SkinAuctionatorTab(Tab) end
    end

    SkinPanel(_G.CollectionatorReplicateTabFrame)
    SkinPanel(_G.CollectionatorSummaryTabFrame)
end

function Private:SetupCollectionatorSkin()
    Private:RegisterAuctionatorSkin("Collectionator", SkinCollectionator)
end
