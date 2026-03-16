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

---Default the object name to its wiki page if no other method is implemented.
---@return string|nil
function WETile:_getName()
    local moveProps = ISMoveableSpriteProps.fromObject(self.object)
    local name = Translator.getMoveableDisplayName(moveProps.name)
    -- handle the case of no name, or default "Moveable Object" name, to instead use the wiki page name
    if not name or name == Translator.getMoveableDisplayName("Moveable_object") then return self:getWikiPage() end
    return name
end

return WETile