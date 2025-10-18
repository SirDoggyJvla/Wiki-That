--[[

WikiElement for IsoAnimal

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"

---@class WEIsoAnimal : WikiElement
---@field object IsoAnimal
local WEIsoAnimal = WikiElement:derive("WEIsoAnimal")

function WEIsoAnimal:_getName()
    return self.object:getFullName()
end

function WEIsoAnimal:_getIcon()
    return self.object:getInventoryIconTexture()
end

return WEIsoAnimal