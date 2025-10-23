cfButtonColors = {}
local addon = cfButtonColors

-- Apply color tint to button icon: blue (out of mana), red (out of range), white (normal)
function addon.applyButtonColor(icon, isOutOfMana, isOutOfRange)
	if isOutOfMana then
		icon:SetVertexColor(0.1, 0.3, 1.0)
	elseif isOutOfRange then
		icon:SetVertexColor(1.0, 0.3, 0.1)
	else
		icon:SetVertexColor(1.0, 1.0, 1.0)
	end
end
