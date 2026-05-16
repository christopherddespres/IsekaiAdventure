local _, addon = ...

local function PickLine(lines)
    if not lines or #lines == 0 then
        return nil
    end
    return lines[addon:Random(#lines)]
end

function addon:GetLines(trigger, companionID)
    companionID = companionID or self.db.currentCompanionID or "elyria"
    local companionLines = self.dialogue[companionID] or self.dialogue.elyria
    return companionLines and companionLines[trigger]
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
    if audioPath and not self.db.muted then
        PlaySoundFile(audioPath, "Dialog")
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

    local queued = table.remove(self.queue, 1)
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

    table.insert(self.queue, { line = line, trigger = trigger })
    self:PlayNextQueuedLine()
end

function addon:Say(trigger)
    if not self.db.enabled then
        return
    end

    local line = PickLine(self:GetLines(trigger))
    self:QueueLine(line, trigger)
end

function addon:SayQuestAccepted(questID, questTitle)
    if not self.db.enabled or not self:Chance(self.db.questChance) then
        return
    end

    local specificKey = questID and ("quest_" .. tostring(questID))
    local line = specificKey and PickLine(self:GetLines(specificKey)) or nil

    if not line then
        line = PickLine(self:GetLines("quest_accept"))
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

function addon:ScheduleIdleChatter()
    self.idleToken = self.idleToken + 1
    local token = self.idleToken

    if not self.db.idleChatter or not self.db.enabled then
        return
    end

    local minSeconds = self:Clamp(self.db.idleMinSeconds, 5, 3600)
    local maxSeconds = self:Clamp(self.db.idleMaxSeconds, minSeconds, 7200)
    local delay = addon:Random(minSeconds, maxSeconds)

    C_Timer.After(delay, function()
        if addon.idleToken ~= token then
            return
        end

        if addon.db.enabled and addon.db.idleChatter and not UnitIsDeadOrGhost("player") and not InCombatLockdown() then
            addon:Say("idle")
        end

        addon:ScheduleIdleChatter()
    end)
end
