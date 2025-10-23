local addon = cfButtonColors
local applyButtonColor = addon.applyButtonColor

-- Localize for performance
local GetPetActionInfo = GetPetActionInfo
local PetHasActionBar = PetHasActionBar
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local IsSpellUsable = C_Spell.IsSpellUsable
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME
local C_Timer = C_Timer

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
	local _, _, _, _, _, _, spellId, hasRangeCheck, isInRange = GetPetActionInfo(cachedPetButton.buttonSlot)
	
	if not spellId then return end
	if not hasRangeCheck then return end

	local isOutOfMana = select(2, IsSpellUsable(spellId))
	local isOutOfRange = not isInRange

	applyButtonColor(cachedPetButton.icon, isOutOfMana, isOutOfRange)
end

-- Update all visible pet action buttons
local function updateAllPetButtons()
	if not PetHasActionBar() then return end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local cachedPetButton = petButtonCache[i]
		if cachedPetButton.button:IsVisible() then
			updatePetActionButtonColor(cachedPetButton)
		end
	end
end

-- Initialize pet action button coloring for pet classes
local _, playerClass = UnitClass("player")
if playerClass == "HUNTER" or playerClass == "WARLOCK" then
	-- Hook for instant updates on target change, attack, and follow commands
	hooksecurefunc("PetActionBar_Update", updateAllPetButtons)

	-- Register events for pet mana changes and cooldown updates
	local petEventFrame = CreateFrame("Frame")
	petEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
	petEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	petEventFrame:SetScript("OnEvent", function(_, event, unit)
		if event ~= "UNIT_POWER_UPDATE" or unit == "pet" then
			updateAllPetButtons()
		end
	end)

	-- Ticker polls every 0.2s to catch range changes during pet movement (no event exists for this)
	C_Timer.NewTicker(TOOLTIP_UPDATE_TIME, updateAllPetButtons)
end
