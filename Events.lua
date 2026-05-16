local _, addon = ...

local eventFrame = CreateFrame("Frame")
addon.eventFrame = eventFrame
addon.recentDamage = addon.recentDamage or {}

local DAMAGE_EVENTS = {
    SWING_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    SPELL_BUILDING_DAMAGE = true,
    DAMAGE_SHIELD = true,
    DAMAGE_SPLIT = true,
}

local DEATH_EVENTS = {
    PARTY_KILL = true,
    UNIT_DIED = true,
    UNIT_DESTROYED = true,
    UNIT_DISSIPATES = true,
}

local function IsMine(sourceGUID, sourceFlags)
    if sourceGUID and sourceGUID == UnitGUID("player") then
        return true
    end

    if sourceGUID and UnitGUID("pet") and sourceGUID == UnitGUID("pet") then
        return true
    end

    if sourceGUID and UnitGUID("vehicle") and sourceGUID == UnitGUID("vehicle") then
        return true
    end

    if sourceFlags and bit and COMBATLOG_OBJECT_AFFILIATION_MINE then
        return bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
    end

    return false
end

local function GetQuestTitleFromEvent(questID, questLogIndex)
    if questID and C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local title = C_QuestLog.GetTitleForQuestID(questID)
        if title then
            return title
        end
    end

    if questLogIndex and GetQuestLogTitle then
        local title = GetQuestLogTitle(questLogIndex)
        if title then
            return title
        end
    end

    return nil
end

local function HandleQuestAccepted(...)
    local first, second = ...
    local questID
    local questLogIndex

    if type(first) == "number" and first > 1000 then
        questID = first
    elseif type(second) == "number" and second > 1000 then
        questLogIndex = first
        questID = second
    else
        questLogIndex = first
        questID = second
    end

    addon:SayQuestAccepted(questID, GetQuestTitleFromEvent(questID, questLogIndex))
end

local function TryKillChatter()
    local now = GetTime()
    if now - (addon.lastKillLineAt or 0) < 12 then
        return
    end

    if addon:Chance(addon.db.killChance) then
        addon.lastKillLineAt = now
        addon:Say("kill")
    end
end

local function HandleCombatLog()
    local _, subevent, _, sourceGUID, _, sourceFlags, _, destGUID = CombatLogGetCurrentEventInfo()
    local now = GetTime()

    if DAMAGE_EVENTS[subevent] and destGUID and IsMine(sourceGUID, sourceFlags) then
        addon.recentDamage[destGUID] = now
        return
    end

    if not DEATH_EVENTS[subevent] or not destGUID then
        return
    end

    if subevent == "PARTY_KILL" and IsMine(sourceGUID, sourceFlags) then
        addon.recentDamage[destGUID] = nil
        TryKillChatter()
        return
    end

    local lastDamageAt = addon.recentDamage[destGUID]
    if lastDamageAt and now - lastDamageAt <= 30 then
        addon.recentDamage[destGUID] = nil
        TryKillChatter()
    end
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName ~= addon.name then
            return
        end

        addon:InitializeDatabase()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if addon.started then
            addon:RefreshZoneCompanion("zone")
            addon:ScheduleIdleChatter()
        else
            addon.started = true
            addon:RefreshZoneCompanion("login")
            addon:ScheduleIdleChatter()
            addon:Print("loaded. Type /isekai show to open the overlay.")
        end
    elseif event == "PLAYER_LOGIN" then
        -- Keep startup quiet. Options are registered lazily when /isekai options is used.
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        if addon.started then
            addon:RefreshZoneCompanion()
        else
            addon:RefreshZoneCompanion("login")
        end
    elseif event == "QUEST_ACCEPTED" then
        HandleQuestAccepted(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandleCombatLog()
    elseif event == "PLAYER_LEVEL_UP" then
        if addon:Chance(addon.db.levelChance) then
            addon:Say("level_up")
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        addon:ResumeQueuedDialogue()
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
