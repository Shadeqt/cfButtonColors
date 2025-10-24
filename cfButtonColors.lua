cfButtonColors = {}
local addon = cfButtonColors

-- State cache to prevent redundant SetVertexColor calls
local iconStates = {}

-- Color state constants for comparison
local STATE_OUT_OF_MANA = 1
local STATE_OUT_OF_RANGE = 2
local STATE_NORMAL = 3

-- Apply color tint to button icon: blue (out of mana), red (out of range), white (normal)
-- Only updates if state has changed (optimization: prevents redundant texture operations)
function addon.applyButtonColor(icon, isOutOfMana, isOutOfRange)
	-- Determine new state
	local newState
	if isOutOfMana then
		newState = STATE_OUT_OF_MANA
	elseif isOutOfRange then
		newState = STATE_OUT_OF_RANGE
	else
		newState = STATE_NORMAL
	end

	-- Early exit if state unchanged (major optimization)
	if iconStates[icon] == newState then
		return
	end

	-- Update cached state
	iconStates[icon] = newState

	-- Apply color based on new state
	if newState == STATE_OUT_OF_MANA then
		icon:SetVertexColor(0.1, 0.3, 1.0)
	elseif newState == STATE_OUT_OF_RANGE then
		icon:SetVertexColor(1.0, 0.3, 0.1)
	else
		icon:SetVertexColor(1.0, 1.0, 1.0)
	end
end
