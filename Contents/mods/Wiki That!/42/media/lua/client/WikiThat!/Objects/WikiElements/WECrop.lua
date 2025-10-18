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

return WECrop