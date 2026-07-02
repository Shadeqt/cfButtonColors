-- Tint pet action-bar icons: blue when out of mana, red when out of range. Mana wins.
-- Hunter / Warlock only (the rest have no persistent pet bar in Classic Era).

local _, addon = ...

local _, class = UnitClass("player")
if class ~= "HUNTER" and class ~= "WARLOCK" then return end

local OOM, OOR = addon.colors.OOM, addon.colors.OOR

local function Update()
    if not PetHasActionBar() then return end
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = _G["PetActionButton" .. i]
        if button and button.icon then
            local _, _, _, _, _, _, spellId, hasRange, inRange = GetPetActionInfo(i)
            if spellId then
                local _, oom = C_Spell.IsSpellUsable(spellId)
                local oor = hasRange and (inRange == false or inRange == 0)
                if oom then
                    button.icon:SetVertexColor(OOM[1], OOM[2], OOM[3])
                elseif oor then
                    button.icon:SetVertexColor(OOR[1], OOR[2], OOR[3])
                else
                    button.icon:SetVertexColor(1, 1, 1)
                end
            end
        end
    end
end

hooksecurefunc("PetActionBar_Update", Update)

-- Blizzard's PetActionBar_Update only fires on layout changes — range and mana flip
-- mid-combat without an event, so poll. Gated to skip idle work.
C_Timer.NewTicker(0.2, function()
    if PetHasActionBar()
       and (UnitCanAttack("player", "target") or UnitPower("pet") < UnitPowerMax("pet")) then
        Update()
    end
end)
