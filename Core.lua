local addonName, addon = ...

IsekaiAdventure = addon
addon.name = addonName
addon.version = "0.1.0"
addon.mediaPath = "Interface\\AddOns\\IsekaiAdventure\\Media\\"

local SETTINGS_VERSION = 4

local DEFAULT_FRAME = {
    point = "LEFT",
    relativePoint = "LEFT",
    x = 80.02424621582031,
    y = 216.8075103759766,
}

local DEFAULT_LAYOUT = {
    character = { x = -3.809356689453125, y = 20.660888671875 },
    namePlate = { x = 112.8471832275391, y = 23.5869140625 },
    metaChip = { x = 99.63192749023438, y = -104.5867919921875 },
    dialogueBox = { x = -33.48089981079102, y = -80.44873046875 },
}

local VALID_POINTS = {
    TOPLEFT = true,
    TOP = true,
    TOPRIGHT = true,
    LEFT = true,
    CENTER = true,
    RIGHT = true,
    BOTTOMLEFT = true,
    BOTTOM = true,
    BOTTOMRIGHT = true,
}

local VOICE_CHANNELS = {
    { value = "Dialog", label = "Dialog" },
    { value = "Master", label = "Master" },
    { value = "SFX", label = "Sound Effects" },
    { value = "Ambience", label = "Ambience" },
    { value = "Music", label = "Music" },
}

local VALID_VOICE_CHANNELS = {}
for _, channel in ipairs(VOICE_CHANNELS) do
    VALID_VOICE_CHANNELS[channel.value] = channel.label
end

local defaults = {
    settingsVersion = SETTINGS_VERSION,
    enabled = true,
    visible = true,
    muted = false,
    locked = true,
    scale = 1,
    frame = DEFAULT_FRAME,
    layout = DEFAULT_LAYOUT,
    currentCompanionID = nil,
    lastMapID = nil,
    idleChatter = true,
    idleMinSeconds = 240,
    idleMaxSeconds = 520,
    questChance = 100,
    killChance = 12,
    killCooldownSeconds = 12,
    levelChance = 100,
    maxQueuedLines = 6,
    idleCooldownSeconds = 240,
    portraitAlpha = 1,
    subtitleSeconds = 7,
    subtitleFontSize = 14,
    dialogueBoxAlpha = 0.90,
    dialogueBoxColor = { r = 0.02, g = 0.018, b = 0.014 },
    voiceChannel = "Dialog",
    showBond = true,
    relationships = {},
    debugTaintLog = false,
    autoStartAutomation = true,
    debugStartup = false,
}

function addon:Debug(message)
    if self.db and self.db.debugStartup then
        self:Print("|cffb0ffb0debug:|r " .. tostring(message))
    end
end

addon.db = defaults
addon.companions = {}
addon.dialogue = {}
addon.mapCompanions = {}
addon.queue = {}
addon.isSpeaking = false
addon.idleToken = 0
addon.lastKillLineAt = 0

local function CopyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            CopyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

local function CopyTable(source)
    local target = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            target[key] = CopyTable(value)
        else
            target[key] = value
        end
    end
    return target
end

function addon:InitializeDatabase()
    IsekaiAdventureDB = IsekaiAdventureDB or {}
    if (IsekaiAdventureDB.settingsVersion or 0) < SETTINGS_VERSION then
        IsekaiAdventureDB.autoStartAutomation = true
        IsekaiAdventureDB.debugStartup = false
        IsekaiAdventureDB.settingsVersion = SETTINGS_VERSION
    end

    CopyDefaults(defaults, IsekaiAdventureDB)
    self.db = IsekaiAdventureDB
    self:NormalizeDatabase()
end

function addon:GetDefaultFrameConfig()
    return DEFAULT_FRAME
end

function addon:GetDefaultLayoutConfig()
    return DEFAULT_LAYOUT
end

