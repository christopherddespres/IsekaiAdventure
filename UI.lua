local _, addon = ...

local PANEL_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local function ApplyPanelBackdrop(frame, r, g, b, alpha)
    if BackdropTemplateMixin then
        frame:SetBackdrop(PANEL_BACKDROP)
        frame:SetBackdropColor(r or 0.05, g or 0.04, b or 0.07, alpha or 0.86)
        frame:SetBackdropBorderColor(1, 0.88, 1, 0.72)
    end
end

local function GetDialogueColor()
    local color = addon.db.dialogueBoxColor or {}
    return color.r or 0.02, color.g or 0.018, color.b or 0.014
end

local function SetRelativePoint(region, x, y)
    region:ClearAllPoints()
    region:SetPoint("BOTTOMLEFT", addon.frame, "BOTTOMLEFT", x, y)
end

local function SaveLayoutPosition(key, region)
    local frameLeft = addon.frame:GetLeft()
    local frameBottom = addon.frame:GetBottom()
    local regionLeft = region:GetLeft()
    local regionBottom = region:GetBottom()

    if not frameLeft or not frameBottom or not regionLeft or not regionBottom then
        return
    end

    addon.db.layout[key].x = regionLeft - frameLeft
    addon.db.layout[key].y = regionBottom - frameBottom
    addon:ApplyLayoutPositions()
end

local function AttachMover(region, key)
    region:SetMovable(true)
    region:EnableMouse(false)
    region:RegisterForDrag("LeftButton")
    region:SetScript("OnDragStart", function(self)
        if addon.layoutMode then
            self:StartMoving()
        end
    end)
    region:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveLayoutPosition(key, self)
    end)
end

local function CreateLayoutHandle(parent, label)
    local handle = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    handle:SetAllPoints(parent)
    handle:SetFrameLevel(parent:GetFrameLevel() + 8)
    ApplyPanelBackdrop(handle, 0.12, 0.10, 0.18, 0.35)
    handle:Hide()

    handle.text = handle:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    handle.text:SetPoint("CENTER", handle, "CENTER", 0, 0)
    handle.text:SetText(label)

    return handle
end

