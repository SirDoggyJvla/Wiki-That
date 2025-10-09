--[[

WikiElement for InventoryItem
This also applies to InventoryItems which are Medias and Moveables

]]

local WikiElement = require "Objects/WikiElement"

---@class WEInventoryItem : WikiElement
---@field object InventoryItem
local WEInventoryItem = WikiElement:derive("WEInventoryItem")

function WEInventoryItem:_getName()
    return self.object:getDisplayName()
end

function WEInventoryItem:_getIcon()
    return self.object:getTexture()
end

return WEInventoryItem