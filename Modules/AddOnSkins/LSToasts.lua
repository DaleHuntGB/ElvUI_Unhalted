local Private = select(2, ...)

function Private:SetupLSToasts()
    if not Private.DB.global.AddOnSkins.LSToasts then return end
    if not C_AddOns.IsAddOnLoaded("ls_Toasts") then return end

    local LST = _G.ls_Toasts
    if not LST or not LST[1] or not LST[1].RegisterSkin then return end

    local Config = LST[2]
    local AnchorOptions = Config and Config.options and Config.options.args.anchors.args
    if AnchorOptions then
        for _, Options in pairs(AnchorOptions) do
            local OffsetY = Options.args and Options.args.growth_offset_y
            if OffsetY then
                OffsetY.min = 0
                OffsetY.step = 1
            end
        end

        local Registry = LibStub("AceConfigRegistry-3.0", true)
        if Registry then Registry:NotifyChange("ls_Toasts") end
    end

    LST[1]:RegisterSkin("unhaltedui", {
        name = "|cFF6080FFUnhalted|r",
        template = "elv",
        text_bg = { hidden = true },
        leaves = { hidden = true },
        dragon = { hidden = true },
        icon_highlight = { hidden = true },
        bg = {
            default = {
                texture = {20/255, 20/255, 20/255, 1},
            },
        },
        glow = {
            texture = {1, 1, 1, 0},
            size = {226, 50},
        },
        shine = {
            tex_coords = {403 / 512, 465 / 512, 15 / 256, 61 / 256},
            size = {0.1, 0.1},
            point = { y = 0, },
        },
    })
end
