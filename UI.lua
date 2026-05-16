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

function addon:CreateCompanionFrame()
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
    frame.character:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -18, 18)
    frame.character:SetSize(500, 390)

    frame.namePlate = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.namePlate:SetSize(220, 34)
    frame.namePlate:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 248, 118)
    ApplyPanelBackdrop(frame.namePlate, 0.10, 0.08, 0.18, 0.94)

    frame.name = frame.namePlate:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.name:SetPoint("CENTER", frame.namePlate, "CENTER", 0, 0)
    frame.name:SetWidth(190)
    frame.name:SetJustifyH("CENTER")

    frame.metaChip = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.metaChip:SetSize(250, 28)
    frame.metaChip:SetPoint("BOTTOMLEFT", frame.namePlate, "TOPLEFT", 28, 7)
    ApplyPanelBackdrop(frame.metaChip, 0.08, 0.07, 0.13, 0.88)

    frame.title = frame.metaChip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.title:SetPoint("CENTER", frame.metaChip, "CENTER", 0, 0)
    frame.title:SetWidth(222)
    frame.title:SetJustifyH("CENTER")

    frame.dialogueBox = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.dialogueBox:SetSize(560, 108)
    frame.dialogueBox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 184, 18)
    ApplyPanelBackdrop(frame.dialogueBox, 0.96, 0.93, 0.98, 0.92)

    frame.subtitle = frame.dialogueBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.subtitle:SetPoint("TOPLEFT", frame.dialogueBox, "TOPLEFT", 24, -20)
    frame.subtitle:SetPoint("BOTTOMRIGHT", frame.dialogueBox, "BOTTOMRIGHT", -24, 20)
    frame.subtitle:SetTextColor(0.10, 0.08, 0.16)
    frame.subtitle:SetJustifyH("LEFT")
    frame.subtitle:SetJustifyV("MIDDLE")
    frame.subtitle:SetWordWrap(true)
    frame.subtitle:SetText("")

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableTiny")
    frame.hint:SetPoint("BOTTOMRIGHT", frame.dialogueBox, "TOPRIGHT", -12, 6)
    frame.hint:SetText("/isekai for commands")

    self.frame = frame
    self:UpdateFrameMouseState()
    self:UpdateCompanionFrame()
end

function addon:UpdateFrameMouseState()
    if not self.frame then
        return
    end

    self.frame:EnableMouse(not self.db.locked and self.dragEnabled == true)
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
    end

    self.frame.namePlate:SetBackdropBorderColor(color[1], color[2], color[3], 0.86)
    self.frame.metaChip:SetBackdropBorderColor(color[1], color[2], color[3], 0.62)
    self.frame.dialogueBox:SetBackdropBorderColor(color[1], color[2], color[3], 0.74)
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
    self:UpdateCompanionFrame()
end
