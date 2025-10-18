local patch = {CharacterCreationProfession = {}}

---CACHE
local WT = require "WikiThat!/WT_module"
require "WikiThat!/WT_main"
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
patch.traitContextMenu = ISContextMenu:new(0,0,1,1,1.5) --[[@as ISContextMenu]]
patch.traitContextMenu:initialise()
patch.traitContextMenu:addToUIManager()
patch.traitContextMenu:setVisible(false)
patch.traitContextMenu.onMouseMove = patch.onMouseMove
patch.traitContextMenu.keepOnScreen = false

patch.onRightClickTrait = function(self, x, y)
    self:onMouseDown(x, y) -- update selected item

    -- wiki that the selected trait
    if self.selected then
        -- init context menu
        local context = patch.traitContextMenu
        context = patch.resetContextMenu(context,getMouseX(), getMouseY())

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
        context = patch.resetContextMenu(context, getMouseX(), getMouseY())

        -- populate context menu for wiki that
        local profession = self.items[self.selected].item --[[@as Profession]]
        local type = profession:getType()
        local uniqueEntries = {[type] = WETrait:new(profession, type, "Profession"),}
        WT.populateDictionary(context, uniqueEntries)
    end
end

---Commented out the check for top most menu so that the context menu gets updated and is usable.
---@param self ISContextMenu --instance
---@param dx integer
---@param dy integer
patch.traitContextMenu.onMouseMove = function(self, dx, dy)
	self.mouseOut = false
	-- if self:topmostMenuWithMouse(getMouseX(), getMouseY()) ~= self then return end
    local mouseY = self:getMouseY()
	local dy = (self:getScrollHeight() > self:getScrollAreaHeight()) and self.scrollIndicatorHgt or 0
	mouseY = math.max(self.padTopBottom + dy - self:getYScroll(), mouseY)
	mouseY = math.min(self.padTopBottom + dy + self:getScrollAreaHeight() - 1 - self:getYScroll(), mouseY)
	local index = self:getIndexAt(0, mouseY)
	if index ~= -1 then
		if self.subMenu and (index ~= self.mouseOver) then
			self.subMenu:hideSelfAndChildren2()
			self.subMenu = nil
		end
	end
	self.mouseOver = index
end

local SLIDEY = 10
patch.resetContextMenu = function(context,x,y)
    local player = 0
    context:hideAndChildren()
    context:setVisible(true)
    context:clear()
    context:setFontFromOption()
	context.forceVisible = true
    context.parent = nil
    context.requestX = x
    context.requestY = y
    context:setSlideGoalX(x + 20, x)
    context:setSlideGoalY(y - SLIDEY, y)
    context:bringToTop()
    context:setVisible(true)
    context.visibleCheck = true
    if context.instanceMap then
        for _,v in pairs(context.instanceMap) do
            v:setVisible(false)
            v:removeFromUIManager()
            table.insert(context.subMenuPool, v)
        end
        table.wipe(context.instanceMap)
    end
    context.instanceMap = context.instanceMap or {}
    context.subMenuPool = context.subMenuPool or {}
    context.subOptionNums = 0
    context.subInstance = nil
    context.subMenu = nil
	context.player = player
	context:setForceCursorVisible(false)
	return context
end

return patch