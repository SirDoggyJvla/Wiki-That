local ISWikiToolTip = ISToolTip:derive("ISWikiToolTip") ---@class ISWikiToolTip : ISToolTip

---CACHE
local WT = require "WT_module"
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
	local backgroundColor = self.backgroundColor
	self:drawRect(0, 0, self.width, self.height, backgroundColor.a, backgroundColor.r, backgroundColor.g, backgroundColor.b)
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

	--- DRAW FLUID BOX
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

local function copyTbl(tbl)
	local t = {}
	for k,v in pairs(tbl) do
		t[k] = v
	end
	return t
end

ISWikiToolTip.originalReset = ISWikiToolTip.reset
function ISWikiToolTip:reset()
    ISWikiToolTip.originalReset(self)

    self.fluid = nil

	-- -- override previously set border and background colors
	-- self.borderColor = copyTbl(WT.backgroundColor_highlight)
	-- self.backgroundColor = copyTbl(WT.backgroundColor_darkest)

	-- self.descriptionPanel.borderColor = copyTbl(WT.backgroundColor_highlight)
	-- self.descriptionPanel.backgroundColor = copyTbl(WT.backgroundColor_darkest)
end

ISWikiToolTip.originalNew = ISWikiToolTip.new
function ISWikiToolTip:new()
    local o = ISWikiToolTip.originalNew(self)

	-- -- set colors
	-- o.borderColor = copyTbl(WT.backgroundColor_highlight)
	-- o.backgroundColor = copyTbl(WT.backgroundColor_darkest)

	-- o.descriptionPanel.borderColor = copyTbl(WT.backgroundColor_highlight)
	-- o.descriptionPanel.backgroundColor = copyTbl(WT.backgroundColor_darkest)

    return o
end

return ISWikiToolTip