-- Tint the player's action-bar icons soft red when out of range.
-- Yields to Blizzard's OOM (blue) and unusable (grey) — only paints when the icon
-- would otherwise be plain white. ActionButton_OnUpdate's rangeTimer only calls
-- UpdateRangeIndicator (not UpdateUsable), so we must delegate to UpdateUsable
-- ourselves on the in-range branch to clear our red paint.

local _, addon = ...
local OOR = addon.colors.OOR

hooksecurefunc("ActionButton_UpdateRangeIndicator", function(button)
    if not button.icon or not button.action or not HasAction(button.action) then return end
    local inRange = IsActionInRange(button.action)
    if inRange == false or inRange == 0 then
        local isUsable, notEnoughMana = IsUsableAction(button.action)
        if isUsable and not notEnoughMana then
            button.icon:SetVertexColor(OOR[1], OOR[2], OOR[3])
        end
    else
        ActionButton_UpdateUsable(button)
    end
end)
