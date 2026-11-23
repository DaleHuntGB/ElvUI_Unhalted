local Private = select(2, ...)

function Private:SetupBeastLore()
    if Private.E.myclass ~= "HUNTER" then return end

    local Abilities = {
        -- Bite
        {SpellID = 17254, Rank = 1, NPCs = {30, 1131, 1138, 1505, 1509, 1688, 1922, 1994, 1999, 2958, 2959, 3110, 250868, 250873, 266851}},
        {SpellID = 17262, Rank = 2, NPCs = {118, 442, 833, 834, 1132, 1133, 1195, 1555, 1693, 1765, 2000, 2001, 2960, 3461, 7319, 250874, 254589, 256492, 270693}},
        {SpellID = 17263, Rank = 3, NPCs = {505, 521, 569, 616, 1185, 1923, 2172, 2350, 2476, 3653, 3823, 4005, 4006, 4824, 5053, 11921, 14266, 14279}},
        {SpellID = 17264, Rank = 4, NPCs = {574, 628, 1112, 1258, 2089, 2348, 2349, 2408, 3821, 3825, 4825, 4887, 14223, 260803, 260809}},
        {SpellID = 17265, Rank = 5, NPCs = {2563, 2565, 2727, 4143, 4341, 4343, 4344, 4396, 4411, 4412, 4413, 259267, 266862, 268831}},
        {SpellID = 17266, Rank = 6, NPCs = {769, 1087, 2753, 4345, 4400, 4841, 5286, 5356, 8211, 8762, 8959, 13599, 14233, 14339}},
        {SpellID = 17267, Rank = 7, NPCs = {1817, 1824, 2505, 2681, 3581, 6585, 8213, 8277, 8933, 8961}},
        {SpellID = 17268, Rank = 8, NPCs = {9696, 11370}},
        -- Charge
        {SpellID = 7370, Rank = 1, NPCs = {113, 119, 330, 390, 524, 708, 1125, 1126, 1127, 1190, 1689, 1984, 1985, 2954, 2966, 3098, 3099, 3100, 3225}},
        {SpellID = 26184, Rank = 2, NPCs = {157, 454, 547, 1191, 1192}},
        {SpellID = 26185, Rank = 3, NPCs = {345, 4511, 4512, 4514}},
        {SpellID = 26186, Rank = 4, NPCs = {255851, 258331}},
        {SpellID = 26202, Rank = 5, NPCs = {5992, 8303}},
        {SpellID = 28343, Rank = 6, NPCs = {16117}},
        -- Claw
        {SpellID = 2980, Rank = 1, NPCs = {1196, 1995, 2970, 3106, 3124, 3281, 250926, 250928, 250937, 251115}},
        {SpellID = 2981, Rank = 2, NPCs = {822, 1130, 1778, 1961, 1997, 2163, 2232, 3108, 3127, 5823, 248299, 250927, 254588}},
        {SpellID = 2982, Rank = 3, NPCs = {1189, 1216, 1225, 2351, 3619, 3809, 3812, 4821, 4822, 6788}},
        {SpellID = 3667, Rank = 4, NPCs = {3810, 4140, 4696, 4823}},
        {SpellID = 2975, Rank = 5, NPCs = {4697, 5937, 7022, 259269, 263343}},
        {SpellID = 2976, Rank = 6, NPCs = {731, 922, 1088, 5268, 5352, 5422}},
        {SpellID = 2977, Rank = 7, NPCs = {1816, 5274, 7099, 7444, 7455, 8301, 8958, 9695, 14343, 14344}},
        {SpellID = 3666, Rank = 8, NPCs = {7445, 7456}},
        -- Cower
        {SpellID = 1747, Rank = 1, NPCs = {1199, 1553, 2042, 2070, 2321, 2957, 3035, 3068, 3121, 3246, 251245, 253282, 276198}},
        {SpellID = 1748, Rank = 2, NPCs = {2237, 2323, 2384, 3241, 3245, 4067}},
        {SpellID = 1749, Rank = 3, NPCs = {681, 683, 736, 2385, 4126, 4425, 4538, 4539}},
        {SpellID = 1750, Rank = 4, NPCs = {2731, 2732, 4725, 4861, 259054, 259055, 263348}},
        {SpellID = 1751, Rank = 5, NPCs = {2522, 8600, 8601, 8927}},
        {SpellID = 16698, Rank = 6, NPCs = {7430, 8602}},
        -- Dash
        {SpellID = 23100, Rank = 1, NPCs = {682, 729, 767, 976, 2727, 2728, 2729, 2850, 4304, 4662, 4688, 4724, 4725, 4950}},
        {SpellID = 23111, Rank = 2, NPCs = {728, 1713, 2730, 2734, 2926, 5286, 5425, 5426, 5427, 8208, 8211, 263315}},
        {SpellID = 23112, Rank = 3, NPCs = {2681, 7055, 7432, 7433, 8300, 8303, 9416, 9696, 10200, 11365, 15067}},
        -- Demoralizing Screech
        {SpellID = 24424, Rank = 1, NPCs = {154, 199, 2971}},
        {SpellID = 24580, Rank = 2, NPCs = {4158, 4694}},
        {SpellID = 24581, Rank = 3, NPCs = {1809}},
        -- Dismember
        {SpellID = 1264937, Rank = 1, NPCs = {1400, 1417, 1693, 270693}},
        {SpellID = 1264939, Rank = 2, NPCs = {1084, 1150, 1151, 260796, 260797}},
        {SpellID = 1264970, Rank = 3, NPCs = {4342, 259046}},
        -- Dive
        {SpellID = 23146, Rank = 1, NPCs = {2578, 2579, 4346, 4347, 4348, 4425, 4538, 4539, 4693, 4861, 6013}},
        {SpellID = 23149, Rank = 2, NPCs = {5307, 5308, 5349, 5428, 5429, 5430, 7097, 8207}},
        {SpellID = 23150, Rank = 3, NPCs = {1809, 2931, 5708, 7098, 7099, 7455, 7456, 8299, 8600, 8927, 14343}},
        -- Dust Cloud
        {SpellID = 1265907, Rank = 1, NPCs = {2172, 2322, 3246}},
        {SpellID = 1265908, Rank = 2, NPCs = {4724}},
        {SpellID = 1265909, Rank = 3, NPCs = {4725, 263348}},
        -- Faster Attack
        {SpellID = 1263099, NPCs = {3416}},
        {SpellID = 1263100, NPCs = {259388}},
        {SpellID = 1263102, NPCs = {3415, 274300}},
        {SpellID = 1263104, NPCs = {3425, 251245}},
        {SpellID = 1263107, NPCs = {3245}},
        {SpellID = 1263109, NPCs = {5807}},
        -- Furious Howl
        {SpellID = 24609, Rank = 1, NPCs = {833, 1765, 10644, 274300}},
        {SpellID = 24608, Rank = 2, NPCs = {1258, 2729, 2925, 3825, 5287}},
        {SpellID = 24607, Rank = 3, NPCs = {2924, 5286, 5356, 8959, 14339}},
        {SpellID = 24599, Rank = 4, NPCs = {9696}},
        -- Lightning Breath
        {SpellID = 24845, Rank = 1, NPCs = {20797}},
        {SpellID = 25013, Rank = 2, NPCs = {3247, 3249, 3424, 3630, 3631, 5056, 5756}},
        {SpellID = 25014, Rank = 3, NPCs = {3472, 4117, 4118, 4119}},
        {SpellID = 25015, Rank = 4, NPCs = {4347, 4348, 5307, 5308}},
        {SpellID = 25016, Rank = 5, NPCs = {5291, 5349, 5708, 8336}},
        {SpellID = 25017, Rank = 6, NPCs = {11357, 11359}},
        -- Mine!
        {SpellID = 1265059, Rank = 1, NPCs = {270196, 270298, 276101}},
        {SpellID = 1265061, Rank = 3, NPCs = {272389}},
        -- Pinch
        {SpellID = 1264745, Rank = 1, NPCs = {1216, 2232, 2235, 2236}},
        {SpellID = 1264749, Rank = 2, NPCs = {4823, 12347}},
        {SpellID = 1264750, Rank = 3, NPCs = {922, 255901}},
        {SpellID = 1264751, Rank = 4, NPCs = {256807}},
        -- Prowl
        {SpellID = 24451, Rank = 1, NPCs = {684, 768, 2406, 2731}},
        {SpellID = 24454, Rank = 2, NPCs = {731, 1713, 2734}},
        {SpellID = 24455, Rank = 3, NPCs = {2522, 7432, 15067}},
        -- Savage Rend
        {SpellID = 1265831, Rank = 1, NPCs = {3255}},
        {SpellID = 1265833, Rank = 2, NPCs = {855, 1015, 1016, 1017, 1018, 1019, 1021, 1022, 1023, 260800}},
        {SpellID = 1265834, Rank = 3, NPCs = {687, 854, 2561, 4352, 4355, 4357}},
        -- Scorpid Poison
        {SpellID = 24641, Rank = 1, NPCs = {3127, 3226, 3250, 3252, 5823}},
        {SpellID = 24584, Rank = 2, NPCs = {4139, 4140, 4696, 4697, 4699, 5937, 7078}},
        {SpellID = 24588, Rank = 3, NPCs = {5422, 5423, 5424, 5988, 7405, 7803, 8926, 9691, 9695, 11735}},
        {SpellID = 24589, Rank = 4, NPCs = {9698, 11736, 11737, 14476}},
        -- Shell Shield
        {SpellID = 26065, Rank = 1, NPCs = {2408, 3653, 4824, 4825, 4887, 8213, 14223}},
        -- Slower Attack
        {SpellID = 1263113, NPCs = {251115}},
        -- Sonic Blast
        {SpellID = 1264483, Rank = 1, NPCs = {3866, 3868, 277882}},
        {SpellID = 1264484, Rank = 2, NPCs = {277881}},
        -- Swipe
        {SpellID = 1264727, Rank = 1, NPCs = {1188, 1797, 259388}},
        {SpellID = 1264729, Rank = 2, NPCs = {2356, 271334}},
        {SpellID = 1264730, Rank = 3, NPCs = {5268, 5272}},
        -- Tendon Rip
        {SpellID = 1265043, Rank = 1, NPCs = {4127, 4128, 4129, 4316}},
        {SpellID = 1265045, Rank = 2, NPCs = {4248, 4249, 4548}},
        {SpellID = 1265046, Rank = 3, NPCs = {5426}},
        -- Thunderstomp
        {SpellID = 26094, Rank = 1, NPCs = {1108, 1114}},
        {SpellID = 26189, Rank = 2, NPCs = {1557, 5262}},
        {SpellID = 26190, Rank = 3, NPCs = {6516, 9622}},
        -- Trickster's Dance
        {SpellID = 1310617, Rank = 1, NPCs = {277645}},
        -- Web
        {SpellID = 1265887, Rank = 1, NPCs = {217, 539, 1184, 1780, 3819, 250484, 256040}},
        {SpellID = 1265888, Rank = 2, NPCs = {930, 949, 2349, 3820}},
        {SpellID = 1265890, Rank = 3, NPCs = {858, 4377, 4378, 4379, 4414, 4415, 270664}},
    }

    local NPCAbilities = {}

    for _, Ability in ipairs(Abilities) do
        local SpellName = C_Spell.GetSpellName(Ability.SpellID)
        if SpellName then
            if Ability.Rank then
                local Rank = "|r [Rank " .. Ability.Rank .. "]"
                Ability.KnownLine = "|c" .. Private.E.AccentColour .. "Ability:|r |cFF40CC40" .. SpellName .. Rank
                Ability.UnknownLine = "|c" .. Private.E.AccentColour .. "Ability:|r |cFFCC4040" .. SpellName .. Rank
            else
                Ability.Line = "|c" .. Private.E.AccentColour .. "Ability:|r " .. SpellName
            end
            for _, NPCID in ipairs(Ability.NPCs) do
                NPCAbilities[NPCID] = NPCAbilities[NPCID] or {}
                table.insert(NPCAbilities[NPCID], Ability)
            end
        end
    end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(Tooltip, Data)
        local GUID = Data.guid
        if Tooltip ~= GameTooltip or Private:IsSecret(GUID) or not GUID then return end

        local UnitType, _, _, _, _, NPCID = strsplit("-", GUID)
        local NPCAbilityList = UnitType == "Creature" and NPCAbilities[tonumber(NPCID)]
        if not NPCAbilityList then return end

        for _, Ability in ipairs(NPCAbilityList) do
            local Line = Ability.Line or (C_SpellBook.IsSpellKnown(Ability.SpellID) and Ability.KnownLine or Ability.UnknownLine)
            Tooltip:AddLine(Line, 1, 1, 1)
        end
    end)
end
