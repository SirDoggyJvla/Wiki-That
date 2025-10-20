local patch = {}

---CACHE
local WT = require "WikiThat!/module"
require "WikiThat!/main"
--WikiElements
local WETrait = require "WikiThat!/Objects/WikiElements/WETrait"


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
    local context = WT.ingameContextMenu --[[@as ISWikiThatContextMenu]]
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