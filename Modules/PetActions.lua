local addon = cfButtonColors
local getButtonColorRGB = addon.getButtonColorRGB

-- Lua built-ins
local select = select
local hooksecurefunc = hooksecurefunc

-- WoW API calls
local _GetPetActionInfo = GetPetActionInfo
local _PetHasActionBar = PetHasActionBar
local _UnitClass = UnitClass
local _CreateFrame = CreateFrame
local _C_Spell = C_Spell
local _C_Timer = C_Timer
local _UnitExists = UnitExists
local _InCombatLockdown = InCombatLockdown

-- Constants
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local TOOLTIP_UPDATE_TIME = TOOLTIP_UPDATE_TIME

-- Cache pet action button references and block Blizzard's SetVertexColor
local petButtonCache = {}
for i = 1, NUM_PET_ACTION_SLOTS do
	local button = _G["PetActionButton"..i]
	local icon = button.icon

	-- Disable Blizzard's OnUpdate range coloring
	button:SetScript("OnUpdate", nil)

	-- Store original SetVertexColor and block Blizzard from changing colors
	local originalSetVertexColor = icon.SetVertexColor
	icon.SetVertexColor = function() end  -- Block all external calls

	petButtonCache[i] = {
		button = button,
		buttonSlot = i,
		icon = icon,
		setColor = originalSetVertexColor  -- Direct access to original function
	}
end

-- State cache to prevent redundant SetVertexColor calls
local buttonStates = {}

-- Update color for pet action button based on range and mana
local function updatePetActionButtonColor(cachedPetButton)
	local _, _, _, _, _, _, spellId, hasRangeCheck, isInRange = _GetPetActionInfo(cachedPetButton.buttonSlot)

	if not spellId then return end

	local isOutOfMana = select(2, _C_Spell.IsSpellUsable(spellId))
	local isOutOfRange = hasRangeCheck and not isInRange

	local buttonSlot = cachedPetButton.buttonSlot
	local lastState = buttonStates[buttonSlot]

	-- Early exit if state unchanged
	if lastState
	   and lastState.isOutOfMana == isOutOfMana
	   and lastState.isOutOfRange == isOutOfRange then
		return
	end

	-- Update cached state
	buttonStates[buttonSlot] = {
		isOutOfMana = isOutOfMana,
		isOutOfRange = isOutOfRange
	}

	-- Apply color using direct SetVertexColor (bypasses Blizzard blocking)
	local r, g, b = getButtonColorRGB(isOutOfMana, isOutOfRange)
	cachedPetButton.setColor(cachedPetButton.icon, r, g, b)
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
	-- Hook for instant updates on pet bar changes
	hooksecurefunc("PetActionBar_Update", function()
		PetActionBarFrame.rangeTimer = nil
		updateAllPetButtons()
	end)

	-- Register events for pet mana changes and cooldown updates
	local petEventFrame = _CreateFrame("Frame")
	petEventFrame:RegisterEvent("UNIT_POWER_UPDATE")
	petEventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	petEventFrame:SetScript("OnEvent", function(_, event, unit)
		if event == "UNIT_POWER_UPDATE" and unit == "pet" then
			updateAllPetButtons()
		elseif event == "SPELL_UPDATE_COOLDOWN" then
			updateAllPetButtons()
		end
	end)

	-- Ticker polls every 0.2s to catch range changes during pet movement
	-- Only polls when player has target or is in combat
	_C_Timer.NewTicker(TOOLTIP_UPDATE_TIME, function()
		if _UnitExists("target") or _InCombatLockdown() then
			updateAllPetButtons()
		end
	end)
end
