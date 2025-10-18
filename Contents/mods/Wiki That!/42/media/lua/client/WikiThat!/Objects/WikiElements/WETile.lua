--[[

WikiElement for Tiles
The object name for tiles is the wiki page name

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"

---@class WETile : WikiElement
---@field object IsoObject
local WETile = WikiElement:derive("WETile")

function WETile:_getIcon()
    local sprite = self.object:getSprite()
    return sprite:getTextureForCurrentFrame(self.object:getDir())
end

return WETile