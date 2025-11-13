-- Lua API
local pairs = pairs

-- WoW API
local CreateFrame = CreateFrame
local ReloadUI = ReloadUI
local ColorPickerFrame = ColorPickerFrame
local Settings = Settings

-- Module Constants
local addon = cfButtonColors
local MODULES = addon.MODULES
local defaultColors = addon.DEFAULT_COLORS

-- Module-level state
local pendingState = nil
local allCheckboxes = {}

-- Initialization code
local panel = CreateFrame("Frame", "cfButtonColorsPanel")
panel.name = "cfButtonColors"

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("cfButtonColors Settings")

-- Functions
-- Helper function to create reset buttons for color pickers
local function createResetButton(colorButton, colorKey, xOffset)
	local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	resetBtn:SetSize(60, 20)
	resetBtn:SetPoint("LEFT", colorButton, "RIGHT", xOffset, 0)
	resetBtn:SetText("Reset")
	resetBtn:SetScript("OnClick", function()
		local default = defaultColors[colorKey]
		pendingState[colorKey] = {r = default.r, g = default.g, b = default.b}
		cfButtonColorsDB[colorKey] = {r = default.r, g = default.g, b = default.b}
		colorButton.colorTexture:SetColorTexture(default.r, default.g, default.b)
	end)
	return resetBtn
end

-- Helper function to create color picker buttons
local function createColorButton(parent, label, colorKey, yOffset)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(20, 20)
	button:SetPoint("TOPLEFT", 20, yOffset)

	-- White border
	local border = button:CreateTexture(nil, "BACKGROUND")
	border:SetColorTexture(1, 1, 1, 1)
	border:SetPoint("TOPLEFT", -1, 1)
	border:SetPoint("BOTTOMRIGHT", 1, -1)

	-- Color texture
	local color = button:CreateTexture(nil, "ARTWORK")
	color:SetAllPoints()
	button.colorTexture = color
	button:SetNormalTexture(color)

	-- Label
	local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetPoint("LEFT", button, "RIGHT", 8, 0)
	text:SetText(label)

	-- Click handler
	button:SetScript("OnClick", function()
		local currentColor = pendingState[colorKey]

		local function updateColor()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			pendingState[colorKey] = {r = r, g = g, b = b}
			cfButtonColorsDB[colorKey] = {r = r, g = g, b = b}
			button.colorTexture:SetColorTexture(r, g, b)
		end

		ColorPickerFrame.func = updateColor
		ColorPickerFrame.swatchFunc = updateColor
		ColorPickerFrame.cancelFunc = function()
			local c = currentColor
			pendingState[colorKey] = {r = c.r, g = c.g, b = c.b}
			cfButtonColorsDB[colorKey] = {r = c.r, g = c.g, b = c.b}
			button.colorTexture:SetColorTexture(c.r, c.g, c.b)
		end
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame:SetColorRGB(currentColor.r, currentColor.g, currentColor.b)
		ColorPickerFrame.previousValues = {currentColor.r, currentColor.g, currentColor.b}
		ColorPickerFrame:Show()
	end)

	return button
end

-- Helper function to create a checkbox
local function createCheckbox(parent, anchorTo, xOffset, yOffset, moduleName, labelText)
	local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	check:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", xOffset, yOffset)
	check.Text:SetText(labelText)
	check.moduleName = moduleName -- Store module name for DB access

	-- OnClick handler will be set during initialization
	return check
end

-- UI Element Creation
-- Checkboxes
allCheckboxes.manaCheck = createCheckbox(panel, title, 0, -16, MODULES.PLAYER_MANA, "Player Actionbar Mana/Usability (Blue for mana, Grey for unusable)")
allCheckboxes.rangeCheck = createCheckbox(panel, allCheckboxes.manaCheck, 0, -8, MODULES.PLAYER_RANGE, "Player Actionbar Range (Red when out of range)")
allCheckboxes.petCheck = createCheckbox(panel, allCheckboxes.rangeCheck, 0, -8, MODULES.PET, "Pet Actionbar Range/Mana")