function addon:NormalizeDatabase()
    local db = self.db or defaults

    if type(db.enabled) ~= "boolean" then db.enabled = defaults.enabled end
    if type(db.visible) ~= "boolean" then db.visible = defaults.visible end
    if type(db.muted) ~= "boolean" then db.muted = defaults.muted end
    if type(db.locked) ~= "boolean" then db.locked = defaults.locked end
    if type(db.idleChatter) ~= "boolean" then db.idleChatter = defaults.idleChatter end
    if type(db.debugTaintLog) ~= "boolean" then db.debugTaintLog = defaults.debugTaintLog end
    if type(db.autoStartAutomation) ~= "boolean" then db.autoStartAutomation = defaults.autoStartAutomation end
    if type(db.debugStartup) ~= "boolean" then db.debugStartup = defaults.debugStartup end
    if type(db.showBond) ~= "boolean" then db.showBond = defaults.showBond end

    db.scale = self:Clamp(db.scale, 0.6, 1.8)
    db.idleMinSeconds = self:Clamp(db.idleMinSeconds, 5, 3600)
    db.idleMaxSeconds = self:Clamp(db.idleMaxSeconds, db.idleMinSeconds, 7200)
    db.questChance = self:Clamp(db.questChance, 0, 100)
    db.killChance = self:Clamp(db.killChance, 0, 100)
    db.levelChance = self:Clamp(db.levelChance, 0, 100)
    db.killCooldownSeconds = self:Clamp(db.killCooldownSeconds, 0, 300)
    db.maxQueuedLines = self:Clamp(db.maxQueuedLines, 1, 20)
    db.idleCooldownSeconds = self:Clamp(db.idleCooldownSeconds or db.idleMinSeconds, 5, 3600)
    if db.idleMinSeconds < db.idleCooldownSeconds then
        db.idleMinSeconds = db.idleCooldownSeconds
    end
    if db.idleMaxSeconds < db.idleMinSeconds then
        db.idleMaxSeconds = db.idleMinSeconds
    end
    db.portraitAlpha = self:Clamp(db.portraitAlpha, 0, 1)
    db.subtitleSeconds = self:Clamp(db.subtitleSeconds, 1, 30)
    db.subtitleFontSize = self:Clamp(db.subtitleFontSize, 10, 24)
    db.dialogueBoxAlpha = self:Clamp(db.dialogueBoxAlpha, 0.2, 1)
    if type(db.voiceChannel) ~= "string" or not VALID_VOICE_CHANNELS[db.voiceChannel] then
        db.voiceChannel = defaults.voiceChannel
    end

    if type(db.dialogueBoxColor) ~= "table" then db.dialogueBoxColor = {} end
    CopyDefaults(defaults.dialogueBoxColor, db.dialogueBoxColor)
    db.dialogueBoxColor.r = self:Clamp(db.dialogueBoxColor.r, 0, 1)
    db.dialogueBoxColor.g = self:Clamp(db.dialogueBoxColor.g, 0, 1)
    db.dialogueBoxColor.b = self:Clamp(db.dialogueBoxColor.b, 0, 1)

    if type(db.frame) ~= "table" then db.frame = {} end
    CopyDefaults(DEFAULT_FRAME, db.frame)
    if not VALID_POINTS[db.frame.point] then db.frame.point = DEFAULT_FRAME.point end
    if not VALID_POINTS[db.frame.relativePoint] then db.frame.relativePoint = DEFAULT_FRAME.relativePoint end
    db.frame.x = tonumber(db.frame.x) or DEFAULT_FRAME.x
    db.frame.y = tonumber(db.frame.y) or DEFAULT_FRAME.y

    if type(db.layout) ~= "table" then db.layout = {} end
    CopyDefaults(DEFAULT_LAYOUT, db.layout)
    for key, layout in pairs(DEFAULT_LAYOUT) do
        if type(db.layout[key]) ~= "table" then db.layout[key] = {} end
        db.layout[key].x = tonumber(db.layout[key].x) or layout.x
        db.layout[key].y = tonumber(db.layout[key].y) or layout.y
    end

    if db.currentCompanionID and not self.companions[db.currentCompanionID] then
        db.currentCompanionID = nil
    end

    if type(db.relationships) ~= "table" then db.relationships = {} end
end

function addon:GetVoiceChannels()
    return VOICE_CHANNELS
end

function addon:GetVoiceChannelLabel(channel)
    return VALID_VOICE_CHANNELS[channel or ""] or tostring(channel or "Dialog")
end

function addon:ResetSavedSettings()
    IsekaiAdventureDB = CopyTable(defaults)
    self.db = IsekaiAdventureDB
    self:NormalizeDatabase()
    self.queue = {}
    self.isSpeaking = false
    self.idleToken = (self.idleToken or 0) + 1
    self.bondToken = (self.bondToken or 0) + 1

    if self.frame then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(self.db.frame.point, UIParent, self.db.frame.relativePoint, self.db.frame.x, self.db.frame.y)
        self:ApplyLayoutPositions()
        self:ApplyDialogueStyle()
        self:UpdateCompanionFrame()
    end

    self:RefreshZoneCompanion("reset")
    self:ScheduleIdleChatter()
    if self.ScheduleBondTimeTick then
        self:ScheduleBondTimeTick()
    end
end

function addon:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd98cffIsekai Adventure:|r " .. tostring(message))
end

function addon:Clamp(value, minValue, maxValue)
    value = tonumber(value) or minValue
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

function addon:Chance(percent)
    percent = self:Clamp(percent or 0, 0, 100)
    return self:Random(100) <= percent
end

function addon:Random(minValue, maxValue)
    if maxValue == nil then
        if random then
            return random(minValue)
        end
        return math.random(minValue)
    end

    if random then
        return random(minValue, maxValue)
    end
    return math.random(minValue, maxValue)
end

function addon:GetMapID()
    if C_Map and C_Map.GetBestMapForUnit then
        return C_Map.GetBestMapForUnit("player")
    end
    return nil
end

function addon:GetZoneName(mapID)
    mapID = mapID or self:GetMapID()
    if mapID and C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name then
            return info.name
        end
    end
    return GetZoneText() or UNKNOWN
end

function addon:GetCompanion(companionID)
    return self.companions[companionID] or self.companions.elyria
end

function addon:GetCompanionForMap(mapID)
    if mapID and self.mapCompanions[mapID] then
        return self.mapCompanions[mapID]
    end

    local ordered = self.companionOrder or {}
    if mapID and #ordered > 0 then
        local index = (mapID % #ordered) + 1
        return ordered[index]
    end

    return "elyria"
end

function addon:SetCompanion(companionID, reason)
    local companion = self:GetCompanion(companionID)
    if not companion then
        return
    end

    local oldCompanionID = self.db.currentCompanionID
    self.db.currentCompanionID = companion.id

    if self.UpdateCompanionFrame then
        self:UpdateCompanionFrame()
    end

    if oldCompanionID ~= companion.id and reason == "zone" then
        self:Say("zone_intro")
    end
end

function addon:RefreshZoneCompanion(reason)
    local mapID = self:GetMapID()
    self.db.lastMapID = mapID
    self:SetCompanion(self:GetCompanionForMap(mapID), reason or "zone")
end
