
---@class ISWikiThatContextMenu : ISContextMenu
local ISWikiThatContextMenu = ISContextMenu:derive("ISWikiThatContextMenu")

---CACHE
local SLIDEY = 10

function ISWikiThatContextMenu:topmostMenuWithMouse(x, y)
	local contextMenu = self
	if not contextMenu then return nil end
	local menu = nil
	if self == contextMenu then
		if self:isVisible() and x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height then
			menu = self
		end
	end
	for i=1,#contextMenu.instanceMap do
		local m = contextMenu.instanceMap[i]
		if m:isVisible() and x >= m.x and x < m.x + m.width and y >= m.y and y < m.y + m.height then
			menu = m
		end
	end
	return menu
end

---Commented out the check for top most menu so that the context menu gets updated and is usable.
---@param self ISContextMenu --instance
---@param dx integer
---@param dy integer
function ISWikiThatContextMenu:onMouseMove(dx, dy)
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


function ISWikiThatContextMenu:resetContextMenu(x, y)
    local player = 0
    local context = self
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

function ISWikiThatContextMenu:adjustX()
	local screenW = getCore():getScreenWidth()
	local goLeft
	if self.x + self.width - 20 > screenW then
		goLeft = true
	end

	if not goLeft then return end

	local m_x = getMouseX()
	local x = m_x - self.width

	self:setSlideGoalX(self.x, x)
end

return ISWikiThatContextMenu