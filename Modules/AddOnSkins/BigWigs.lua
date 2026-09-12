local Private = select(2, ...)
local E = Private.E
local S = E:GetModule("Skins")

local function SkinQueueTimer(_, Bar, Name)
    if Name ~= "QueueTimer" or Bar.IsSkinned then return end

    Bar:StripTextures()
    Bar:SetStatusBarTexture(E.media.normTex)
    Bar:CreateBackdrop("Transparent")
    Bar:ClearAllPoints()
    Bar:Point("TOPLEFT", LFGDungeonReadyDialog, "BOTTOMLEFT", E.Border, -(E.Border * 2 + E.Spacing))
    Bar:Point("TOPRIGHT", LFGDungeonReadyDialog, "BOTTOMRIGHT", -E.Border, -(E.Border * 2 + E.Spacing))
    Bar:Height(16)
    Bar:SetStatusBarColor(0.37, 0.5, 1)
    Bar.text:FontTemplate()
    E:RegisterStatusBar(Bar)

    Bar.IsSkinned = true
end

local function SkinKeystoneRows(ScrollChild)
    for _, Cell in ipairs({ ScrollChild:GetChildren() }) do
        if Cell.bg and not Cell.IsSkinned then
            Cell.bg:Hide()
            Cell:SetTemplate("Default")
            Cell:SetBackdropColor(0.2, 0.2, 0.2, 1)
            Cell.IsSkinned = true
        end
    end
end

local function SkinBigWigs()
    BigWigsLoader.RegisterMessage(Private, "BigWigs_FrameCreated", SkinQueueTimer)

    local Title = BigWigsAPI:GetLocale("BigWigs").keystoneTitle
    for _, Panel in ipairs({ UIParent:GetChildren() }) do
        if not Panel:IsForbidden() and Panel.TitleContainer and Panel.TitleContainer.TitleText then
            local Text = Panel.TitleContainer.TitleText:GetText()
            if not issecretvalue(Text) and Text == Title then
                if Panel.IsSkinned then return end

                S:HandlePortraitFrame(Panel)
                Panel.PortraitContainer:Hide()
                Panel.tip:StripTextures()
                Panel.tip:SetTemplate("Transparent")
                for _, Arrow in ipairs({ Panel.tip:GetChildren() }) do
                    Arrow:StripTextures()
                end

                local PreviousTab;
                for _, Child in ipairs({ Panel:GetChildren() }) do
                    if Child:IsObjectType("ScrollFrame") then
                        S:HandleTrimScrollBar(Child.ScrollBar)
                        local ScrollChild = Child:GetScrollChild()
                        SkinKeystoneRows(ScrollChild)
                        hooksecurefunc(ScrollChild, "SetHeight", SkinKeystoneRows)
                    elseif Child.LeftActive then
                        Child:StripTextures()
                        S:HandleTab(Child)
                        Child:ClearAllPoints()
                        if PreviousTab then
                            Child:Point("TOPLEFT", PreviousTab, "TOPRIGHT", -5, 0)
                        else
                            Child:Point("TOPLEFT", Panel, "BOTTOMLEFT", -3, 0)
                        end
                        PreviousTab = Child
                    end
                end

                Panel.IsSkinned = true
                return
            end
        end
    end
end

function Private:SetupBigWigsSkin()
    if not Private.DB.global.AddOnSkins.BigWigs then return end

    if S.Initialized and C_AddOns.IsAddOnLoaded("BigWigs") then
        SkinBigWigs()
    else
        S:AddCallbackForAddon("BigWigs", "UnhaltedUI_BigWigs", SkinBigWigs)
    end
end
