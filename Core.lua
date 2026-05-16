local addonName, addon = ...

IsekaiAdventure = addon
addon.name = addonName
addon.version = "0.1.0"
addon.mediaPath = "Interface\\AddOns\\IsekaiAdventure\\Media\\"

local defaults = {
    enabled = true,
    visible = true,
    muted = false,
    locked = true,
    scale = 1,
    frame = {
        point = "LEFT",
        relativePoint = "LEFT",
        x = 80.02424621582031,
        y = 216.8075103759766,
    },
    layout = {
        character = { x = -3.809356689453125, y = 20.660888671875 },
        namePlate = { x = 112.8471832275391, y = 23.5869140625 },
        metaChip = { x = 99.63192749023438, y = -104.5867919921875 },
        dialogueBox = { x = -33.48089981079102, y = -80.44873046875 },
    },
    currentCompanionID = nil,
    lastMapID = nil,
    idleChatter = true,
    idleMinSeconds = 240,
    idleMaxSeconds = 520,
    questChance = 100,
    killChance = 12,
    levelChance = 100,
    portraitAlpha = 1,
    subtitleSeconds = 7,
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

function addon:InitializeDatabase()
    IsekaiAdventureDB = IsekaiAdventureDB or {}
    CopyDefaults(defaults, IsekaiAdventureDB)
    self.db = IsekaiAdventureDB
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
