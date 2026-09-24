local Private = select(2, ...)

local function SkinCollectionator()
    for _, Name in ipairs({ "Collecting", "Collecting(s)" }) do
        local Tab = _G["AuctionatorTabs_" .. Name]
        if Tab then Private:SkinAuctionatorTab(Tab) end
    end

    Private:SkinAuctionatorFrame(_G.CollectionatorReplicateTabFrame)
    Private:SkinAuctionatorFrame(_G.CollectionatorSummaryTabFrame)
end

function Private:SetupCollectionatorSkin()
    Private:RegisterAuctionatorSkin("Collectionator", SkinCollectionator)
end
