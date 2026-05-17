local _, addon = ...

addon.companionOrder = {
    "seraphine",
    "maribel",
    "elyria",
    "mika",
    "sera",
    "kaori",
    "rin",
    "lyra",
}

addon.companions = {
    seraphine = {
        id = "seraphine",
        name = "Seraphine Applebrook",
        title = "Elwynn Blossom Mage",
        race = "Human",
        gender = "Female",
        color = { 1.00, 0.82, 0.52 },
        portrait = addon.mediaPath .. "Portraits\\seraphine.tga",
        characterArt = addon.mediaPath .. "Portraits\\seraphine_full.tga",
        characterTexCoord = { 0, 1, 0.226562, 1 },
        characterHeight = 390,
        voicePath = addon.mediaPath .. "Voice\\Seraphine\\",
    },
    maribel = {
        id = "maribel",
        name = "Maribel Dustwhisper",
        title = "Westfall Survival Scout",
        race = "Human",
        gender = "Female",
        color = { 0.95, 0.64, 0.32 },
        portrait = addon.mediaPath .. "Portraits\\maribel.tga",
        characterArt = addon.mediaPath .. "Portraits\\maribel_full.tga",
        characterTexCoord = { 0, 1, 0.08, 1 },
        characterHeight = 390,
        voicePath = addon.mediaPath .. "Voice\\Maribel\\",
    },
    cedric = {
        id = "cedric",
        name = "Cedric Applebrook",
        title = "Elwynn Novice Protector",
        race = "Human",
        gender = "Male",
        color = { 0.70, 0.86, 1.00 },
        portrait = addon.mediaPath .. "Portraits\\cedric.tga",
        characterArt = addon.mediaPath .. "Portraits\\cedric_full.tga",
        characterTexCoord = { 0, 1, 0.08, 1 },
        characterHeight = 390,
        voicePath = addon.mediaPath .. "Voice\\Cedric\\",
    },
    elyria = {
        id = "elyria",
        name = "Elyria Dawnspell",
        title = "Reincarnation Guide",
        race = "Human",
        gender = "Female",
        color = { 1.00, 0.70, 0.95 },
        portrait = addon.mediaPath .. "Portraits\\elyria.tga",
        voicePath = addon.mediaPath .. "Voice\\Elyria\\",
    },
    mika = {
        id = "mika",
        name = "Mika Starbloom",
        title = "Cheerful Field Mage",
        race = "Draenei",
        gender = "Female",
        color = { 0.65, 0.90, 1.00 },
        portrait = addon.mediaPath .. "Portraits\\mika.tga",
        voicePath = addon.mediaPath .. "Voice\\Mika\\",
    },
    sera = {
        id = "sera",
        name = "Sera Moonvale",
        title = "Soft-Spoken Ranger",
        race = "Night Elf",
        gender = "Female",
        color = { 0.75, 1.00, 0.70 },
        portrait = addon.mediaPath .. "Portraits\\sera.tga",
        voicePath = addon.mediaPath .. "Voice\\Sera\\",
    },
    kaori = {
        id = "kaori",
        name = "Kaori Emberheart",
        title = "Battle Senpai",
        race = "Blood Elf",
        gender = "Female",
        color = { 1.00, 0.55, 0.45 },
        portrait = addon.mediaPath .. "Portraits\\kaori.tga",
        voicePath = addon.mediaPath .. "Voice\\Kaori\\",
    },
    rin = {
        id = "rin",
        name = "Rin Gearwhisper",
        title = "Inventor Companion",
        race = "Gnome",
        gender = "Female",
        color = { 1.00, 0.85, 0.45 },
        portrait = addon.mediaPath .. "Portraits\\rin.tga",
        voicePath = addon.mediaPath .. "Voice\\Rin\\",
    },
    lyra = {
        id = "lyra",
        name = "Lyra Ashpetal",
        title = "Mysterious Shrine Maiden",
        race = "Void Elf",
        gender = "Female",
        color = { 0.78, 0.68, 1.00 },
        portrait = addon.mediaPath .. "Portraits\\lyra.tga",
        voicePath = addon.mediaPath .. "Voice\\Lyra\\",
    },
}

-- Explicit zone assignments. Any unmapped zone still gets a stable companion based on mapID.
addon.mapCompanions = {
    [37] = { female = "seraphine", male = "cedric" }, -- Elwynn Forest
    [425] = { female = "seraphine", male = "cedric" }, -- Northshire
    [52] = "maribel", -- Westfall
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