local petNote = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
petNote:SetPoint("LEFT", allCheckboxes.petCheck.Text, "RIGHT", 8, 0)
petNote:SetText("(only affects |cffAAD372Hunter|r and |cff9382C9Warlock|r)")

-- Reload UI button and warning text
local reloadBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
reloadBtn:SetPoint("TOPLEFT", allCheckboxes.petCheck, "BOTTOMLEFT", 0, -16)
reloadBtn:SetSize(120, 25)
reloadBtn:SetText("Reload UI")
reloadBtn:SetScript("OnClick", function()
	-- Commit pending changes to database
	for key, value in pairs(pendingState) do
		cfButtonColorsDB[key] = value
	end
	ReloadUI()
end)

local warning = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
warning:SetPoint("LEFT", reloadBtn, "RIGHT", 8, 0)
warning:SetText("|cffFF6600Click 'Reload UI' to apply changes|r")

-- Color pickers with individual reset buttons
local manaColorBtn = createColorButton(panel, "Out of Mana Color", "manaColor", -260)
local resetManaBtn = createResetButton(manaColorBtn, "manaColor", 135)

local rangeColorBtn = createColorButton(panel, "Out of Range Color", "rangeColor", -300)
local resetRangeBtn = createResetButton(rangeColorBtn, "rangeColor", 135)

local unusableColorBtn = createColorButton(panel, "Unusable Color", "unusableColor", -340)
local resetUnusableBtn = createResetButton(unusableColorBtn, "unusableColor", 135)

local info = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
info:SetPoint("TOPLEFT", reloadBtn, "BOTTOMLEFT", 4, -8)
info:SetText("Type |cffFFFF00/cfbc|r to open this panel")

-- Event Handlers / Hooks
-- Function to initialize checkboxes from database
local function initializeCheckboxes()
	-- Copy database to pending state
	pendingState = {
		[MODULES.PLAYER_MANA] = cfButtonColorsDB[MODULES.PLAYER_MANA],
		[MODULES.PLAYER_RANGE] = cfButtonColorsDB[MODULES.PLAYER_RANGE],
		[MODULES.PET] = cfButtonColorsDB[MODULES.PET],
		manaColor = {r = cfButtonColorsDB.manaColor.r, g = cfButtonColorsDB.manaColor.g, b = cfButtonColorsDB.manaColor.b},
		rangeColor = {r = cfButtonColorsDB.rangeColor.r, g = cfButtonColorsDB.rangeColor.g, b = cfButtonColorsDB.rangeColor.b},
		unusableColor = {r = cfButtonColorsDB.unusableColor.r, g = cfButtonColorsDB.unusableColor.g, b = cfButtonColorsDB.unusableColor.b},
	}

	-- Configure each checkbox
	for _, check in pairs(allCheckboxes) do
		-- Special handling for Pet checkbox (class restriction)
		if check.moduleName == MODULES.PET and not addon.isPetClass then
			-- Non-pet class: disable checkbox and gray out text
			check:SetChecked(false)
			check:Disable()
			check.Text:SetTextColor(0.5, 0.5, 0.5)
		else
			-- Normal handling: set checked state and enable
			check:SetChecked(pendingState[check.moduleName])
			check:Enable()

			-- Set OnClick handler
			check:SetScript("OnClick", function(self)
				pendingState[self.moduleName] = self:GetChecked()
			end)
		end
	end

	-- Set color picker button colors
	manaColorBtn.colorTexture:SetColorTexture(pendingState.manaColor.r, pendingState.manaColor.g, pendingState.manaColor.b)
	rangeColorBtn.colorTexture:SetColorTexture(pendingState.rangeColor.r, pendingState.rangeColor.g, pendingState.rangeColor.b)
	unusableColorBtn.colorTexture:SetColorTexture(pendingState.unusableColor.r, pendingState.unusableColor.g, pendingState.unusableColor.b)
end

-- Don't initialize immediately - wait for all addons to load
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", initializeCheckboxes)

-- OnShow: Refresh checkboxes from database
panel:SetScript("OnShow", initializeCheckboxes)

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
