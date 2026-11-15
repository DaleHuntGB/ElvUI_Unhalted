local Private = select(2, ...)

local ClassMergedIcons = {
    HUNTER = {
        Class = "Hunter",
        Icons = {
            AimedShotMultiShot = { 200362, 200394 },
            FireTraps = { 200402, 200408 },
            FrostTraps = { 200404, 200407 },
            SummonHawkArcaneShot = { 200354, 200363 },
        },
    },
}

local ClassIcons = ClassMergedIcons[Private.E.myclass]
local MergedTextures, HookedItems = {}, {}
local isHooked = false

if ClassIcons then
    for TextureName, CooldownIDs in pairs(ClassIcons.Icons) do
        local Texture = "Interface\\AddOns\\ElvUI_Unhalted\\Media\\Textures\\Classes\\" .. ClassIcons.Class .. "\\" .. TextureName .. ".png"
        for Index = 1, #CooldownIDs do MergedTextures[CooldownIDs[Index]] = Texture end
    end
end

local function ApplyMergedTexture(Item)
    local Texture = MergedTextures[Item:GetCooldownID()]
    if Texture and Private.DB.global.Miscellaneous[ClassIcons.Class].MergeIcons then Item:GetIconTexture():SetTexture(Texture) end
end

local function HookItem(_, Item)
    if HookedItems[Item] then return end
    HookedItems[Item] = true
    hooksecurefunc(Item, "RefreshSpellTexture", ApplyMergedTexture)
end

local function RefreshItems()
    for _, Viewer in ipairs({ EssentialCooldownViewer, UtilityCooldownViewer }) do
        if not isHooked then hooksecurefunc(Viewer, "OnAcquireItemFrame", HookItem) end
        for Item in Viewer.itemFramePool:EnumerateActive() do
            HookItem(Viewer, Item)
            if MergedTextures[Item:GetCooldownID()] then Item:RefreshSpellTexture() end
        end
    end
    isHooked = true
end

function Private:SetupMergeIcons()
    Private:UpdateMergeIcons()
end

function Private:UpdateMergeIcons()
    if not ClassIcons or not (isHooked or Private.DB.global.Miscellaneous[ClassIcons.Class].MergeIcons) then return end
    EventUtil.ContinueOnAddOnLoaded("Blizzard_CooldownViewer", RefreshItems)
end
