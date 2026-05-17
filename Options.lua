local _, addon = ...

local ROW_HEIGHT = 32
local LEFT = 22
local TOP = -58
local controlIndex = 0

local function NextControlName(kind)
    controlIndex = controlIndex + 1
    return "IsekaiAdventure" .. kind .. controlIndex
end

local function SetLabel(fontString, text)
    fontString:SetText(text)
    fontString:SetJustifyH("LEFT")
end

local function CreateCheck(panel, label, tooltip, getter, setter)
    local name = NextControlName("Check")
    local check = CreateFrame("CheckButton", name, panel, "InterfaceOptionsCheckButtonTemplate")
    local text = check.Text or _G[name .. "Text"]
    if text then
        text:SetText(label)
    end
    check.tooltipText = tooltip
    check:SetScript("OnClick", function(self)
        setter(self:GetChecked() == true)
        if addon.RefreshOptionsPanel then
            addon:RefreshOptionsPanel()
        end
    end)
    check.Refresh = function(self)
        self:SetChecked(getter() == true)
    end
    return check
end

local function CreateSlider(panel, label, minValue, maxValue, step, getter, setter, formatter)
    local name = NextControlName("Slider")
    local slider = CreateFrame("Slider", name, panel, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    local text = slider.Text or _G[name .. "Text"]
    local low = slider.Low or _G[name .. "Low"]
    local high = slider.High or _G[name .. "High"]
    if text then
        text:SetText(label)
    end
    if low then
        low:SetText(tostring(minValue))
    end
    if high then
        high:SetText(tostring(maxValue))
    end

    slider.valueText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    slider.valueText:SetPoint("LEFT", slider, "RIGHT", 14, 0)

    slider:SetScript("OnValueChanged", function(self, value)
        value = addon:Clamp(value, minValue, maxValue)
        if step >= 1 then
            value = math.floor(value + 0.5)
        end
        setter(value)
        self.valueText:SetText(formatter and formatter(value) or tostring(value))
    end)

    slider.Refresh = function(self)
        local value = getter()
        self:SetValue(value)
        self.valueText:SetText(formatter and formatter(value) or tostring(value))
    end

    return slider
end

local function CreateEditNumber(panel, label, width, getter, setter)
    local frame = CreateFrame("Frame", nil, panel)
    frame:SetSize(260, 28)

    frame.label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.label:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.label:SetWidth(130)
    SetLabel(frame.label, label)

    frame.box = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    frame.box:SetSize(width or 72, 28)
    frame.box:SetPoint("LEFT", frame.label, "RIGHT", 8, 0)
    frame.box:SetAutoFocus(false)
    frame.box:SetNumeric(true)
    frame.box:SetScript("OnEnterPressed", function(self)
        setter(tonumber(self:GetText()))
        self:ClearFocus()
        if addon.RefreshOptionsPanel then
            addon:RefreshOptionsPanel()
        end
    end)
    frame.box:SetScript("OnEditFocusLost", function(self)
        setter(tonumber(self:GetText()))
        if addon.RefreshOptionsPanel then
            addon:RefreshOptionsPanel()
        end
    end)

    frame.Refresh = function(self)
        self.box:SetText(tostring(getter()))
    end

    return frame
end

local function CreateButton(panel, text, width, onClick)
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(width or 140, 26)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateChoiceButton(panel, label, width, choices, getter, setter)
    local frame = CreateFrame("Frame", nil, panel)
    frame:SetSize(260, 28)

    frame.label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    frame.label:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.label:SetWidth(110)
    SetLabel(frame.label, label)

    frame.button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.button:SetSize(width or 132, 26)
    frame.button:SetPoint("LEFT", frame.label, "RIGHT", 8, 0)
    frame.button:SetScript("OnClick", function()
        local current = getter()
        local nextIndex = 1
        for index, choice in ipairs(choices) do
            if choice.value == current then
                nextIndex = index + 1
                break
            end
        end
        if nextIndex > #choices then
            nextIndex = 1
        end
        setter(choices[nextIndex].value)
        frame:Refresh()
    end)

    frame.Refresh = function(self)
        local current = getter()
        local labelText = tostring(current or "")
        for _, choice in ipairs(choices) do
            if choice.value == current then
                labelText = choice.label
                break
            end
        end
        self.button:SetText(labelText)
    end

    return frame
end

local function Place(control, x, y)
    control:SetPoint("TOPLEFT", x, y)
    return control
end

local function RefreshIdleTimer()
    if addon.ScheduleIdleChatter then
        addon:ScheduleIdleChatter()
    end
end

local function ApplyVisualSettings()
    addon:NormalizeDatabase()
    addon:EnsureCompanionFrame()
    addon:ApplyDialogueStyle()
end

function addon:CreateOptionsPanel()
    if self.optionsPanel then
        return self.optionsPanel
    end

    local panel = CreateFrame("Frame", "IsekaiAdventureOptionsPanel")
    panel.name = "Isekai Adventure"
    panel:SetSize(620, 720)

    local scrollFrame = CreateFrame("ScrollFrame", "IsekaiAdventureOptionsScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 0)

    local content = CreateFrame("Frame", "IsekaiAdventureOptionsScrollContent", scrollFrame)
    content:SetSize(560, 900)
    scrollFrame:SetScrollChild(content)
    panel.scrollFrame = scrollFrame
    panel.content = content

    panel.title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    panel.title:SetPoint("TOPLEFT", content, "TOPLEFT", LEFT, -20)
    panel.title:SetText("Isekai Adventure")

    panel.subtitle = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.subtitle:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -8)
    panel.subtitle:SetText("Companion display, voice, and chatter settings.")

    local y = TOP
    local controls = {}

    controls[#controls + 1] = Place(CreateCheck(content, "Enable companion dialogue", "Turns automatic companion dialogue on or off.", function()
        return addon.db.enabled
    end, function(value)
        addon.db.enabled = value
        addon:UpdateCompanionFrame()
        RefreshIdleTimer()
    end), LEFT, y)

    controls[#controls + 1] = Place(CreateCheck(content, "Show visual novel overlay", "Shows or hides the companion UI.", function()
        return addon.db.visible
    end, function(value)
        addon:SetShownState(value)
    end), LEFT + 260, y)
    y = y - ROW_HEIGHT

    controls[#controls + 1] = Place(CreateCheck(content, "Show bond progress", "Shows companion relationship progress under the name.", function()
        return addon.db.showBond
    end, function(value)
        addon.db.showBond = value
        addon:UpdateCompanionFrame()
    end), LEFT, y)

    controls[#controls + 1] = Place(CreateCheck(content, "Show romance button", "Shows the romance progression button below the hearts.", function()
        return addon.db.showRomanceButton
    end, function(value)
        addon.db.showRomanceButton = value
        addon:UpdateCompanionFrame()
    end), LEFT + 260, y)
    y = y - ROW_HEIGHT

    controls[#controls + 1] = Place(CreateCheck(content, "Mute voice playback", "Keeps subtitles but stops audio playback.", function()
        return addon.db.muted
    end, function(value)
        addon.db.muted = value
    end), LEFT, y)

    controls[#controls + 1] = Place(CreateChoiceButton(content, "Voice channel", 132, addon:GetVoiceChannels(), function()
        return addon.db.voiceChannel
    end, function(value)
        addon.db.voiceChannel = value
    end), LEFT + 260, y)
    y = y - ROW_HEIGHT

    controls[#controls + 1] = Place(CreateChoiceButton(content, "Companion route", 132, addon:GetCompanionPreferenceChoices(), function()
        return addon.db.companionPreference
    end, function(value)
        addon.db.companionPreference = value
        addon:RefreshZoneCompanion("preference")
    end), LEFT, y)
    y = y - ROW_HEIGHT

    controls[#controls + 1] = Place(CreateCheck(content, "Enable idle chatter", "Allows random out-of-combat chatter.", function()
        return addon.db.idleChatter
    end, function(value)
        addon.db.idleChatter = value
        RefreshIdleTimer()
    end), LEFT, y)
    y = y - 44

    controls[#controls + 1] = Place(CreateCheck(content, "Start automatically", "Starts zone, quest, kill, and idle chatter after login.", function()
        return addon.db.autoStartAutomation
    end, function(value)
        addon.db.autoStartAutomation = value
        if value and not addon.started then
            addon:StartAutomation("options")
        end
    end), LEFT, y)

    controls[#controls + 1] = Place(CreateCheck(content, "Startup debug messages", "Prints startup diagnostics in chat.", function()
        return addon.db.debugStartup
    end, function(value)
        addon.db.debugStartup = value
    end), LEFT + 260, y)
    y = y - ROW_HEIGHT

    controls[#controls + 1] = Place(CreateSlider(content, "Quest chance", 0, 100, 1, function()
        return addon.db.questChance
    end, function(value)
        addon.db.questChance = value
    end, function(value)
        return value .. "%"
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Kill chance", 0, 100, 1, function()
        return addon.db.killChance
    end, function(value)
        addon.db.killChance = value
    end, function(value)
        return value .. "%"
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Idle cooldown", 5, 600, 5, function()
        return addon.db.idleCooldownSeconds
    end, function(value)
        addon.db.idleCooldownSeconds = value
        if addon.db.idleMinSeconds < value then
            addon.db.idleMinSeconds = value
        end
        if addon.db.idleMaxSeconds < addon.db.idleMinSeconds then
            addon.db.idleMaxSeconds = addon.db.idleMinSeconds
        end
        RefreshIdleTimer()
    end, function(value)
        return value .. " sec"
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Kill cooldown", 0, 60, 1, function()
        return addon.db.killCooldownSeconds
    end, function(value)
        addon.db.killCooldownSeconds = value
    end, function(value)
        return value .. " sec"
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Level chance", 0, 100, 1, function()
        return addon.db.levelChance
    end, function(value)
        addon.db.levelChance = value
    end, function(value)
        return value .. "%"
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Overlay scale", 0.6, 1.8, 0.05, function()
        return addon.db.scale
    end, function(value)
        addon.db.scale = value
        addon:EnsureCompanionFrame()
        addon:UpdateCompanionFrame()
    end, function(value)
        return string.format("%.2f", value)
    end), LEFT, y)
    y = y - 50

    controls[#controls + 1] = Place(CreateSlider(content, "Dialogue opacity", 0.2, 1, 0.05, function()
        return addon.db.dialogueBoxAlpha
    end, function(value)
        addon.db.dialogueBoxAlpha = value
        ApplyVisualSettings()
    end, function(value)
        return string.format("%.2f", value)
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Text size", 10, 24, 1, function()
        return addon.db.subtitleFontSize
    end, function(value)
        addon.db.subtitleFontSize = value
        ApplyVisualSettings()
    end, function(value)
        return value .. " px"
    end), LEFT, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Box red", 0, 1, 0.01, function()
        return addon.db.dialogueBoxColor.r
    end, function(value)
        addon.db.dialogueBoxColor.r = value
        ApplyVisualSettings()
    end, function(value)
        return string.format("%.2f", value)
    end), LEFT, y)

    controls[#controls + 1] = Place(CreateSlider(content, "Box green", 0, 1, 0.01, function()
        return addon.db.dialogueBoxColor.g
    end, function(value)
        addon.db.dialogueBoxColor.g = value
        ApplyVisualSettings()
    end, function(value)
        return string.format("%.2f", value)
    end), LEFT + 260, y)
    y = y - 54

    controls[#controls + 1] = Place(CreateSlider(content, "Box blue", 0, 1, 0.01, function()
        return addon.db.dialogueBoxColor.b
    end, function(value)
        addon.db.dialogueBoxColor.b = value
        ApplyVisualSettings()
    end, function(value)
        return string.format("%.2f", value)
    end), LEFT, y)
    y = y - 54

    local minBox = CreateEditNumber(content, "Idle min seconds", 72, function()
        return addon.db.idleMinSeconds
    end, function(value)
        addon.db.idleMinSeconds = addon:Clamp(value, 5, 3600)
        addon.db.idleCooldownSeconds = addon.db.idleMinSeconds
        if addon.db.idleMaxSeconds < addon.db.idleMinSeconds then
            addon.db.idleMaxSeconds = addon.db.idleMinSeconds
        end
        RefreshIdleTimer()
    end)
    controls[#controls + 1] = Place(minBox, LEFT, y)

    local maxBox = CreateEditNumber(content, "Idle max seconds", 72, function()
        return addon.db.idleMaxSeconds
    end, function(value)
        addon.db.idleMaxSeconds = addon:Clamp(value, addon.db.idleMinSeconds, 7200)
        RefreshIdleTimer()
    end)
    controls[#controls + 1] = Place(maxBox, LEFT + 260, y)
    y = y - 44

    controls[#controls + 1] = Place(CreateButton(content, "Test Summon", 120, function()
        addon:Say("summon")
    end), LEFT, y)
    controls[#controls + 1] = Place(CreateButton(content, "Test Quest", 120, function()
        addon:SayQuestAccepted(nil, "A Very Suspicious Quest")
    end), LEFT + 130, y)
    controls[#controls + 1] = Place(CreateButton(content, "Test Idle", 120, function()
        addon:Say("idle")
    end), LEFT + 260, y)
    controls[#controls + 1] = Place(CreateButton(content, "Test Kill", 120, function()
        addon:Say("kill")
    end), LEFT + 390, y)
    y = y - 36

    controls[#controls + 1] = Place(CreateButton(content, "Layout Mode", 120, function()
        addon:EnsureCompanionFrame()
        addon:SetLayoutMode(not addon.layoutMode)
    end), LEFT, y)
    controls[#controls + 1] = Place(CreateButton(content, "Reset Layout", 120, function()
        addon:EnsureCompanionFrame()
        addon:SetLayoutMode(false)
        addon:ResetLayout()
    end), LEFT + 130, y)

    controls[#controls + 1] = Place(CreateButton(content, "Reset Settings", 132, function()
        addon:ResetSavedSettings()
        addon:RefreshOptionsPanel()
        addon:Print("saved settings reset to defaults.")
    end), LEFT + 260, y)

    content:SetHeight(math.abs(y) + 70)

    panel.controls = controls
    panel:SetScript("OnShow", function()
        addon:RefreshOptionsPanel()
    end)

    self.optionsPanel = panel
    return panel
end

function addon:RefreshOptionsPanel()
    local panel = self.optionsPanel
    if not panel or not panel.controls then
        return
    end

    for _, control in ipairs(panel.controls) do
        if control.Refresh then
            control:Refresh()
        end
    end
end

function addon:RegisterOptionsPanel()
    if self.optionsRegistered then
        return
    end

    local panel = self:CreateOptionsPanel()
    local registered = false

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        self.optionsCategory = category
        registered = true
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
        registered = true
    end

    self.optionsRegistered = registered
end

function addon:OpenOptionsPanel()
    if not self.optionsPanel or not self.optionsRegistered then
        self:RegisterOptionsPanel()
    end

    if Settings and Settings.OpenToCategory and self.optionsCategory then
        local categoryID = self.optionsCategory.ID
        if not categoryID and self.optionsCategory.GetID then
            categoryID = self.optionsCategory:GetID()
        end
        Settings.OpenToCategory(categoryID or self.optionsCategory)
    elseif InterfaceOptionsFrame_OpenToCategory and self.optionsPanel then
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
    else
        self:Print("Open Options > AddOns > Isekai Adventure.")
    end
end
