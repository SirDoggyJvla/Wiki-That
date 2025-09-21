---@class WikiElement : ISBaseObject
---@field object Wikable
---@field type string
---@field class string
local WikiElement = ISBaseObject:derive("WikiElement")
WikiElement.cachePageFetch = {}
WikiElement.cacheNameFetch = {}
-- WikiElement.cacheIconFetch = {}

---CACHE
local WT_utility = require "WT_utility"
-- data
local itemDictionary = require "data/WT_items"
local fluidDictionary = require "data/WT_fluids"
local vehicleDictionary = require "data/WT_vehicles"
local moveableDictionary = require "data/WT_moveables"
local mediaDictionary = require "data/WT_media"
local traitDictionary = require "data/WT_traits"
local professionDictionary = require "data/WT_professions"
local forageDictionary = require "data/WT_forage"


---Get the wiki page for the element.
---@return string|nil
function WikiElement:getWikiPage()
    if self.page then return self.page end

    local type = self.type
    local class = self.class
    local page = nil
    local object = self.object
    if class == "Moveable" then
        page = moveableDictionary[type]
    elseif class == "InventoryItem" then
        ---@cast object InventoryItem
        local media = object:getMediaData()
        if media then
            local rm_guid = media:getId()
            page = mediaDictionary[rm_guid]
        else
            page = itemDictionary[type]
        end
    elseif class == "Item" then
        page = itemDictionary[type]
    elseif class == "Fluid" then
        page = fluidDictionary[type]
    elseif class == "BaseVehicle" then
        page = vehicleDictionary[type]
    elseif class == "Trait" then
        page = traitDictionary[type]
    elseif class == "Profession" then
        page = professionDictionary[type]
    elseif class == "ForageCategory" then
        page = forageDictionary[type]
    end

    -- early return
    if not page then return nil end

    -- cache
    self.page = page
    WikiElement.cachePageFetch[self.object] = page
    return page
end


---Get the object name.
---@return string|nil
function WikiElement:getName()
    if self.name then return self.name end

    local name = nil
    local object = self.object
    local class = self.class
    if class == "Fluid" then
        ---@cast object Fluid
        name = object:getDisplayName()
    elseif class == "Trait" or class == "Profession" then
        ---@cast object Trait|Profession
        name = object:getLabel()
    -- need to check if has name or this can error out in
    -- cases of entries like vehicles that don't have a name
    elseif class == "BaseVehicle" then
        ---@cast object BaseVehicle
        local script = object:getScript()
        local carName = script:getCarModelName() or script:getName()
        name = getText("IGUI_VehicleName" .. carName)
    elseif class == "ForageCategory" then
        ---@cast object ForageCategory
        name = getText("IGUI_ScavengeUI_Title") .. ": " .. getText("IGUI_SearchMode_Categories_" .. self.type)
    elseif object:getName() then
        ---@cast object InventoryItem|Item|Moveable
        name = object:getDisplayName()
    end

    -- early return
    if not name then return nil end

    -- cache
    self.name = name
    WikiElement.cacheNameFetch[object] = name
    return name
end


---Get the icon texture of the element.
---@return Texture|nil
function WikiElement:getIcon()
    if self.icon then return self.icon end

    local class = self.class
    local object = self.object
    local icon = nil
    if class == "InventoryItem" then
        ---@cast object InventoryItem
        icon = object:getTexture()
    elseif class == "Item" then
        ---@cast object Item
        icon = object:getNormalTexture()
    elseif class == "BaseVehicle" then
        icon = self:getVehicleIcon()
    elseif class == "Fluid" then
        icon = getTexture("Item_Waterdrop_Grey.png")
    elseif class == "Trait" or class == "Profession" then
        ---@cast object Trait|Profession
        icon = object:getTexture()
    elseif class == "ForageCategory" then
        icon = getTexture("media/textures/Foraging/pinIcon"..self.type..".png")
            or getTexture("media/textures/Foraging/pinIconUnknown.png")
    end

    -- early return
    if not icon then return nil end

    -- cache
    self.icon = icon
    -- WikiElement.cacheIconFetch[object] = icon
    return icon
end

---Method to retrieve the vehicle icon texture.
---@return Texture|nil
function WikiElement:getVehicleIcon()
    local type = WT_utility.split(self.type, ".")[2] or nil
    return type and getTexture("media/ui/vehicle_icons/" .. type .. "_Model.png") or nil
end


function WikiElement:getTooltip()
    local tooltipObject = ISWorldObjectContextMenu.addToolTip()

    local class = self.class
    local object = self.object
    local s = ""
    if class == "Fluid" then
        ---@cast object Fluid
        local color = object:getColor()
        local r,g,b = color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat()
        local w,h = 50,50

        s = "<FLUIDBOXCENTRE:"..w..","..h..","..r..","..g..","..b..">\n" .. (self:getName() or "")
    else
        ---@cast object InventoryItem|Item|BaseVehicle|Trait|Profession
        local texture = self:getIcon()
        s = self:getImageTooltip(texture)
    end

    tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)

    return tooltipObject
end

function WikiElement:getImageTooltip(texture)
    local imgString = ""
    if texture then
        local _setHeight = 40

        local width = texture:getWidth()
        local height = texture:getHeight()
        local texturePath = string.gsub(texture:getName(), "^.*media", "media")

        -- find proper texture size for the tooltip
        local ratio = width/height
        height = _setHeight -- fixed height
        width = height*ratio -- adjust width

        imgString = "<IMAGECENTRE:"..texturePath..","..width..","..height..">\n"
    end

    return imgString .. "<CENTRE>" .. (self:getName() or "")
end



---Fetched informations previously cached about this object.
function WikiElement:fetchCache()
    local object = self.object
    self.page = WikiElement.cachePageFetch[object]
    self.name = WikiElement.cacheNameFetch[object]
    -- self.icon = WikiElement.cacheIconFetch[object]
end

---Create a WikiElement instance.
---@param object Wikable
---@param type string
---@param class string
---@return WikiElement instance
function WikiElement:new(object, type, class)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.object = object
    o.type = type
    o.class = class

    -- retrieve informations already previously cached about this object
    o:fetchCache()

    return o
end

return WikiElement