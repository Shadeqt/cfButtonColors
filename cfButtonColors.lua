-- Addon namespace
cfButtonColors = cfButtonColors or {}
local addon = cfButtonColors

-- Player class detection
local _, playerClass = UnitClass("player")
local isPetClass = (playerClass == "HUNTER" or playerClass == "WARLOCK")
addon.isPetClass = isPetClass

-- SavedVariables initialization
if not cfButtonColorsDB then
    cfButtonColorsDB = {
        showManaColor = true,
        showRangeColor = true,
        enablePetButtons = isPetClass,
    }
end

-- Button state cache
local buttonStates = {}

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
		icon:SetVertexColor(0.1, 0.3, 1.0)
	elseif isOutOfRange then
		icon:SetVertexColor(1.0, 0.3, 0.1)
	elseif isUnusable then
		icon:SetVertexColor(0.4, 0.4, 0.4)
	else
		icon:SetVertexColor(1.0, 1.0, 1.0)
	end
end
