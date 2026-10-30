local Private = select(2, ...)

local BannerElements = {
    "BlackBar",
    "DownLine",
    "DownLineGlow",
    "Filigree",
    "FiligreeGlow",
    "UpLine",
    "UpLineGlow",
    "Spark",
}

function Private:SetupObjectiveTrackerBanner()
    if not Private.DB.global.Blizzard.CleanObjectiveTrackerBanner then return end
    _G["ObjectiveTrackerTopBannerFrame"]:ClearAllPoints()
    _G["ObjectiveTrackerTopBannerFrame"]:SetPoint("CENTER", UIParent, "CENTER", 0, 275)
    _G["ObjectiveTrackerTopBannerFrame"].Title:SetFont(_G["ObjectiveTrackerTopBannerFrame"].Title:GetFont(), 18, "OUTLINE, SLUG")
    _G["ObjectiveTrackerTopBannerFrame"].Subtitle:SetFont(_G["ObjectiveTrackerTopBannerFrame"].Subtitle:GetFont(), 15, "OUTLINE, SLUG")
    _G["ObjectiveTrackerTopBannerFrame"]:HookScript("OnShow", function()
        for _, bannerElement in ipairs(BannerElements) do
            if _G["ObjectiveTrackerTopBannerFrame"][bannerElement] then _G["ObjectiveTrackerTopBannerFrame"][bannerElement]:Hide() end
        end
    end)
end