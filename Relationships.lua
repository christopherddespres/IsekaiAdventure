local _, addon = ...

local POINTS_PER_HEART = 100
local MAX_HEARTS = 10
local MAX_POINTS = POINTS_PER_HEART * MAX_HEARTS
local BOND_THRESHOLDS = { 2, 4, 6, 8, 10 }
local ROMANCE_THRESHOLDS = { 2, 4, 6, 8, 10 }
local ROMANCE_ATTEMPT_COOLDOWN = 8

local BOND_REASONS = {
    quest_complete = 7,
    level_up = 20,
    time_together = 5,
    manual_summon = 1,
}

local function EnsureRelationshipStore()
    addon.db.relationships = addon.db.relationships or {}
    return addon.db.relationships
end

function addon:GetRelationship(companionID)
    companionID = companionID or self.db.currentCompanionID
    if not companionID then
        return nil
    end

    local relationships = EnsureRelationshipStore()
    if type(relationships[companionID]) ~= "table" then
        relationships[companionID] = {
            points = 0,
            unlocked = {},
        }
    end

    local relationship = relationships[companionID]
    relationship.points = self:Clamp(relationship.points or 0, 0, MAX_POINTS)
    relationship.romanceRank = self:Clamp(relationship.romanceRank or 0, 0, MAX_HEARTS)
    relationship.romanceAttempts = tonumber(relationship.romanceAttempts) or 0
    relationship.romanceStopCount = tonumber(relationship.romanceStopCount) or 0
    relationship.lastRomanceAttemptAt = tonumber(relationship.lastRomanceAttemptAt) or 0
    if type(relationship.unlocked) ~= "table" then
        relationship.unlocked = {}
    end

    return relationship
end

function addon:GetBondPoints(companionID)
    local relationship = self:GetRelationship(companionID)
    return relationship and relationship.points or 0
end

function addon:GetBondHearts(companionID)
    return math.floor(self:GetBondPoints(companionID) / POINTS_PER_HEART)
end

function addon:GetBondProgress(companionID)
    local points = self:GetBondPoints(companionID)
    local hearts = math.floor(points / POINTS_PER_HEART)
    local intoHeart = points % POINTS_PER_HEART

    if hearts >= MAX_HEARTS then
        hearts = MAX_HEARTS
        intoHeart = POINTS_PER_HEART
    end

    return hearts, intoHeart, POINTS_PER_HEART, points, MAX_POINTS
end

function addon:GetBondLabel(companionID)
    local hearts, intoHeart, pointsPerHeart = self:GetBondProgress(companionID)
    if hearts >= MAX_HEARTS then
        return "Bond: 10/10 hearts"
    end

    return "Bond: " .. hearts .. "/10 hearts - " .. intoHeart .. "/" .. pointsPerHeart
end

function addon:GetDisplayedBondHearts(companionID)
    local hearts = self:GetBondHearts(companionID)
    return self:Clamp(hearts, 0, MAX_HEARTS)
end

function addon:GetRomanceRank(companionID)
    local relationship = self:GetRelationship(companionID)
    return relationship and relationship.romanceRank or 0
end

function addon:GetNextRomanceThreshold(companionID)
    local rank = self:GetRomanceRank(companionID)
    for _, threshold in ipairs(ROMANCE_THRESHOLDS) do
        if rank < threshold then
            return threshold
        end
    end
    return nil
end

local function QueueRomanceFallback(key, threshold)
    if key == "romance_not_ready" then
        addon:SayText("I'm not ready for that yet. Stay with me a little longer, okay?", 5.2, key)
    elseif key == "romance_repeat" then
        addon:SayText("We've already shared that moment. Let us keep walking forward together.", 5.2, key)
    elseif key == "romance_stop" then
        addon:SayText("I understand. Let us take a step back, and keep walking as companions.", 5.4, key)
    else
        addon:SayText("My heart is trying to find the words. Give me just a little more time.", 5.0, key or ("romance_" .. tostring(threshold or "")))
    end
end

