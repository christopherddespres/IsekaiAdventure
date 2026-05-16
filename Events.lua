local _, addon = ...

local eventFrame = CreateFrame("Frame")
addon.eventFrame = eventFrame

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

local function HandleCombatLog()
    local _, subevent, _, sourceGUID = CombatLogGetCurrentEventInfo()
    if subevent ~= "PARTY_KILL" then
        return
    end

    if sourceGUID ~= UnitGUID("player") then
        return
    end

    local now = GetTime()
    if now - (addon.lastKillLineAt or 0) < 12 then
        return
    end

    if addon:Chance(addon.db.killChance) then
        addon.lastKillLineAt = now
        addon:Say("kill")
    end
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName ~= addon.name then
            return
        end

        math.randomseed(time())
        addon:InitializeDatabase()
        addon:CreateCompanionFrame()
        addon:RefreshZoneCompanion()
        addon:ScheduleIdleChatter()
        addon:Print("loaded. Type /isekai for commands.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        addon:RefreshZoneCompanion()
        addon:ScheduleIdleChatter()
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        addon:RefreshZoneCompanion()
    elseif event == "QUEST_ACCEPTED" then
        HandleQuestAccepted(...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandleCombatLog()
    elseif event == "PLAYER_LEVEL_UP" then
        if addon:Chance(addon.db.levelChance) then
            addon:Say("level_up")
        end
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("ZONE_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
eventFrame:RegisterEvent("QUEST_ACCEPTED")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

