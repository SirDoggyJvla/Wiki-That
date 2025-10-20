--[[

WikiElement for Traits

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"

---@class WETrait : WikiElement
---@field object Trait|Profession
local WETrait = WikiElement:derive("WETrait")

function WETrait:_getName()
    return self.object:getLabel()
end

function WETrait:_getIcon()
    return self.object:getTexture()
end

return WETrait