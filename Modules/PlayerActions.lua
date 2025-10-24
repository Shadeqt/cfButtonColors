local addon = cfButtonColors
local applyButtonColor = addon.applyButtonColor

-- Lua built-ins
local hooksecurefunc = hooksecurefunc

-- WoW API calls
local _ActionHasRange = ActionHasRange
local _IsUsableAction = IsUsableAction
local _IsActionInRange = IsActionInRange

-- State cache to prevent redundant SetVertexColor calls
local iconStates = {}

-- Color state constants for comparison
local STATE_OUT_OF_MANA = 1
local STATE_OUT_OF_RANGE = 2
local STATE_NORMAL = 3

-- Determine color state based on mana and range
local function getColorState(isOutOfMana, isOutOfRange)
	if isOutOfMana then
		return STATE_OUT_OF_MANA
	elseif isOutOfRange then
		return STATE_OUT_OF_RANGE
	else
		return STATE_NORMAL
	end
end

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

	-- Determine new state
	local newState = getColorState(isOutOfMana, isOutOfRange)

	-- Early exit if state unchanged (optimization: prevents redundant texture operations)
	if iconStates[button.icon] == newState then
		return
	end

	-- Update cached state
	iconStates[button.icon] = newState

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
