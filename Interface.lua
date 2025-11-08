-- Settings panel frame
local panel = CreateFrame("Frame", "cfButtonColorsPanel")
panel.name = "cfButtonColors"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("cfButtonColors Settings")

-- Checkbox: Mana coloring
local manaCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
manaCheck:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
manaCheck.Text:SetText("Enable Mana/Usability Coloring (Blue for mana, Grey for unusable)")
manaCheck:SetChecked(cfButtonColorsDB.showManaColor)
manaCheck:SetScript("OnClick", function(self)
	cfButtonColorsDB.showManaColor = self:GetChecked()
end)

-- Checkbox: Range coloring
local rangeCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
rangeCheck:SetPoint("TOPLEFT", manaCheck, "BOTTOMLEFT", 0, -8)
rangeCheck.Text:SetText("Enable Range Coloring (Red when out of range)")
rangeCheck:SetChecked(cfButtonColorsDB.showRangeColor)
rangeCheck:SetScript("OnClick", function(self)
	cfButtonColorsDB.showRangeColor = self:GetChecked()
end)

-- Checkbox: Pet button coloring
local petCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
petCheck:SetPoint("TOPLEFT", rangeCheck, "BOTTOMLEFT", 0, -8)
petCheck.Text:SetText("Enable Pet Button Coloring")
petCheck:SetChecked(cfButtonColorsDB.enablePetButtons)
petCheck:SetScript("OnClick", function(self)
	cfButtonColorsDB.enablePetButtons = self:GetChecked()
end)

local petNote = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
petNote:SetPoint("LEFT", petCheck.Text, "RIGHT", 8, 0)
petNote:SetText("(only affects |cffAAD372Hunter|r and |cff9382C9Warlock|r)")

-- Reload UI button and warning text
local reloadBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
reloadBtn:SetPoint("TOPLEFT", petCheck, "BOTTOMLEFT", 0, -16)
reloadBtn:SetSize(120, 25)
reloadBtn:SetText("Reload UI")
reloadBtn:SetScript("OnClick", function()
	ReloadUI()
end)

local warning = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
warning:SetPoint("LEFT", reloadBtn, "RIGHT", 8, 0)
warning:SetText("|cffFF6600Changes require a reload to take effect|r")

local info = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
info:SetPoint("TOPLEFT", reloadBtn, "BOTTOMLEFT", 4, -8)
info:SetText("Type |cffFFFF00/cfbc|r to open this panel")

-- Event: Refresh checkbox states when panel is shown
panel:SetScript("OnShow", function(self)
	manaCheck:SetChecked(cfButtonColorsDB.showManaColor)
	rangeCheck:SetChecked(cfButtonColorsDB.showRangeColor)
	petCheck:SetChecked(cfButtonColorsDB.enablePetButtons)
end)

-- Register panel with WoW settings API
if Settings and Settings.RegisterCanvasLayoutCategory then
	local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	category.ID = panel.name
	Settings.RegisterAddOnCategory(category)
end

-- Slash command: /cfbc
SLASH_CFBUTTONCOLORS1 = "/cfbc"
SlashCmdList["CFBUTTONCOLORS"] = function()
	Settings.OpenToCategory(panel.name)
end
