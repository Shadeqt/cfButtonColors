-- Shared color palette for cfActionButtons. Single source of truth so the OOM/OOR
-- tints stay identical across the player and pet bars — change a value here and every
-- file picks it up. Loaded first (see .toc) so addon.colors exists before the others run.
local _, addon = ...

addon.colors = {
    -- Out of mana: Blizzard's authentic action-button tint. ActionButton_UpdateUsable
    -- calls icon:SetVertexColor(0.5, 0.5, 1.0) with no alpha (full opacity).
    OOM = { 0.5, 0.5, 1.0 },

    -- Out of range: a lifted red for icon tints. Blizzard's authentic value (1.0, 0.1,
    -- 0.1) is meant for the hotkey *text*; as a multiplicative icon tint its near-zero
    -- green/blue crush the icon dark, so we raise the floor to keep icons legible.
    OOR = { 1.0, 0.3, 0.3 },

    -- Pure red for the outdated-rank "!". Safe here (unlike a spell icon) because the
    -- marker glyph is near-solid yellow, so the multiply leaves a clean bright red.
    MARKER = { 1, 0, 0 },
}
