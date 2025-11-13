-- Localize for performance and consistency
local db = cfButtonColorsDB
local addon = cfButtonColors

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
		local c = db.manaColor
		icon:SetVertexColor(c.r, c.g, c.b)
	elseif isOutOfRange then
		local c = db.rangeColor
		icon:SetVertexColor(c.r, c.g, c.b)
	elseif isUnusable then
		local c = db.unusableColor
		icon:SetVertexColor(c.r, c.g, c.b)
	else
		icon:SetVertexColor(1.0, 1.0, 1.0)
	end
end