function addon:CreateCompanionFrame()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", "IsekaiAdventureCompanionFrame", UIParent, "BackdropTemplate")
    frame:SetSize(760, 430)
    frame:SetPoint(self.db.frame.point, UIParent, self.db.frame.relativePoint, self.db.frame.x, self.db.frame.y)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(false)
    frame:RegisterForDrag("LeftButton")
    frame:SetScale(self.db.scale or 1)
    frame:SetScript("OnDragStart", function(selfFrame)
        if not addon.db.locked then
            selfFrame:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(selfFrame)
        selfFrame:StopMovingOrSizing()
        local point, _, relativePoint, x, y = selfFrame:GetPoint()
        addon.db.frame.point = point or "CENTER"
        addon.db.frame.relativePoint = relativePoint or "CENTER"
        addon.db.frame.x = x or 360
        addon.db.frame.y = y or -20
    end)

    frame.character = frame:CreateTexture(nil, "ARTWORK")

    frame.characterMover = CreateFrame("Frame", nil, frame)
    frame.characterMover:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.db.layout.character.x, self.db.layout.character.y)
    frame.characterMover:SetSize(390, 390)
    AttachMover(frame.characterMover, "character")

    frame.character:SetAllPoints(frame.characterMover)

    frame.namePlate = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.namePlate:SetSize(220, 34)
    frame.namePlate:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.db.layout.namePlate.x, self.db.layout.namePlate.y)
    AttachMover(frame.namePlate, "namePlate")
    ApplyPanelBackdrop(frame.namePlate, 0.10, 0.08, 0.18, 0.94)

    frame.name = frame.namePlate:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.name:SetPoint("CENTER", frame.namePlate, "CENTER", 0, 0)
    frame.name:SetWidth(190)
    frame.name:SetJustifyH("CENTER")

    frame.metaChip = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.metaChip:SetSize(250, 28)
    frame.metaChip:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.db.layout.metaChip.x, self.db.layout.metaChip.y)
    AttachMover(frame.metaChip, "metaChip")
    ApplyPanelBackdrop(frame.metaChip, 0.08, 0.07, 0.13, 0.88)

    frame.title = frame.metaChip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.title:SetPoint("CENTER", frame.metaChip, "CENTER", 0, 0)
    frame.title:SetWidth(222)
    frame.title:SetJustifyH("CENTER")

    frame.dialogueBox = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.dialogueBox:SetSize(560, 108)
    frame.dialogueBox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", self.db.layout.dialogueBox.x, self.db.layout.dialogueBox.y)
    AttachMover(frame.dialogueBox, "dialogueBox")
    local dialogueR, dialogueG, dialogueB = GetDialogueColor()
    ApplyPanelBackdrop(frame.dialogueBox, dialogueR, dialogueG, dialogueB, self.db.dialogueBoxAlpha or 0.90)

    frame.subtitle = frame.dialogueBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.subtitle:SetPoint("TOPLEFT", frame.dialogueBox, "TOPLEFT", 24, -20)
    frame.subtitle:SetPoint("BOTTOMRIGHT", frame.dialogueBox, "BOTTOMRIGHT", -24, 20)
    frame.subtitle:SetTextColor(1.00, 0.88, 0.62)
    frame.subtitle:SetShadowColor(0, 0, 0, 0.95)
    frame.subtitle:SetShadowOffset(1, -1)
    frame.subtitle:SetJustifyH("LEFT")
    frame.subtitle:SetJustifyV("MIDDLE")
    frame.subtitle:SetWordWrap(true)
    frame.subtitle:SetText("")

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableTiny")
    frame.hint:SetPoint("BOTTOMRIGHT", frame.dialogueBox, "TOPRIGHT", -12, 6)
    frame.hint:SetTextColor(0.66, 0.55, 0.36)
    frame.hint:SetText("/isekai for commands")

    frame.characterHandle = CreateLayoutHandle(frame.characterMover, "Character")
    frame.nameHandle = CreateLayoutHandle(frame.namePlate, "Name")
    frame.titleHandle = CreateLayoutHandle(frame.metaChip, "Title")
    frame.dialogueHandle = CreateLayoutHandle(frame.dialogueBox, "Dialogue")

    self.frame = frame
    self:ApplyDialogueStyle()
    self:UpdateFrameMouseState()
    self:UpdateCompanionFrame()
    return frame
end

function addon:EnsureCompanionFrame()
    if not self.frame then
        self:CreateCompanionFrame()
    end
    return self.frame
end

function addon:ApplyLayoutPositions()
    if not self.frame then
        return
    end

    SetRelativePoint(self.frame.characterMover, self.db.layout.character.x, self.db.layout.character.y)
    SetRelativePoint(self.frame.namePlate, self.db.layout.namePlate.x, self.db.layout.namePlate.y)
    SetRelativePoint(self.frame.metaChip, self.db.layout.metaChip.x, self.db.layout.metaChip.y)
    SetRelativePoint(self.frame.dialogueBox, self.db.layout.dialogueBox.x, self.db.layout.dialogueBox.y)
end

function addon:ApplyDialogueStyle()
    if not self.frame then
        return
    end

    local r, g, b = GetDialogueColor()
    ApplyPanelBackdrop(self.frame.dialogueBox, r, g, b, self.db.dialogueBoxAlpha or 0.90)
    local companion = self:GetCompanion(self.db.currentCompanionID)
    local borderColor = companion and companion.color or { 1, 0.8, 1 }
    self.frame.dialogueBox:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], 0.74)

    local fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    self.frame.subtitle:SetFont(fontPath, self.db.subtitleFontSize or 14, "")
    self.frame.subtitle:SetTextColor(1.00, 0.88, 0.62)
    self.frame.subtitle:SetShadowColor(0, 0, 0, 0.95)
    self.frame.subtitle:SetShadowOffset(1, -1)
