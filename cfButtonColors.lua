-- WoW constants
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS -- 10, pet action bar slots

-- Module states
local petButtons = {}
for i = 1, NUM_PET_ACTION_SLOTS do
	petButtons[i] = _G["PetActionButton" .. i]
end

local _, playerClass = UnitClass("player")

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

local function updatePlayerButton(button)
    if not button.action then return end
    if not HasAction(button.action) then return end
    
    local isUsable, isOutOfMana = IsUsableAction(button.action)
    local isInRange = IsActionInRange(button.action)
    local isOutOfRange = (isInRange == false or isInRange == 0)
    local isUnusable = not isUsable and not isOutOfMana
    applyButtonColor(button.icon, isOutOfMana, isOutOfRange, isUnusable)
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

hooksecurefunc("ActionButton_UpdateUsable", updatePlayerButton)
hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerButton)

if playerClass == "HUNTER" or playerClass == "WARLOCK" then
	hooksecurefunc("PetActionBar_Update", updatePetButtons)

	C_Timer.NewTicker(0.2, function()
		if PetHasActionBar() and (UnitExists("target") or InCombatLockdown()) then
			updatePetButtons()
		end
	end)
end