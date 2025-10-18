--[[

WikiElement for Item

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"

---@class WEItem : WikiElement
---@field object Item
local WEItem = WikiElement:derive("WEItem")

function WEItem:_getName()
    return self.object:getDisplayName()
end

function WEItem:_getIcon()
    return self.object:getNormalTexture()
end

return WEItem