end

function addon:UpdateFrameMouseState()
    if not self.frame then
        return
    end

    local canDragMain = not self.db.locked and self.dragEnabled == true
    self.frame:EnableMouse(canDragMain)
    self.frame.characterMover:EnableMouse(self.layoutMode == true)
    self.frame.namePlate:EnableMouse(self.layoutMode == true)
    self.frame.metaChip:EnableMouse(self.layoutMode == true)
    self.frame.dialogueBox:EnableMouse(self.layoutMode == true)
end

function addon:SetLayoutMode(enabled)
    self.layoutMode = enabled

    if self.frame then
        local handles = {
            self.frame.characterHandle,
            self.frame.nameHandle,
            self.frame.titleHandle,
            self.frame.dialogueHandle,
        }

        for _, handle in ipairs(handles) do
            if enabled then
                handle:Show()
            else
                handle:Hide()
            end
        end
    end

    self:UpdateFrameMouseState()
end

function addon:ResetLayout()
    local defaultFrame = self:GetDefaultFrameConfig()
    local defaultLayout = self:GetDefaultLayoutConfig()

    self.db.frame.point = defaultFrame.point
    self.db.frame.relativePoint = defaultFrame.relativePoint
    self.db.frame.x = defaultFrame.x
    self.db.frame.y = defaultFrame.y

    for key, layout in pairs(defaultLayout) do
        self.db.layout[key].x = layout.x
        self.db.layout[key].y = layout.y
    end

    if self.frame then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(self.db.frame.point, UIParent, self.db.frame.relativePoint, self.db.frame.x, self.db.frame.y)
    end
    self:ApplyLayoutPositions()
end

function addon:UpdateCompanionFrame()
    if not self.frame then
        return
    end

    local companion = self:GetCompanion(self.db.currentCompanionID)
    if not companion then
        return
    end

    local color = companion.color or { 1, 0.8, 1 }
    self.frame.name:SetText(companion.name or "Unknown Companion")
    self.frame.name:SetTextColor(color[1], color[2], color[3])
    self.frame.title:SetText(companion.title or "")
    self.frame.character:SetTexture(companion.characterArt or companion.portrait or "Interface\\Icons\\INV_Misc_QuestionMark")
    self.frame.character:SetAlpha(self.db.portraitAlpha or 1)

    local texCoord = companion.characterTexCoord
    if texCoord then
        self.frame.character:SetTexCoord(texCoord[1], texCoord[2], texCoord[3], texCoord[4])
    else
        self.frame.character:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        texCoord = { 0.08, 0.92, 0.08, 0.92 }
    end

    local characterHeight = companion.characterHeight or 390
    local characterAspect = (texCoord[2] - texCoord[1]) / (texCoord[4] - texCoord[3])
    self.frame.characterMover:SetSize(characterHeight * characterAspect, characterHeight)
    self:ApplyLayoutPositions()

    self.frame.namePlate:SetBackdropBorderColor(color[1], color[2], color[3], 0.86)
    self.frame.metaChip:SetBackdropBorderColor(color[1], color[2], color[3], 0.62)
    self:ApplyDialogueStyle()
    self.frame:SetScale(self.db.scale or 1)

    if self.db.enabled and self.db.visible then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

function addon:SetSubtitle(text, seconds)
    if not self.frame then
        return
    end

    self.frame.subtitle:SetText(text or "")

    if text and text ~= "" then
        local token = (self.subtitleToken or 0) + 1
        self.subtitleToken = token
        C_Timer.After(seconds or self.db.subtitleSeconds or 7, function()
            if addon.subtitleToken == token and addon.frame then
                addon.frame.subtitle:SetText("")
            end
        end)
    end
end

function addon:SetShownState(visible)
    self.db.visible = visible
    if visible then
        self:EnsureCompanionFrame()
    end
    self:UpdateCompanionFrame()
end
