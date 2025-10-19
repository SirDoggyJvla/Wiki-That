local patch = {CharacterCreationProfession = {}}

---CACHE
local WT = require "WikiThat!/module"
require "WikiThat!/main"
local WT_utility = require "WikiThat!/utility"
local ISWikiThatContextMenu = require "WikiThat!/ISUI/ISWikiThatContextMenu"
--WikiElements
local WETrait = require "WikiThat!/Objects/WikiElements/WETrait"

---Hook into the profession creation screen to add right click context menu to traits
patch.CharacterCreationProfession.original_create = CharacterCreationProfession.create
function CharacterCreationProfession:create()
    patch.CharacterCreationProfession.original_create(self)

    -- add right click context menu to traits list
    self.listboxTraitSelected.onRightMouseDown = patch.onRightClickTrait
    self.listboxTrait.onRightMouseDown = patch.onRightClickTrait
    self.listboxBadTrait.onRightMouseDown = patch.onRightClickTrait
    self.listboxProf.onRightMouseDown = patch.onRightClickProfession
end

---Initialize the context menu for right clicking traits
patch.traitContextMenu = ISWikiThatContextMenu:new(0,0,1,1,1.5) --[[@as ISWikiThatContextMenu]]
patch.traitContextMenu:initialise()
patch.traitContextMenu:addToUIManager()
patch.traitContextMenu:setVisible(false)
patch.traitContextMenu.keepOnScreen = false


patch.onRightClickTrait = function(self, x, y)
    self:onMouseDown(x, y) -- update selected item

    -- wiki that the selected trait
    if self.selected then
        -- init context menu
        local context = patch.traitContextMenu
        context = context:resetContextMenu(getMouseX(), getMouseY())

        -- populate context menu for wiki that
        local trait = self.items[self.selected].item --[[@as Trait]]
        local type = trait:getType()
        local uniqueEntries = {[type] = WETrait:new(trait, type, "Trait"),}
        WT.populateDictionary(context, uniqueEntries)
    end
end

patch.onRightClickProfession = function(self, x, y)
    self:onMouseDown(x, y) -- update selected item

    -- wiki that the selected profession
    if self.selected then
        -- init context menu
        local context = patch.traitContextMenu
        context = context:resetContextMenu(getMouseX(), getMouseY())

        -- populate context menu for wiki that
        local profession = self.items[self.selected].item --[[@as Profession]]
        local type = profession:getType()
        local uniqueEntries = {[type] = WETrait:new(profession, type, "Profession"),}
        WT.populateDictionary(context, uniqueEntries)
    end
end

return patch