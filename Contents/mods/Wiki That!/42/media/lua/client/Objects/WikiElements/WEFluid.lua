--[[

WikiElement for Fluids

]]

local WikiElement = require "Objects/WikiElement"

---@class WEFluid : WikiElement
---@field object Fluid
local WEFluid = WikiElement:derive("WEFluid")

function WEFluid:_getName()
    return self.object:getDisplayName()
end

function WEFluid:_getIcon()
    return getTexture("Item_Waterdrop_Grey.png")
end

function WEFluid:getTooltipContent()
    local color = self.object:getColor()
    local r,g,b = color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat()
    local w,h = 50,50

    return "<FLUIDBOXCENTRE:"..w..","..h..","..r..","..g..","..b..">\n" .. (self:getName() or "")
end

return WEFluid