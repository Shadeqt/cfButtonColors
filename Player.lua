local addon = cfButtonColors

-- Updates button color based on mana/usability state
local function updatePlayerButtonUsable(button)
	if not button.action then return end
	if not HasAction(button.action) then return end

	local state = addon.getOrCreateState(button)
	local isUsable, isOutOfMana = IsUsableAction(button.action)
	state.isOutOfMana = isOutOfMana
	state.isUnusable = not isUsable and not isOutOfMana

	addon.applyButtonColor(button.icon, state.isOutOfMana, state.isOutOfRange, state.isUnusable)
end

-- Updates button color based on range state
local function updatePlayerButtonRange(button)
	if not button.action then return end
	if not HasAction(button.action) then return end

	local state = addon.getOrCreateState(button)
	local isInRange = IsActionInRange(button.action)
	state.isOutOfRange = (isInRange == false or isInRange == 0)

	addon.applyButtonColor(button.icon, state.isOutOfMana, state.isOutOfRange, state.isUnusable)
end

-- Hook: ActionButton_UpdateUsable (conditional on config)
if cfButtonColorsDB.PlayerMana then
	hooksecurefunc("ActionButton_UpdateUsable", updatePlayerButtonUsable)
end

-- Hook: ActionButton_UpdateRangeIndicator (conditional on config)
if cfButtonColorsDB.PlayerRange then
	hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerButtonRange)
end
