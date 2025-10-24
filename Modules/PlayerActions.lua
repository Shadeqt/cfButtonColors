local addon = cfButtonColors
local applyButtonColor = addon.applyButtonColor

-- Localized API calls
local _ActionHasRange = ActionHasRange
local _IsUsableAction = IsUsableAction
local _IsActionInRange = IsActionInRange

-- Update color for player action button based on current state
local function updatePlayerActionButtonColor(button)
	local action = button.action
	if not _ActionHasRange(action) then return end

	local _, isOutOfMana = _IsUsableAction(action)
	local isOutOfRange = _IsActionInRange(action) == false

	applyButtonColor(button.icon, isOutOfMana, isOutOfRange)
end

-- Hook into Blizzard's action button update functions
hooksecurefunc("ActionButton_UpdateUsable", updatePlayerActionButtonColor)
hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerActionButtonColor)
