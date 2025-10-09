--[[

WikiElement for ForageCategory

]]

local WikiElement = require "Objects/WikiElement"

---@class WEForageCategory : WikiElement
---@field object ForageCategory
local WEForageCategory = WikiElement:derive("WEForageCategory")

function WEForageCategory:_getName()
    return getText("IGUI_ScavengeUI_Title") .. ": " .. getText("IGUI_SearchMode_Categories_" .. self.type)
end

function WEForageCategory:_getIcon()
    return getTexture("media/textures/Foraging/pinIcon"..self.type..".png")
        or getTexture("media/textures/Foraging/pinIconUnknown.png")
end

return WEForageCategory