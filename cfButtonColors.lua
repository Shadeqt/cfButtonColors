cfButtonColors = {}
local addon = cfButtonColors

-- Get RGB color values based on button state: blue (out of mana), red (out of range), white (normal)
function addon.getButtonColorRGB(isOutOfMana, isOutOfRange)
	if isOutOfMana then
		return 0.1, 0.3, 1.0  -- Blue
	elseif isOutOfRange then
		return 1.0, 0.3, 0.1  -- Red
	else
		return 1.0, 1.0, 1.0  -- White
	end
end

-- Apply color tint to button icon
function addon.applyButtonColor(icon, isOutOfMana, isOutOfRange)
	local r, g, b = addon.getButtonColorRGB(isOutOfMana, isOutOfRange)
	icon:SetVertexColor(r, g, b)
end
