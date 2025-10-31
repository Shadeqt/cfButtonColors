-- Apply color tint to button icon: blue (no mana), red (out of range), white (usable)
local function applyButtonColor(icon, isOutOfMana, isOutOfRange)
    if isOutOfMana then
        icon:SetVertexColor(0.1, 0.3, 1.0)  -- Blue
    elseif isOutOfRange then
        icon:SetVertexColor(1.0, 0.3, 0.1)  -- Red
    else
        icon:SetVertexColor(1.0, 1.0, 1.0)  -- White
    end
end

-- Update color for single player action button based on mana and range status
local function updatePlayerButton(button)
    if button and button.action and HasAction(button.action) then
        local _, isOutOfMana = IsUsableAction(button.action)
        local isInRange = IsActionInRange(button.action)
        applyButtonColor(button.icon, isOutOfMana, isInRange == false)
    end
end

-- Hook player button usability updates for immediate mana state coloring
hooksecurefunc("ActionButton_UpdateUsable", updatePlayerButton)

-- Hook player button range updates for immediate range state coloring
hooksecurefunc("ActionButton_UpdateRangeIndicator", updatePlayerButton)

-- Pre-cache pet button references to avoid repeated _G lookups during updates
local petButtons = {}
for i = 1, NUM_PET_ACTION_SLOTS do
    petButtons[i] = _G["PetActionButton" .. i]
end

-- Update colors for all pet action buttons with mana and range checking
local function updatePetButtons()
    if not PetHasActionBar() then return end
    for i = 1, NUM_PET_ACTION_SLOTS do
        local button = petButtons[i]
        if button and button.icon then
            local _, _, _, _, _, _, spellId, hasRangeCheck, isInRange = GetPetActionInfo(i)
            if spellId then
                local _, isOutOfMana = C_Spell.IsSpellUsable(spellId)
                local isOutOfRange = hasRangeCheck and not isInRange
                applyButtonColor(button.icon, isOutOfMana, isOutOfRange)
            end
        end
    end
end

-- Initialize pet coloring system only for Hunter/Warlock classes with pets
local _, playerClass = UnitClass("player")
if playerClass == "HUNTER" or playerClass == "WARLOCK" then
    -- Hook pet bar updates for immediate coloring when pet abilities change
    hooksecurefunc("PetActionBar_Update", updatePetButtons)

    -- Poll pet range every 0.2s during combat/targeting since pets move independently
    C_Timer.NewTicker(0.2, function()
        if PetHasActionBar() and (UnitExists("target") or InCombatLockdown()) then
            updatePetButtons()
        end
    end)
end