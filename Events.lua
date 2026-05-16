local _, addon = ...

local eventFrame = CreateFrame("Frame")
addon.eventFrame = eventFrame
addon.recentDamage = addon.recentDamage or {}
addon.automationRegistered = false

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
    if now - (addon.lastKillLineAt or 0) < (addon.db.killCooldownSeconds or 12) then
        return
    end

    if addon:Chance(addon.db.killChance) then
        addon.lastKillLineAt = now
        addon:Say("kill")
    end
end

local function RegisterOptionsPanel()
    if addon.RegisterOptionsPanel then
        addon:RegisterOptionsPanel()
    end
end

local function QueueStartup(reason)
    if addon.started or addon.startupScheduled then
        return
    end

    addon.startupScheduled = true
    C_Timer.After(2, function()
        addon.startupScheduled = false
        if not addon.db or not addon.db.autoStartAutomation or addon.started then
            return
        end

        addon:StartAutomation(reason or "login")
        if addon.db.visible then
            addon:EnsureCompanionFrame()
        end
        addon:Print("loaded. Type /isekai options for settings.")
    end)
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName ~= addon.name then
            return
        end

        addon:InitializeDatabase()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if addon.db and addon.db.autoStartAutomation then
            QueueStartup("entering_world")
        end
    elseif event == "PLAYER_LOGIN" then
        RegisterOptionsPanel()

        if addon.db.autoStartAutomation then
            QueueStartup("login")
        else
            addon:Print("loaded. Type /isekai start to enable quest/kill/idle automation, or /isekai show to open the overlay.")
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        if addon.started then
            addon:RefreshZoneCompanion()
        else
            addon:RefreshZoneCompanion("login")
        end
    elseif event == "QUEST_ACCEPTED" then
        HandleQuestAccepted(...)
    elseif event == "PLAYER_LEVEL_UP" then
        if addon:Chance(addon.db.levelChance) then
            addon:Say("level_up")
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        addon.wasInCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        if addon.wasInCombat and not UnitIsDeadOrGhost("player") then
            addon.wasInCombat = false
            TryKillChatter()
        end
        addon:ResumeQueuedDialogue()
    end
end)

function addon:RegisterAutomationEvent(eventName)
    if self.registeredAutomationEvents[eventName] then
        return
    end

    self.registeredAutomationEvents[eventName] = true
    eventFrame:RegisterEvent(eventName)
    self:Debug("registered " .. eventName)
end

function addon:RegisterAutomationEvents()
    if self.automationRegistered then
        return
    end

    self.automationRegistered = true
    self.registeredAutomationEvents = self.registeredAutomationEvents or {}
    self:RegisterAutomationEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterAutomationEvent("ZONE_CHANGED")
    self:RegisterAutomationEvent("ZONE_CHANGED_INDOORS")
    self:RegisterAutomationEvent("QUEST_ACCEPTED")
    self:RegisterAutomationEvent("PLAYER_LEVEL_UP")
    self:RegisterAutomationEvent("PLAYER_REGEN_DISABLED")
    self:RegisterAutomationEvent("PLAYER_REGEN_ENABLED")
end

function addon:StartAutomation(reason)
    self.registeredAutomationEvents = self.registeredAutomationEvents or {}
    self:Debug("automation start")
    self:RegisterAutomationEvents()
    self:Debug("refresh companion")
    if self.NormalizeDatabase then
        self:NormalizeDatabase()
    end

    self.started = true
    self:RefreshZoneCompanion(reason or "login")
    self:Debug("schedule idle")
    self:ScheduleIdleChatter()
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
