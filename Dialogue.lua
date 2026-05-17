local _, addon = ...

local function PickLine(lines)
    if not lines or #lines == 0 then
        return nil
    end
    return lines[addon:Random(#lines)]
end

function addon:ChooseLine(trigger, companionID)
    return PickLine(self:GetLinePool(trigger, companionID))
end

function addon:GetLines(trigger, companionID)
    companionID = companionID or self.db.currentCompanionID or "elyria"
    local companionLines = self.dialogue[companionID] or self.dialogue.elyria
    local lines = companionLines and companionLines[trigger]
    if (not lines or #lines == 0) and companionID ~= "elyria" and self.dialogue.elyria then
        lines = self.dialogue.elyria[trigger]
    end
    return lines
end

local function AddLines(pool, lines)
    if not lines then
        return
    end

    for _, line in ipairs(lines) do
        pool[#pool + 1] = line
    end
end

function addon:GetBondLineKeys(trigger, companionID)
    local hearts = self.GetBondHearts and self:GetBondHearts(companionID) or 0
    local keys = {}

    if trigger == "kill" then
        for _, threshold in ipairs({ 2, 4, 6, 8, 10 }) do
            if hearts >= threshold then
                keys[#keys + 1] = "bond_kill_" .. threshold
            end
        end
    elseif trigger == "idle" then
        for _, threshold in ipairs({ 1, 3, 5, 7, 9 }) do
            if hearts >= threshold then
                keys[#keys + 1] = "bond_idle_" .. threshold
            end
        end
    end

    return keys
end

function addon:GetLinePool(trigger, companionID)
    companionID = companionID or self.db.currentCompanionID or "elyria"
    local pool = {}
    AddLines(pool, self:GetLines(trigger, companionID))

    for _, key in ipairs(self:GetBondLineKeys(trigger, companionID)) do
        AddLines(pool, self:GetLines(key, companionID))
    end

    return pool
end

function addon:GetAudioPath(companion, line)
    if not companion or not line or not line.audio or line.audio == "" then
        return nil
    end

    if line.audio:find("\\") or line.audio:find("/") then
        return line.audio
    end

    return (companion.voicePath or "") .. line.audio
end

function addon:PlayLine(line, trigger)
    if not line then
        return
    end

    local companion = self:GetCompanion(self.db.currentCompanionID)
    local name = companion and companion.name or "Companion"
    local text = line.text or ""
    local duration = tonumber(line.duration) or self.db.subtitleSeconds or 7

    self:SetSubtitle(text, duration)
    self:Print("|cffffd6ff" .. name .. ":|r " .. text)

    local audioPath = self:GetAudioPath(companion, line)
    if audioPath and not self.db.muted and PlaySoundFile then
        PlaySoundFile(audioPath, self.db.voiceChannel or "Dialog")
    end

    C_Timer.After(duration, function()
        addon.isSpeaking = false
        addon:PlayNextQueuedLine()
    end)
end

function addon:PlayNextQueuedLine()
    if self.isSpeaking or not self.db.enabled then
        return
    end

    local queued = self.queue[1]
    if not queued then
        return
    end

    if InCombatLockdown and InCombatLockdown() and queued.trigger ~= "low_health" and queued.trigger ~= "death" then
        return
    end

    queued = table.remove(self.queue, 1)
    if not queued then
        return
    end

    self.isSpeaking = true
    self:PlayLine(queued.line, queued.trigger)
end

function addon:QueueLine(line, trigger)
    if not line or not self.db.enabled then
        return
    end

    local maxQueuedLines = self.db.maxQueuedLines or 6
    while #self.queue >= maxQueuedLines do
        table.remove(self.queue, 1)
    end

    local queued = { line = line, trigger = trigger, queuedAt = GetTime and GetTime() or 0 }
    if trigger == "low_health" or trigger == "death" then
        table.insert(self.queue, 1, queued)
    else
        table.insert(self.queue, queued)
    end
    self:PlayNextQueuedLine()
end

function addon:ResumeQueuedDialogue()
    if self.db.enabled then
        self:PlayNextQueuedLine()
    end
end

function addon:Say(trigger)
    if not self.db.enabled then
        return
    end

    local line = self:ChooseLine(trigger)
    self:QueueLine(line, trigger)
end

function addon:SayText(text, duration, trigger)
    if not self.db.enabled or not text or text == "" then
        return
    end

    self:QueueLine({
        text = text,
        duration = duration or self.db.subtitleSeconds or 7,
    }, trigger or "manual")
end

function addon:SayQuestAccepted(questID, questTitle)
    if not self.db.enabled or not self:Chance(self.db.questChance) then
        return
    end

    local specificKey = questID and ("quest_" .. tostring(questID))
    local line = specificKey and self:ChooseLine(specificKey) or nil

    if not line then
        line = self:ChooseLine("quest_accept")
    end

    if line and questTitle and questTitle ~= "" then
        line = {
            text = line.text:gsub("%%q", questTitle),
            audio = line.audio,
            duration = line.duration,
        }
    end

    self:QueueLine(line, "quest_accept")
end

function addon:SayQuestComplete(questID)
    if not self.db.enabled or not self:Chance(self.db.questCompleteChance) then
        return
    end

    local specificKey = questID and ("quest_complete_" .. tostring(questID))
    local line = specificKey and self:ChooseLine(specificKey) or nil

    if not line then
        line = self:ChooseLine("quest_complete")
    end

    self:QueueLine(line, "quest_complete")
end

function addon:ScheduleIdleChatter()
    self.idleToken = self.idleToken + 1
    local token = self.idleToken

    if not self.db.idleChatter or not self.db.enabled then
        self.nextIdleAt = nil
        return
    end

    local minSeconds = self:Clamp(self.db.idleMinSeconds, 5, 3600)
    local maxSeconds = self:Clamp(self.db.idleMaxSeconds, minSeconds, 7200)
    local delay = addon:Random(minSeconds, maxSeconds)
    self.nextIdleAt = (GetTime and GetTime() or 0) + delay

    C_Timer.After(delay, function()
        if addon.idleToken ~= token then
            return
        end

        if addon.db.enabled and addon.db.idleChatter and not UnitIsDeadOrGhost("player") and not InCombatLockdown() then
            addon.lastIdleLineAt = GetTime and GetTime() or 0
            addon:Say("idle")
        end

        addon:ScheduleIdleChatter()
    end)
end

function addon:GetSubzoneDialogueKey(mapID, subzoneName)
    if not mapID or not subzoneName or subzoneName == "" then
        return nil
    end

    local mapSubzones = self.subzones and self.subzones[mapID]
    return mapSubzones and mapSubzones[subzoneName] or nil
end

function addon:MarkSubzoneVisited(companionID, mapID, key)
    self.db.visitedSubzones = self.db.visitedSubzones or {}
    local companionVisits = self.db.visitedSubzones[companionID]
    if type(companionVisits) ~= "table" then
        companionVisits = {}
        self.db.visitedSubzones[companionID] = companionVisits
    end

    local mapVisits = companionVisits[mapID]
    if type(mapVisits) ~= "table" then
        mapVisits = {}
        companionVisits[mapID] = mapVisits
    end

    if mapVisits[key] then
        return false
    end

    mapVisits[key] = true
    return true
end

function addon:TrySubzoneVisitLine()
    if not self.db.enabled or not self:Chance(self.db.subzoneChance) then
        return
    end

    local now = GetTime and GetTime() or 0
    if now - (self.lastSubzoneLineAt or 0) < (self.db.subzoneCooldownSeconds or 90) then
        return
    end

    local mapID = self:GetMapID()
    local subzoneName = GetSubZoneText and GetSubZoneText() or nil
    local key = self:GetSubzoneDialogueKey(mapID, subzoneName)
    if not key then
        return
    end

    local companionID = self.db.currentCompanionID
    if not self:MarkSubzoneVisited(companionID, mapID, key) then
        return
    end

    local line = self:ChooseLine(key, companionID)
    if line then
        self.lastSubzoneLineAt = now
        self:QueueLine(line, key)
    end
end
