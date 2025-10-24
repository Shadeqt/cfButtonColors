local addon = cfButtonColors
local applyButtonColor = addon.applyButtonColor

-- WoW API calls
local _ActionHasRange = ActionHasRange
local _IsUsableAction = IsUsableAction
local _IsActionInRange = IsActionInRange

-- Watched buttons tracking: only buttons with range indicators
local watchedButtons = {}

-- Check if button should be tracked for color updates
local function shouldWatchButton(button)
	if not button or not button:IsVisible() then return false end
	local action = button.action
	if not action then return false end
	return _ActionHasRange(action)
end

-- Update which buttons are being watched (called when buttons change)
local function updateWatchedButtons(button)
	local shouldWatch = shouldWatchButton(button)
	watchedButtons[button] = shouldWatch or nil
end

-- Update color for player action button based on current state
local function updatePlayerActionButtonColor(button)
	-- Fast path: skip if not in watched list
	if not watchedButtons[button] then
		-- Check if button should now be watched (action might have changed)
		updateWatchedButtons(button)
		if not watchedButtons[button] then
			return
		end
	end

	local action = button.action
	local _, isOutOfMana = _IsUsableAction(action)
	local isOutOfRange = _IsActionInRange(action) == false

	applyButtonColor(button.icon, isOutOfMana, isOutOfRange)
end

-- Update watched status when button content changes
local function onButtonUpdate(button)
	updateWatchedButtons(button)
end

-- Hook into Blizzard's action button update functions
hooksecurefunc("ActionButton_Update", onButtonUpdate)
hooksecurefunc("ActionButton_UpdateUsable", updatePlayerActionButtonColor)
hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerActionButtonColor)
