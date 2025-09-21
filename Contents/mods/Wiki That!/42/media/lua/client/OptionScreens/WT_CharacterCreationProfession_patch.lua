local patch = {CharacterCreationProfession = {}}

---CACHE
local WT = require "WT_module"
require "WT_main"

---Hook into the profession creation screen to add right click context menu to traits
patch.CharacterCreationProfession.original_create = CharacterCreationProfession.create
function CharacterCreationProfession:create()
    patch.CharacterCreationProfession.original_create(self)

    -- add right click context menu to traits list
    self.listboxTraitSelected.onRightMouseDown = patch.onRightClickTrait
    self.listboxTrait.onRightMouseDown = patch.onRightClickTrait
    self.listboxBadTrait.onRightMouseDown = patch.onRightClickTrait
end

---Initialize the context menu for right clicking traits
patch.traitContextMenu = ISContextMenu:new(0,0,1,1,1.5) --[[@as ISContextMenu]]
patch.traitContextMenu:initialise()
patch.traitContextMenu:addToUIManager()
patch.traitContextMenu:setVisible(false)
patch.traitContextMenu.onMouseMove = patch.onMouseMove

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

patch.onRightClickTrait = function(self, x, y)
    self:onMouseDown(x, y)

    print(self.Type) -- CharacterCreationProfessionListBox
    print(self.target and self.target.Type or "no target") -- CharacterCreationProfession
    print("Right click on trait")

    if self.selected then
        local context = patch.traitContextMenu
        context = patch.resetContextMenu(context,getMouseX(), getMouseY())
        -- context:addOption("Test", self.target, patch.wikiTrait, self)

        local trait = self.items[self.selected].item
        local uniqueEntries = {[trait:getType()] = trait,}
        WT.populateDictionary(context, uniqueEntries)

        context:addOption("Test", self.target, patch.wikiTrait, self)
    end

    -- context.mouseOver = 1
end

patch.wikiTrait = function(professionMenu, listBox)
    print("open wiki for trait")
    print(listBox.selected)
    print(listBox.items[listBox.selected].item)
    print(listBox.items[listBox.selected])
    printTable(listBox.items[listBox.selected])

    local trait = listBox.items[listBox.selected].item

    local isTraitFactoryTrait = string.find(tostring(trait), "TraitFactory.Trait")

    local uniqueEntries = {[trait:getType()] = trait,}
    -- WT.populateDictionary(context, uniqueEntries)
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

-- patch.original_instantiate = MainScreen.instantiate
-- function MainScreen:instantiate()
--     patch.original_instantiate(self)

--     self.traitContextMenu = patch.traitContextMenu
--     self:addChild(self.traitContextMenu)
--     -- self.traitContextMenu:create()
-- end

return patch