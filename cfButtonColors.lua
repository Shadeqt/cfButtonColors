-- WoW constants
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS -- 10, pet action bar slots

-- Module states
local petButtons = {}
for i = 1, NUM_PET_ACTION_SLOTS do
	petButtons[i] = _G["PetActionButton" .. i]
end

local _, playerClass = UnitClass("player")

-- Configuration
local config = {
    showManaColor = true,   -- Set to false to disable mana coloring
    showRangeColor = true,  -- Set to false to disable range coloring
	enablePetButtons = true, -- Set to false to disable pet button coloring
}

local buttonStates = {}

local function getOrCreateState(button)
	local buttonName = button:GetName()
	if not buttonStates[buttonName] then
		buttonStates[buttonName] = {
			isOutOfMana = false,
			isOutOfRange = false,
			isUnusable = false
		}
	end
	return buttonStates[buttonName]
end

local function applyButtonColor(icon, isOutOfMana, isOutOfRange, isUnusable)
	if isOutOfMana then
		icon:SetVertexColor(0.1, 0.3, 1.0)
	elseif isOutOfRange then
		icon:SetVertexColor(1.0, 0.3, 0.1)
	elseif isUnusable then
		icon:SetVertexColor(0.4, 0.4, 0.4)
	else
		icon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

-- HOOK 1: Handles mana/usability coloring
local function updatePlayerButtonUsable(button)
	if not button.action then return end
	if not HasAction(button.action) then return end
	
	local state = getOrCreateState(button)
	
	-- Update mana/usability state
	local isUsable, isOutOfMana = IsUsableAction(button.action)
	state.isOutOfMana = isOutOfMana
	state.isUnusable = not isUsable and not isOutOfMana
	
	-- Apply color with current state (including cached range)
	applyButtonColor(button.icon, state.isOutOfMana, state.isOutOfRange, state.isUnusable)
end

-- HOOK 2: Handles range coloring
local function updatePlayerButtonRange(button)
	if not button.action then return end
	if not HasAction(button.action) then return end
	
	local state = getOrCreateState(button)
	
	-- Update range state
	local isInRange = IsActionInRange(button.action)
	state.isOutOfRange = (isInRange == false or isInRange == 0)
	
	-- Apply color with current state (including cached mana/usability)
	applyButtonColor(button.icon, state.isOutOfMana, state.isOutOfRange, state.isUnusable)
end

local function updatePetButtons()
	if not PetHasActionBar() then return end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local button = petButtons[i]
		if button and button.icon then
			local _, _, _, _, _, _, spellId, hasRangeCheck, isInRange = GetPetActionInfo(i)
			if spellId then
				local isUsable, isOutOfMana = C_Spell.IsSpellUsable(spellId)
				local isOutOfRange = hasRangeCheck and (isInRange == false or isInRange == 0)
				local isUnusable = not isUsable and not isOutOfMana
				applyButtonColor(button.icon, isOutOfMana, isOutOfRange, isUnusable)
			end
		end
	end
end

-- Only register mana hook if mana coloring enabled
if config.showManaColor then
	hooksecurefunc("ActionButton_UpdateUsable", updatePlayerButtonUsable)
end

-- Only register range hook if range coloring enabled
if config.showRangeColor then
	hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerButtonRange)
end

-- Only register pet hooks if enabled and player is hunter/warlock
if (playerClass == "HUNTER" or playerClass == "WARLOCK") and config.enablePetButtons then
	hooksecurefunc("PetActionBar_Update", updatePetButtons)

	C_Timer.NewTicker(0.2, function()
		if PetHasActionBar() and (UnitExists("target") or InCombatLockdown()) then
			updatePetButtons()
		end
	end)
end