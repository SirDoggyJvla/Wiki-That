local ISWikiToolTip = ISToolTip:derive("ISWikiToolTip") ---@class ISWikiToolTip : ISToolTip

---CACHE
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
-- local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

ISWikiToolTip.originalRender = ISWikiToolTip.render
function ISWikiToolTip:render()
    local mx = getMouseX() + 32
	local my = getMouseY() + 10
	if not self.followMouse then
		mx = self:getX()
		my = self:getY()
	end
	if self.desiredX and self.desiredY then
		mx = self.desiredX
		my = self.desiredY
	end
	self:setX(mx)
	self:setY(my)

	if self.contextMenu and self.contextMenu.joyfocus then
		local playerNum = self.contextMenu.player
		self:setX(getPlayerScreenLeft(playerNum) + 60);
		self:setY(getPlayerScreenTop(playerNum) + 60);
	elseif self.contextMenu and self.contextMenu.currentOptionRect then
		if self.contextMenu.currentOptionRect.height > 32 then
			self:setY(my + self.contextMenu.currentOptionRect.height)
		end
		self:adjustPositionToAvoidOverlap(self.contextMenu.currentOptionRect)
	elseif self.owner and self.owner.isButton then
		local ownerRect = { x = self.owner:getAbsoluteX(), y = self.owner:getAbsoluteY(), width = self.owner.width, height = self.owner.height }
		self:adjustPositionToAvoidOverlap(ownerRect)
	elseif self.owner and self.owner.Type == "ISSkillProgressBar" then
		local ownerRect = { x = self.owner:getAbsoluteX(), y = self.owner:getAbsoluteY(), width = self.owner.width, height = self.owner.height }
		self:adjustPositionToAvoidOverlap(ownerRect)
	end

	-- big rectangle (our background)
	self:drawRect(0, 0, self.width, self.height, 0.1, 1, 0.6, 0.05)
    local borderColor = self.borderColor
	self:drawRectBorder(0, 0, self.width, self.height, borderColor.a, borderColor.r, borderColor.g, borderColor.b)

	-- render texture
	if self.texture then
		local widthTexture = self.texture:getWidth()
		local heightTexture = self.texture:getHeight()
		local textureY = self.name and 35 or 5
		self:drawTextureScaled(self.texture, 8, textureY, widthTexture, heightTexture, 1, 1, 1, 1)
	end

	-- render name
	if self.name then
		self:drawText(self.name, 8, 5, 1, 1, 1, 1, UIFont.Medium)
	end

	self:renderContents()

	-- render a how to rotate message at the bottom if needed
	if self.footNote then
		local fontHgt = FONT_HGT_SMALL
		self:drawTextCentre(self.footNote, self:getWidth() / 2, self:getHeight() - fontHgt - 4, 1, 1, 1, 1, UIFont.Small)
	end

    local fluid = self.fluid
    if fluid then
        -- find center
        local centerX = self:getWidth() / 2
        local centerY = self:getHeight() / 2
        local w, h = 50,50

        local color = fluid:getColor()
        local r,g,b = color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat()

        -- draw centered rectangle
        self:drawRect(centerX - w / 2, centerY - h / 2, w, h, 1, r, g, b)
    end
end

local function setRGBA(rgba, r, g, b, a)
    rgba.r = r
    rgba.g = g
    rgba.b = b
    rgba.a = a
    return rgba
end

ISWikiToolTip.originalReset = ISWikiToolTip.reset
function ISWikiToolTip:reset()
    ISWikiToolTip.originalReset(self)

    self.fluid = nil

    setRGBA(self.borderColor, 1, 0, 0, 0.2)
    setRGBA(self.backgroundColor, 1, 0.6, 0, 0.1)

    setRGBA(self.descriptionPanel.borderColor, 1, 0, 0, 0.2)
    setRGBA(self.descriptionPanel.backgroundColor, 1, 0.6, 0, 0.1)
end

ISWikiToolTip.originalNew = ISWikiToolTip.new
function ISWikiToolTip:new()
    local o = ISWikiToolTip.originalNew(self)

    o.borderColor = {r=1, g=0, b=0, a=0.2}
    o.backgroundColor = {r=1, g=0.6, b=0, a=0.1}

    o.descriptionPanel.borderColor = {r=1, g=0, b=0, a=0.2}
    o.descriptionPanel.backgroundColor = {r=1, g=0.6, b=0, a=0.1}

    return o
end

return ISWikiToolTip