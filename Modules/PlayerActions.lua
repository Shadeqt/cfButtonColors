local addon = cfButtonColors
local applyButtonColor = addon.applyButtonColor

-- Localize for performance
local ActionHasRange = ActionHasRange
local IsUsableAction = IsUsableAction
local IsActionInRange = IsActionInRange

-- Update color for player action button based on current state
local function updatePlayerActionButtonColor(button)
	local action = button.action
	if not ActionHasRange(action) then return end

	local _, isOutOfMana = IsUsableAction(action)
	local isOutOfRange = IsActionInRange(action) == false

	applyButtonColor(button.icon, isOutOfMana, isOutOfRange)
end

-- Hook into Blizzard's action button update functions
hooksecurefunc("ActionButton_UpdateUsable", updatePlayerActionButtonColor)
hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerActionButtonColor)
