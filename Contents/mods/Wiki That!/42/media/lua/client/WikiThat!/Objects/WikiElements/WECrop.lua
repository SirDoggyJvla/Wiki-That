--[[

WikiElement for Crop
The object name for tiles is the wiki page name

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"

---@class WECrop : WikiElement
---@field object IsoObject
local WECrop = WikiElement:derive("WECrop")

function WECrop:_getIcon()
    local cropProperties = farming_vegetableconf.props[self.type]
    local iconID = cropProperties.icon -- this gives "Item_{scriptIcon}"
    return getTexture("media/textures/"..iconID)
end

---Default the object name to its wiki page if no other method is implemented.
---@return string|nil
function WECrop:_getName()
    local plant = CFarmingSystem.instance:getLuaObjectOnSquare(self.object:getSquare())
    if not plant then return self:getWikiPage() end

    local name = getText("Farming_" .. plant.typeOfSeed)

    return name
end

return WECrop