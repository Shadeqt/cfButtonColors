-- Localize for performance and consistency
local db = cfButtonColorsDB
local addon = cfButtonColors

-- Initialization code
if not db[addon.MODULES.PET] then return end

-- WoW constants
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS -- 10, number of pet action buttons

-- Functions
-- Updates all pet button colors based on mana, range, and usability
local function updatePetButtons()
	if not PetHasActionBar() then return end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local button = _G["PetActionButton" .. i]
		if button and button.icon then
			local _, _, _, _, _, _, spellId, hasRangeCheck, isInRange = GetPetActionInfo(i)
			if spellId then
				local isUsable, isOutOfMana = C_Spell.IsSpellUsable(spellId)
				local isOutOfRange = hasRangeCheck and (isInRange == false or isInRange == 0)
				local isUnusable = not isUsable and not isOutOfMana
				addon.applyButtonColor(button.icon, isOutOfMana, isOutOfRange, isUnusable)
			end
		end
	end
end

-- Event Handlers / Hooks
-- Hook: PetActionBar_Update and timer
hooksecurefunc("PetActionBar_Update", updatePetButtons)

C_Timer.NewTicker(0.2, function()
	if PetHasActionBar() and (UnitExists("target") or UnitPower("pet") < UnitPowerMax("pet")) then
		updatePetButtons()
	end
end)
