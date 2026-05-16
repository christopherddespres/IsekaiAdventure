local _, addon = ...

local BACKDROP = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 24,
    insets = { left = 7, right = 7, top = 7, bottom = 7 },
}

local function ApplyBackdrop(frame)
    if BackdropTemplateMixin then
        frame:SetBackdrop(BACKDROP)
        frame:SetBackdropColor(0.05, 0.04, 0.07, 0.88)
        frame:SetBackdropBorderColor(0.95, 0.65, 1.00, 0.8)
    end
end

function addon:CreateCompanionFrame()
    local frame = CreateFrame("Frame", "IsekaiAdventureCompanionFrame", UIParent, "BackdropTemplate")
    frame:SetSize(238, 330)
    frame:SetPoint(self.db.frame.point, UIParent, self.db.frame.relativePoint, self.db.frame.x, self.db.frame.y)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
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
    ApplyBackdrop(frame)

    frame.name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.name:SetPoint("TOP", frame, "TOP", 0, -18)
    frame.name:SetWidth(200)
    frame.name:SetJustifyH("CENTER")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.title:SetPoint("TOP", frame.name, "BOTTOM", 0, -3)
    frame.title:SetWidth(200)
    frame.title:SetJustifyH("CENTER")

    frame.portraitBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.portraitBorder:SetSize(184, 184)
    frame.portraitBorder:SetPoint("TOP", frame.title, "BOTTOM", 0, -12)
    frame.portraitBorder:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.portraitBorder:SetBackdropColor(0.03, 0.02, 0.04, 0.95)
    frame.portraitBorder:SetBackdropBorderColor(1, 0.70, 1, 0.85)

    frame.portrait = frame.portraitBorder:CreateTexture(nil, "ARTWORK")
    frame.portrait:SetPoint("TOPLEFT", frame.portraitBorder, "TOPLEFT", 8, -8)
    frame.portrait:SetPoint("BOTTOMRIGHT", frame.portraitBorder, "BOTTOMRIGHT", -8, 8)
    frame.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.subtitle:SetPoint("TOPLEFT", frame.portraitBorder, "BOTTOMLEFT", -7, -14)
    frame.subtitle:SetPoint("RIGHT", frame, "RIGHT", -18, 0)
    frame.subtitle:SetHeight(76)
    frame.subtitle:SetJustifyH("CENTER")
    frame.subtitle:SetJustifyV("TOP")
    frame.subtitle:SetWordWrap(true)
    frame.subtitle:SetText("")

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableTiny")
    frame.hint:SetPoint("BOTTOM", frame, "BOTTOM", 0, 14)
    frame.hint:SetText("/isekai for commands")

    self.frame = frame
    self:UpdateCompanionFrame()
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
    self.frame.portrait:SetTexture(companion.portrait or "Interface\\Icons\\INV_Misc_QuestionMark")
    self.frame.portrait:SetAlpha(self.db.portraitAlpha or 1)
    self.frame.portraitBorder:SetBackdropBorderColor(color[1], color[2], color[3], 0.85)
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
