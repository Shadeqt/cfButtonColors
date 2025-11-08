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
        enablePlayerMana = true,
        enablePlayerRange = true,
        enablePet = isPetClass,
        manaColor = {r = 0.1, g = 0.3, b = 1.0},
        rangeColor = {r = 1.0, g = 0.3, b = 0.1},
        unusableColor = {r = 0.4, g = 0.4, b = 0.4},
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
