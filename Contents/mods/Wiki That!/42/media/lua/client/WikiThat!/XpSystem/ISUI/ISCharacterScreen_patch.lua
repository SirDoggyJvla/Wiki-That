local patch = {}

---CACHE
local WT = require "WikiThat!/module"
require "WikiThat!/main"
local WT_utility = require "WikiThat!/utility"
local ISWikiThatContextMenu = require "WikiThat!/ISUI/ISWikiThatContextMenu"
--WikiElements
local WETrait = require "WikiThat!/Objects/WikiElements/WETrait"



patch.traitContextMenu = ISWikiThatContextMenu:new(0,0,1,1,1.5) --[[@as ISWikiThatContextMenu]]

WT.OnInitGlobalModData = function(_)
    patch.traitContextMenu:initialise()
    patch.traitContextMenu:addToUIManager()
    patch.traitContextMenu:setVisible(false)
    patch.traitContextMenu.keepOnScreen = false
end

---@DEBUG
local function printTable(tbl, maxLvl, _lvl)
    if type(tbl) ~= "table" then print("not a table") return end
    _lvl = _lvl or 0
    maxLvl = maxLvl or 2
    for k, v in pairs(tbl) do
        DebugLog.log(string.rep(" ", _lvl * 4) .. tostring(k) .. " " .. tostring(v))
        -- DebugLog.log(tostring(k))
        if type(v) == "table" and _lvl < maxLvl then
            printTable(v, maxLvl, _lvl + 1)
        end
    end
end

patch.onRightMouseDown = function(self, x, y)
    -- init context menu
    local context = patch.traitContextMenu
    context = context:resetContextMenu(getMouseX(), getMouseY())

    -- populate context menu for wiki that
    local trait = self.trait --[[@as Trait]]
    local type = trait:getType()
    local wikiElement = WETrait:new(trait, type, "Trait")
    local uniqueEntries = {[type] = wikiElement,}
    WT.populateDictionary(context, uniqueEntries)
end


local original_ISCharacterScreen_loadTraits = ISCharacterScreen.loadTraits
function ISCharacterScreen:loadTraits()
    original_ISCharacterScreen_loadTraits(self)
    local traits = self.traits
    for i = 1, #traits do
        local trait = traits[i]
        trait.onRightMouseDown = patch.onRightMouseDown
    end
end

return patch