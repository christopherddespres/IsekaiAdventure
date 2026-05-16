local _, addon = ...

local function PrintHelp()
    addon:Print("commands:")
    addon:Print("/isekai show | hide | enable | disable | lock | unlock | mute | unmute")
    addon:Print("/isekai test | idle | kill | quest | zone")
    addon:Print("/isekai scale 0.8-1.6 | chance kill 0-100 | chance quest 0-100")
    addon:Print("/isekai companion seraphine/elyria/mika/sera/kaori/rin/lyra")
end

local function Split(input)
    local words = {}
    for word in tostring(input or ""):gmatch("%S+") do
        table.insert(words, word:lower())
    end
    return words
end

SLASH_ISEKAIADVENTURE1 = "/isekai"
SLASH_ISEKAIADVENTURE2 = "/ia"

SlashCmdList.ISEKAIADVENTURE = function(input)
    local words = Split(input)
    local command = words[1]

    if not command or command == "" or command == "help" then
        PrintHelp()
    elseif command == "show" then
        addon:SetShownState(true)
        addon:Print("companion frame shown.")
    elseif command == "hide" then
        addon:SetShownState(false)
        addon:Print("companion frame hidden.")
    elseif command == "enable" then
        addon.db.enabled = true
        addon:UpdateCompanionFrame()
        addon:ScheduleIdleChatter()
        addon:Print("companion dialogue enabled.")
    elseif command == "disable" then
        addon.db.enabled = false
        addon:UpdateCompanionFrame()
        addon:Print("companion dialogue disabled.")
    elseif command == "lock" then
        addon.db.locked = true
        addon.dragEnabled = false
        addon:UpdateFrameMouseState()
        addon:Print("frame locked.")
    elseif command == "unlock" then
        addon.db.locked = false
        addon.dragEnabled = true
        addon:UpdateFrameMouseState()
        addon:Print("frame unlocked for this session. Drag it with left mouse, then use /isekai lock.")
    elseif command == "mute" then
        addon.db.muted = true
        addon:Print("voice playback muted. Subtitles still appear.")
    elseif command == "unmute" then
        addon.db.muted = false
        addon:Print("voice playback unmuted.")
    elseif command == "test" or command == "summon" then
        addon:Say("summon")
    elseif command == "idle" then
        addon:Say("idle")
    elseif command == "kill" then
        addon:Say("kill")
    elseif command == "quest" then
        addon:SayQuestAccepted(nil, "A Very Suspicious Quest")
    elseif command == "zone" then
        addon:RefreshZoneCompanion()
    elseif command == "scale" then
        local scale = addon:Clamp(tonumber(words[2]), 0.6, 1.8)
        addon.db.scale = scale
        addon:UpdateCompanionFrame()
        addon:Print("scale set to " .. scale .. ".")
    elseif command == "chance" then
        local kind = words[2]
        local value = addon:Clamp(tonumber(words[3]), 0, 100)
        if kind == "kill" then
            addon.db.killChance = value
            addon:Print("kill chatter chance set to " .. value .. "%.")
        elseif kind == "quest" then
            addon.db.questChance = value
            addon:Print("quest chatter chance set to " .. value .. "%.")
        else
            addon:Print("usage: /isekai chance kill 12 or /isekai chance quest 100")
        end
    elseif command == "companion" then
        local companionID = words[2]
        if companionID and addon.companions[companionID] then
            addon:SetCompanion(companionID, "manual")
            addon:Say("summon")
            addon:Print("companion set to " .. addon.companions[companionID].name .. ".")
        else
            addon:Print("unknown companion. Try seraphine, elyria, mika, sera, kaori, rin, or lyra.")
        end
    else
        PrintHelp()
    end
end
