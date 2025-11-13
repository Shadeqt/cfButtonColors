-- Module Constants
local addon = cfButtonColors or {}
cfButtonColors = addon

-- Module-level state
local buttonStates = {}

-- Shared Functions
-- Retrieves or creates a state object for tracking button status
function addon.getOrCreateState(button)
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

-- Applies color to button icon based on state priority (mana > range > unusable)
function addon.applyButtonColor(icon, isOutOfMana, isOutOfRange, isUnusable)
	if isOutOfMana then
		local c = cfButtonColorsDB.manaColor
		icon:SetVertexColor(c.r, c.g, c.b)
	elseif isOutOfRange then
		local c = cfButtonColorsDB.rangeColor
		icon:SetVertexColor(c.r, c.g, c.b)
	elseif isUnusable then
		local c = cfButtonColorsDB.unusableColor
		icon:SetVertexColor(c.r, c.g, c.b)
	else
		icon:SetVertexColor(1.0, 1.0, 1.0)
	end
end