function addon:TryRomanceCurrentCompanion()
    if not self.db.enabled then
        self:Print("companion dialogue is disabled.")
        return
    end

    local companionID = self.db.currentCompanionID
    local companion = self:GetCompanion(companionID)
    if not companion then
        return
    end

    local relationship = self:GetRelationship(companionID)
    local now = GetTime and GetTime() or 0
    if now - (relationship.lastRomanceAttemptAt or 0) < ROMANCE_ATTEMPT_COOLDOWN then
        self:Print("give " .. companion.name .. " a moment before trying again.")
        return
    end

    relationship.romanceAttempts = (relationship.romanceAttempts or 0) + 1
    relationship.lastRomanceAttemptAt = now

    local nextThreshold = self:GetNextRomanceThreshold(companionID)
    if not nextThreshold then
        local line = self:ChooseLine("romance_repeat", companionID)
        if line then
            self:QueueLine(line, "romance_repeat")
        else
            QueueRomanceFallback("romance_repeat")
        end
        return
    end

    local hearts = self:GetBondHearts(companionID)
    if hearts < nextThreshold then
        local line = self:ChooseLine("romance_not_ready", companionID)
        if line then
            self:QueueLine(line, "romance_not_ready")
        else
            QueueRomanceFallback("romance_not_ready", nextThreshold)
        end
        return
    end

    local key = "romance_" .. tostring(nextThreshold)
    relationship.romanceRank = nextThreshold
    relationship.lastRomanceAt = GetServerTime and GetServerTime() or 0

    local line = self:ChooseLine(key, companionID)
    if line then
        self:QueueLine(line, key)
    else
        QueueRomanceFallback(key, nextThreshold)
    end

    if self.UpdateCompanionFrame then
        self:UpdateCompanionFrame()
    end
end

function addon:StopRomanceCurrentCompanion()
    if not self.db.enabled then
        self:Print("companion dialogue is disabled.")
        return
    end

    local companionID = self.db.currentCompanionID
    local companion = self:GetCompanion(companionID)
    if not companion then
        return
    end

    local relationship = self:GetRelationship(companionID)
    if (relationship.romanceRank or 0) <= 0 then
        self:Print("you are not currently romancing " .. companion.name .. ".")
        return
    end

    relationship.romanceRank = 0
    relationship.romanceStopCount = (relationship.romanceStopCount or 0) + 1
    relationship.lastRomanceStoppedAt = GetServerTime and GetServerTime() or 0

    local line = self:ChooseLine("romance_stop", companionID)
    if line then
        self:QueueLine(line, "romance_stop")
    else
        QueueRomanceFallback("romance_stop")
    end

    if self.UpdateCompanionFrame then
        self:UpdateCompanionFrame()
    end
end

function addon:UnlockBondDialogue(companionID, oldHearts, newHearts)
    local relationship = self:GetRelationship(companionID)
    if not relationship then
        return
    end

    for _, threshold in ipairs(BOND_THRESHOLDS) do
        if oldHearts < threshold and newHearts >= threshold then
            local key = "bond_" .. tostring(threshold)
            if not relationship.unlocked[key] then
                relationship.unlocked[key] = true
                if self.db.currentCompanionID == companionID then
                    self:Say(key)
                end
            end
        end
    end
end
function addon:AddBondPoints(companionID, points, reason)
    if not companionID or not self.companions[companionID] then
        return
    end

    points = tonumber(points) or 0
    if points == 0 then
        return
    end

    local relationship = self:GetRelationship(companionID)
    local oldPoints = relationship.points or 0
    local oldHearts = math.floor(oldPoints / POINTS_PER_HEART)
    local newPoints = self:Clamp(oldPoints + points, 0, MAX_POINTS)
    local newHearts = math.floor(newPoints / POINTS_PER_HEART)

    relationship.points = newPoints
    relationship.lastReason = reason
    relationship.lastChangedAt = GetServerTime and GetServerTime() or 0

    if newPoints ~= oldPoints then
        self:UnlockBondDialogue(companionID, oldHearts, newHearts)
        if self.UpdateCompanionFrame then
            self:UpdateCompanionFrame()
        end
    end
end

function addon:AddBondForCurrentCompanion(reason)
    local points = BOND_REASONS[reason]
    if not points then
        return
    end

    self:AddBondPoints(self.db.currentCompanionID, points, reason)
end

function addon:ScheduleBondTimeTick()
    self.bondToken = (self.bondToken or 0) + 1
    local token = self.bondToken

    C_Timer.After(600, function()
        if addon.bondToken ~= token then
            return
        end

        if addon.started and addon.db.enabled and addon.db.currentCompanionID and not UnitIsDeadOrGhost("player") then
            addon:AddBondForCurrentCompanion("time_together")
        end

        addon:ScheduleBondTimeTick()
    end)
end

function addon:PrintBondStatus(companionID)
    if companionID then
        local companion = self.companions[companionID]
        if companion then
            self:Print(companion.name .. " - " .. self:GetBondLabel(companion.id))
            return
        end
        self:Print("unknown companion. Try /isekai bond to list all bonds.")
        return
    end

    for _, id in ipairs(self.companionOrder or {}) do
        local companion = self:GetCompanion(id)
        if companion then
            self:Print(companion.name .. " - " .. self:GetBondLabel(id))
        end
    end
end
