-- Create addon namespace
cfButtonColors = {}

-- Localize for performance and consistency
local db = cfButtonColorsDB
local addon = cfButtonColors

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
if not db then
	db = {}
	cfButtonColorsDB = db
end

-- Apply defaults for any missing keys (adds new settings in updates)
for key, value in pairs(dbDefaults) do
	if db[key] == nil then
		-- Deep copy for color tables
		if type(value) == "table" then
			db[key] = {r = value.r, g = value.g, b = value.b}
		else
			db[key] = value
		end
	end
end

-- Remove keys from DB that aren't in defaults (cleanup deprecated settings)
for key in pairs(db) do
	if dbDefaults[key] == nil then
		db[key] = nil
	end
end
