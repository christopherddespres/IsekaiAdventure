local _, addon = ...

addon.companionOrder = {
    "elyria",
    "mika",
    "sera",
    "kaori",
    "rin",
    "lyra",
}

addon.companions = {
    elyria = {
        id = "elyria",
        name = "Elyria Dawnspell",
        title = "Reincarnation Guide",
        color = { 1.00, 0.70, 0.95 },
        portrait = addon.mediaPath .. "Portraits\\elyria.tga",
        voicePath = addon.mediaPath .. "Voice\\Elyria\\",
    },
    mika = {
        id = "mika",
        name = "Mika Starbloom",
        title = "Cheerful Field Mage",
        color = { 0.65, 0.90, 1.00 },
        portrait = addon.mediaPath .. "Portraits\\mika.tga",
        voicePath = addon.mediaPath .. "Voice\\Mika\\",
    },
    sera = {
        id = "sera",
        name = "Sera Moonvale",
        title = "Soft-Spoken Ranger",
        color = { 0.75, 1.00, 0.70 },
        portrait = addon.mediaPath .. "Portraits\\sera.tga",
        voicePath = addon.mediaPath .. "Voice\\Sera\\",
    },
    kaori = {
        id = "kaori",
        name = "Kaori Emberheart",
        title = "Battle Senpai",
        color = { 1.00, 0.55, 0.45 },
        portrait = addon.mediaPath .. "Portraits\\kaori.tga",
        voicePath = addon.mediaPath .. "Voice\\Kaori\\",
    },
    rin = {
        id = "rin",
        name = "Rin Gearwhisper",
        title = "Inventor Companion",
        color = { 1.00, 0.85, 0.45 },
        portrait = addon.mediaPath .. "Portraits\\rin.tga",
        voicePath = addon.mediaPath .. "Voice\\Rin\\",
    },
    lyra = {
        id = "lyra",
        name = "Lyra Ashpetal",
        title = "Mysterious Shrine Maiden",
        color = { 0.78, 0.68, 1.00 },
        portrait = addon.mediaPath .. "Portraits\\lyra.tga",
        voicePath = addon.mediaPath .. "Voice\\Lyra\\",
    },
}

-- Explicit zone assignments. Any unmapped zone still gets a stable companion based on mapID.
addon.mapCompanions = {
    [1409] = "elyria", -- Exile's Reach
    [84] = "elyria", -- Stormwind City
    [85] = "mika", -- Orgrimmar
    [2022] = "sera", -- The Waking Shores
    [2023] = "kaori", -- Ohn'ahran Plains
    [2024] = "rin", -- The Azure Span
    [2025] = "lyra", -- Thaldraszus
    [2112] = "mika", -- Valdrakken
    [2214] = "elyria", -- The Ringing Deeps
    [2215] = "sera", -- Hallowfall
    [2255] = "kaori", -- Azj-Kahet
    [2248] = "rin", -- Isle of Dorn
}
