-- Marks any action button holding a spell that is a lower rank than the highest
-- rank of that spell you have trained (e.g. Frostbolt R6 slotted while R7 is known)
-- with a red "!" on the left of the button.
--
-- A trained-rank map is rebuilt from the spellbook on SPELLS_CHANGED (so training a
-- higher rank lights up an already-slotted lower one). Per-button overlays refresh
-- via the ActionButton_Update hook (paging/stance swaps, and the initial draw that
-- populates `buttons`) plus ACTIONBAR_SLOT_CHANGED (drag edits). Before the spellbook
-- is read the map is empty, so nothing flags until we have real data.

local _, addon = ...

local trainedMax = {}     -- spell name -> highest trained rank number
local buttons = {}        -- set of action buttons the hook has touched, for re-scans

-- "Rank 6" / "Rang 6" / "Rank 6 " -> 6, else nil (spells without ranks).
local function rankNumber(rankText)
    return rankText and tonumber(rankText:match("%d+"))
end

-- Walk the spellbook tabs and record the highest rank seen for each spell name.
local function buildTrainedMax()
    local result = {}
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        for i = offset + 1, offset + numSpells do
            local itemType = GetSpellBookItemInfo(i, "spell")
            if itemType == "SPELL" then
                local name, rankText = GetSpellBookItemName(i, "spell")
                local r = rankNumber(rankText)
                if name and r and (not result[name] or r > result[name]) then
                    result[name] = r
                end
            end
        end
    end
    return result
end

-- Does this named spell at this rank fall below the highest rank we have trained?
-- Unranked spells (rankText with no number) never flag.
local function belowMax(name, rankText)
    local r = rankNumber(rankText)
    if not name or not r then return false end
    local maxR = trainedMax[name]
    return maxR ~= nil and r < maxR
end

-- A macro flags if any explicit rank it references (e.g. "/cast Regrowth(Rank 1)")
-- is below trained max. Casts with no rank auto-pick the highest, so they're ignored.
-- The name capture greedily grabs letters/spaces before "(Rank N)", then we trim the
-- leading macro command word (cast/use/castsequence...).
local function macroOutdated(id)
    local _, _, body = GetMacroInfo(id)
    if not body then return false end
    for name, num in body:gmatch("([%a%s'’]+)%(%s*[Rr]ank%s*(%d+)%s*%)") do
        name = name:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^%l+%s+", "")
        if belowMax(name, num) then return true end
    end
    return false
end

-- Is the spell/macro in this action slot using a lower rank than we have trained?
local function isOutdated(slot)
    local actionType, id = GetActionInfo(slot)
    if not id then return false end
    if actionType == "spell" then
        -- GetSpellInfo no longer returns rank in 1.15; the subtext comes from GetSpellSubtext.
        return belowMax((GetSpellInfo(id)), GetSpellSubtext(id))
    elseif actionType == "macro" then
        return macroOutdated(id)
    end
    return false
end

local MARKER = addon.colors.MARKER

-- The same "!" cfItemColors uses for begins-quest items (the gossip available-quest
-- icon), anchored at the top-left of the button and tinted pure red (MARKER).
-- Created lazily and reused.
local function ensureOverlay(button)
    if button.cfRankMarker then return button.cfRankMarker end
    local marker = button:CreateTexture(nil, "OVERLAY")
    marker:SetSize(16, 16)
    marker:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
    marker:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
    marker:SetVertexColor(MARKER[1], MARKER[2], MARKER[3])
    marker:Hide()
    button.cfRankMarker = marker
    return marker
end

local function updateButton(button)
    local slot = button.action
    if not slot then return end
    buttons[button] = true
    if isOutdated(slot) then
        ensureOverlay(button):Show()
    elseif button.cfRankMarker then
        button.cfRankMarker:Hide()
    end
end

local function refreshAll()
    for button in pairs(buttons) do
        updateButton(button)
    end
end

hooksecurefunc("ActionButton_Update", updateButton)

local events = CreateFrame("Frame")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
events:SetScript("OnEvent", function(_, event)
    if event == "SPELLS_CHANGED" then
        trainedMax = buildTrainedMax()
    end
    refreshAll()
end)
