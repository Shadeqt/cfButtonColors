local addon = cfButtonColors
local applyButtonColor = addon.applyButtonColor

-- Localized API calls
local _GetPetActionInfo = GetPetActionInfo
local _PetHasActionBar = PetHasActionBar
local _UnitClass = UnitClass
local _CreateFrame = CreateFrame
local _C_Spell = C_Spell
local _C_Timer = C_Timer

-- Constants
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME

-- Cache pet action button references and IDs to avoid repeated lookups
local petButtonCache = {}
for i = 1, NUM_PET_ACTION_SLOTS do
	local button = _G["PetActionButton"..i]
	petButtonCache[i] = {
		button = button,
		buttonSlot = i,
		icon = button.icon
	}
end

-- Update color for pet action button based on range and mana
local function updatePetActionButtonColor(cachedPetButton)
	local _, _, _, _, _, _, spellId, hasRangeCheck, isInRange = _GetPetActionInfo(cachedPetButton.buttonSlot)

	if not spellId then return end
	if not hasRangeCheck then return end

	local isOutOfMana = select(2, _C_Spell.IsSpellUsable(spellId))
	local isOutOfRange = not isInRange

	applyButtonColor(cachedPetButton.icon, isOutOfMana, isOutOfRange)
end

-- Update all visible pet action buttons
local function updateAllPetButtons()
	if not _PetHasActionBar() then return end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local cachedPetButton = petButtonCache[i]
		if cachedPetButton.button:IsVisible() then
			updatePetActionButtonColor(cachedPetButton)
		end
	end
end

-- Initialize pet action button coloring for pet classes
local _, playerClass = _UnitClass("player")
if playerClass == "HUNTER" or playerClass == "WARLOCK" then
	-- Hook for instant updates on target change, attack, and follow commands
	hooksecurefunc("PetActionBar_Update", updateAllPetButtons)

	-- Register events for pet mana changes and cooldown updates
	local petEventFrame = _CreateFrame("Frame")
	petEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
	petEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	petEventFrame:SetScript("OnEvent", function(_, event, unit)
		if event ~= "UNIT_POWER_UPDATE" or unit == "pet" then
			updateAllPetButtons()
		end
	end)

	-- Ticker polls every 0.2s to catch range changes during pet movement (no event exists for this)
	_C_Timer.NewTicker(TOOLTIP_UPDATE_TIME, updateAllPetButtons)
end
