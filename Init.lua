-- Lua API
local pairs = pairs
local type = type

-- WoW API
local UnitClass = UnitClass

-- Module Constants
local addon = cfButtonColors or {}
cfButtonColors = addon

-- Module-level state
local _, playerClass = UnitClass("player")

-- Initialization code
addon.isPetClass = (playerClass == "HUNTER" or playerClass == "WARLOCK")

addon.MODULES = {
	PLAYER_MANA = "PlayerMana",
	PLAYER_RANGE = "PlayerRange",
	PET = "Pet",
}

addon.DEFAULT_COLORS = {
	manaColor = {r = 0.1, g = 0.3, b = 1.0},
	rangeColor = {r = 1.0, g = 0.3, b = 0.1},
	unusableColor = {r = 0.4, g = 0.4, b = 0.4},
}

local dbDefaults = {
	[addon.MODULES.PLAYER_MANA] = true,
	[addon.MODULES.PLAYER_RANGE] = true,
	[addon.MODULES.PET] = addon.isPetClass,
	manaColor = addon.DEFAULT_COLORS.manaColor,
	rangeColor = addon.DEFAULT_COLORS.rangeColor,
	unusableColor = addon.DEFAULT_COLORS.unusableColor,
}

-- Database initialization
if not cfButtonColorsDB then
	cfButtonColorsDB = {}
end

-- Apply defaults for any missing keys (adds new settings in updates)
for key, value in pairs(dbDefaults) do
	if cfButtonColorsDB[key] == nil then
		-- Deep copy for color tables
		if type(value) == "table" then
			cfButtonColorsDB[key] = {r = value.r, g = value.g, b = value.b}
		else
			cfButtonColorsDB[key] = value
		end
	end
end

-- Remove keys from DB that aren't in defaults (cleanup deprecated settings)
for key in pairs(cfButtonColorsDB) do
	if dbDefaults[key] == nil then
		cfButtonColorsDB[key] = nil
	end
end
