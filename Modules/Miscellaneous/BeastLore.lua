local Private = select(2, ...)

function Private:SetupBeastLore()
    if Private.E.myclass ~= "HUNTER" then return end

    local Abilities = {
        -- Bite
        {SpellID = 17253, Rank = 1, NPCs = {30, 1131, 1138, 1505, 1509, 1688, 1922, 1994, 1999, 2958, 2959, 3110, 250868, 250873, 266851}},
        {SpellID = 17255, Rank = 2, NPCs = {118, 442, 833, 834, 1132, 1133, 1195, 1555, 1693, 1765, 2000, 2001, 2960, 3461, 7319, 250874, 254589, 256492, 270693}},
        {SpellID = 17256, Rank = 3, NPCs = {505, 521, 569, 616, 1185, 1923, 2172, 2350, 2476, 3653, 3823, 4005, 4006, 4824, 5053, 11921, 14266, 14279}},
        {SpellID = 17257, Rank = 4, NPCs = {574, 628, 1112, 1258, 2089, 2348, 2349, 2408, 3821, 3825, 4825, 4887, 14223, 260803, 260809}},
        {SpellID = 17258, Rank = 5, NPCs = {2563, 2565, 2727, 4143, 4341, 4343, 4344, 4396, 4411, 4412, 4413, 259267, 266862, 268831}},
        {SpellID = 17259, Rank = 6, NPCs = {769, 1087, 2753, 4345, 4400, 4841, 5286, 5356, 8211, 8762, 8959, 13599, 14233, 14339}},
        {SpellID = 17260, Rank = 7, NPCs = {1817, 1824, 2505, 2681, 3581, 6585, 8213, 8277, 8933, 8961}},
        {SpellID = 17261, Rank = 8, NPCs = {9696, 11370}},
        -- Charge
        {SpellID = 7371, Rank = 1, NPCs = {113, 119, 330, 390, 524, 708, 1125, 1126, 1127, 1190, 1689, 1984, 1985, 2954, 2966, 3098, 3099, 3100, 3225}},
        {SpellID = 26177, Rank = 2, NPCs = {157, 454, 547, 1191, 1192}},
        {SpellID = 26178, Rank = 3, NPCs = {345, 4511, 4512, 4514}},
        {SpellID = 26179, Rank = 4, NPCs = {255851, 258331}},
        {SpellID = 26201, Rank = 5, NPCs = {5992, 8303}},
        {SpellID = 27685, Rank = 6, NPCs = {16117}},
        -- Claw
        {SpellID = 16827, Rank = 1, NPCs = {1196, 1995, 2970, 3106, 3124, 3281, 250926, 250928, 250937, 251115}},
        {SpellID = 16828, Rank = 2, NPCs = {822, 1130, 1778, 1961, 1997, 2163, 2232, 3108, 3127, 5823, 248299, 250927, 254588}},
        {SpellID = 16829, Rank = 3, NPCs = {1189, 1216, 1225, 2351, 3619, 3809, 3812, 4821, 4822, 6788}},
        {SpellID = 16830, Rank = 4, NPCs = {3810, 4140, 4696, 4823}},
        {SpellID = 16831, Rank = 5, NPCs = {4697, 5937, 7022, 259269, 263343}},
        {SpellID = 16832, Rank = 6, NPCs = {731, 922, 1088, 5268, 5352, 5422}},
        {SpellID = 3010, Rank = 7, NPCs = {1816, 5274, 7099, 7444, 7455, 8301, 8958, 9695, 14343, 14344}},
        {SpellID = 3009, Rank = 8, NPCs = {7445, 7456}},
        -- Cower
        {SpellID = 1742, Rank = 1, NPCs = {1199, 1553, 2042, 2070, 2321, 2957, 3035, 3068, 3121, 3246, 251245, 253282, 276198}},
        {SpellID = 1753, Rank = 2, NPCs = {2237, 2323, 2384, 3241, 3245, 4067}},
        {SpellID = 1754, Rank = 3, NPCs = {681, 683, 736, 2385, 4126, 4425, 4538, 4539}},
        {SpellID = 1755, Rank = 4, NPCs = {2731, 2732, 4725, 4861, 259054, 259055, 263348}},
        {SpellID = 1756, Rank = 5, NPCs = {2522, 8600, 8601, 8927}},
        {SpellID = 16697, Rank = 6, NPCs = {7430, 8602}},
        -- Dash
        {SpellID = 23099, Rank = 1, NPCs = {682, 729, 767, 976, 2727, 2728, 2729, 2850, 4304, 4662, 4688, 4724, 4725, 4950}},
        {SpellID = 23109, Rank = 2, NPCs = {728, 1713, 2730, 2734, 2926, 5286, 5425, 5426, 5427, 8208, 8211, 263315}},
        {SpellID = 23110, Rank = 3, NPCs = {2681, 7055, 7432, 7433, 8300, 8303, 9416, 9696, 10200, 11365, 15067}},
        -- Demoralizing Screech
        {SpellID = 24423, Rank = 1, NPCs = {154, 199, 2971}},
        {SpellID = 24577, Rank = 2, NPCs = {4158, 4694}},
        {SpellID = 24578, Rank = 3, NPCs = {1809}},
        -- Dismember
        {SpellID = 1264758, Rank = 1, NPCs = {1400, 1417, 1693, 270693}},
        {SpellID = 1264927, Rank = 2, NPCs = {1084, 1150, 1151, 260796, 260797}},
        {SpellID = 1264929, Rank = 3, NPCs = {4342, 259046}},
        -- Dive
        {SpellID = 23145, Rank = 1, NPCs = {2578, 2579, 4346, 4347, 4348, 4425, 4538, 4539, 4693, 4861, 6013}},
        {SpellID = 23147, Rank = 2, NPCs = {5307, 5308, 5349, 5428, 5429, 5430, 7097, 8207}},
        {SpellID = 23148, Rank = 3, NPCs = {1809, 2931, 5708, 7098, 7099, 7455, 7456, 8299, 8600, 8927, 14343}},
        -- Dust Cloud
        {SpellID = 1265899, Rank = 1, NPCs = {2172, 2322, 3246}},
        {SpellID = 1265901, Rank = 2, NPCs = {4724}},
        {SpellID = 1265902, Rank = 3, NPCs = {4725, 263348}},
        -- Faster Attack
        {SpellID = 1263099, NPCs = {3416}},
        {SpellID = 1263100, NPCs = {259388}},
        {SpellID = 1263102, NPCs = {3415, 274300}},
        {SpellID = 1263104, NPCs = {3425, 251245}},
        {SpellID = 1263107, NPCs = {3245}},
        {SpellID = 1263109, NPCs = {5807}},
        -- Furious Howl
        {SpellID = 24604, Rank = 1, NPCs = {833, 1765, 10644, 274300}},
        {SpellID = 24605, Rank = 2, NPCs = {1258, 2729, 2925, 3825, 5287}},
        {SpellID = 24603, Rank = 3, NPCs = {2924, 5286, 5356, 8959, 14339}},
        {SpellID = 24597, Rank = 4, NPCs = {9696}},
        -- Lightning Breath
        {SpellID = 24844, Rank = 1, NPCs = {20797}},
        {SpellID = 25008, Rank = 2, NPCs = {3247, 3249, 3424, 3630, 3631, 5056, 5756}},
        {SpellID = 25009, Rank = 3, NPCs = {3472, 4117, 4118, 4119}},
        {SpellID = 25010, Rank = 4, NPCs = {4347, 4348, 5307, 5308}},
        {SpellID = 25011, Rank = 5, NPCs = {5291, 5349, 5708, 8336}},
        {SpellID = 25012, Rank = 6, NPCs = {11357, 11359}},
        -- Mine!
        {SpellID = 1265054, Rank = 1, NPCs = {270196, 270298, 276101}},
        {SpellID = 1265056, Rank = 3, NPCs = {272389}},
        -- Pinch
        {SpellID = 1264735, Rank = 1, NPCs = {1216, 2232, 2235, 2236}},
        {SpellID = 1264736, Rank = 2, NPCs = {4823, 12347}},
        {SpellID = 1264739, Rank = 3, NPCs = {922, 255901}},
        {SpellID = 1264741, Rank = 4, NPCs = {256807}},
        -- Prowl
        {SpellID = 24450, Rank = 1, NPCs = {684, 768, 2406, 2731}},
        {SpellID = 24452, Rank = 2, NPCs = {731, 1713, 2734}},
        {SpellID = 24453, Rank = 3, NPCs = {2522, 7432, 15067}},
        -- Savage Rend
        {SpellID = 1265065, Rank = 1, NPCs = {3255}},
        {SpellID = 1265066, Rank = 2, NPCs = {855, 1015, 1016, 1017, 1018, 1019, 1021, 1022, 1023, 260800}},
        {SpellID = 1265067, Rank = 3, NPCs = {687, 854, 2561, 4352, 4355, 4357}},
        -- Scorpid Poison
        {SpellID = 24640, Rank = 1, NPCs = {3127, 3226, 3250, 3252, 5823}},
        {SpellID = 24583, Rank = 2, NPCs = {4139, 4140, 4696, 4697, 4699, 5937, 7078}},
        {SpellID = 24586, Rank = 3, NPCs = {5422, 5423, 5424, 5988, 7405, 7803, 8926, 9691, 9695, 11735}},
        {SpellID = 24587, Rank = 4, NPCs = {9698, 11736, 11737, 14476}},
        -- Shell Shield
        {SpellID = 26064, Rank = 1, NPCs = {2408, 3653, 4824, 4825, 4887, 8213, 14223}},
        -- Slower Attack
        {SpellID = 1263113, NPCs = {251115}},
        -- Sonic Blast
        {SpellID = 1264478, Rank = 1, NPCs = {3866, 3868, 277882}},
        {SpellID = 1264479, Rank = 2, NPCs = {277881}},
        -- Swipe
        {SpellID = 1264494, Rank = 1, NPCs = {1188, 1797, 259388}},
        {SpellID = 1264497, Rank = 2, NPCs = {2356, 271334}},
        {SpellID = 1264498, Rank = 3, NPCs = {5268, 5272}},
        -- Tendon Rip
        {SpellID = 1265038, Rank = 1, NPCs = {4127, 4128, 4129, 4316}},
        {SpellID = 1265039, Rank = 2, NPCs = {4248, 4249, 4548}},
        {SpellID = 1265040, Rank = 3, NPCs = {5426}},
        -- Thunderstomp
        {SpellID = 26090, Rank = 1, NPCs = {1108, 1114}},
        {SpellID = 26187, Rank = 2, NPCs = {1557, 5262}},
        {SpellID = 26188, Rank = 3, NPCs = {6516, 9622}},
        -- Trickster's Dance
        {SpellID = 1310612, Rank = 1, NPCs = {277645}},
        -- Web
        {SpellID = 1265843, Rank = 1, NPCs = {217, 539, 1184, 1780, 3819, 250484, 256040}},
        {SpellID = 1265878, Rank = 2, NPCs = {930, 949, 2349, 3820}},
        {SpellID = 1265880, Rank = 3, NPCs = {858, 4377, 4378, 4379, 4414, 4415, 270664}},
    }

    local Label = "|c" .. Private.E.AccentColour .. "Ability:|r "
    local NPCLines = {}

    for _, Ability in ipairs(Abilities) do
        local SpellName = C_Spell.GetSpellName(Ability.SpellID)
        if SpellName then
            local Line = Ability.Rank and Label .. SpellName .. " [Rank " .. Ability.Rank .. "]" or Label .. SpellName
            for _, NPCID in ipairs(Ability.NPCs) do
                NPCLines[NPCID] = NPCLines[NPCID] or {}
                table.insert(NPCLines[NPCID], Line)
            end
        end
    end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(Tooltip, Data)
        local GUID = Data.guid
        if Tooltip ~= GameTooltip or Private:IsSecret(GUID) or not GUID then return end

        local UnitType, _, _, _, _, NPCID = strsplit("-", GUID)
        local Lines = UnitType == "Creature" and NPCLines[tonumber(NPCID)]
        if not Lines then return end

        for _, Line in ipairs(Lines) do
            Tooltip:AddLine(Line, 1, 1, 1)
        end
    end)
end
