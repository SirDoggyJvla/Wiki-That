---@class WikiElement : ISBaseObject
---@field object Wikable
---@field type string
---@field class string
---@field _hideIfNoPage boolean
---@field page string|nil
---@field name string|nil
---@field icon Texture|nil
---@field cachePageFetch table<Wikable, string>
---@field cacheNameFetch table<Wikable, string>
---@field wikiPages table<string, table<string, string>>
local WikiElement = ISBaseObject:derive("WikiElement")
WikiElement.cachePageFetch = {}
WikiElement.cacheNameFetch = {}

---CACHE
local WT_utility = require "WT_utility"
-- data
local itemDictionary = require "data/WT_items"
local fluidDictionary = require "data/WT_fluids"
local vehicleDictionary = require "data/WT_vehicles"
local moveableDictionary = require "data/WT_moveables"
local tileDictionary = require "data/WT_tiles"
local mediaDictionary = require "data/WT_media"
local traitDictionary = require "data/WT_traits"
local professionDictionary = require "data/WT_professions"
local forageDictionary = require "data/WT_forage"
local animalDictionary = require "data/WT_animals"
local cropDictionary = require "data/WT_crops"

---Class mapping to their dictionary.
WikiElement.wikiPages = {
    ["InventoryItem"] = itemDictionary,
    ["Item"] = itemDictionary,
    ["Media"] = mediaDictionary,
    ["Fluid"] = fluidDictionary,
    ["BaseVehicle"] = vehicleDictionary,
    ["Moveable"] = moveableDictionary,
    ["Tile"] = tileDictionary,
    ["Trait"] = traitDictionary,
    ["Profession"] = professionDictionary,
    ["ForageCategory"] = forageDictionary,
    ["IsoAnimal"] = animalDictionary,
    ["Crop"] = cropDictionary,
}


---Get the wiki page for the element.
---@return string|nil
function WikiElement:getWikiPage()
    if self.class == "__EMPTY__" then return nil end -- empty WikiElement
    if self.page then return self.page end

    local page = nil
    local category = WikiElement.wikiPages[self.class]
    if category then
        page = category[self.type]
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
    if self.class == "__EMPTY__" then return nil end -- empty WikiElement
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
    elseif class == "BaseVehicle" then
        ---@cast object BaseVehicle
        local script = object:getScript()
        local carName = script:getCarModelName() or script:getName()
        name = getText("IGUI_VehicleName" .. carName)
    elseif class == "ForageCategory" then
        ---@cast object ForageCategory
        name = getText("IGUI_ScavengeUI_Title") .. ": " .. getText("IGUI_SearchMode_Categories_" .. self.type)
    elseif class == "IsoAnimal" then
        ---@cast object IsoAnimal
        name = object:getFullName()
    elseif class == "Crop" or class == "Moveable" or class == "Tile" then
        ---@cast object IsoObject
        local category = WikiElement.wikiPages[class]
        if category then
            name = category[self.type]
        end
    else
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
    if self.class == "__EMPTY__" then return nil end -- empty WikiElement
    if self.icon then return self.icon end

    local class = self.class
    local object = self.object
    local icon = nil
    if class == "InventoryItem" or class == "Media" or class == "Moveable" then
        ---@cast object InventoryItem
        icon = object:getTexture()
    elseif class == "Item" then
        ---@cast object Item
        icon = object:getNormalTexture()
    elseif class == "BaseVehicle" then
        local type = WT_utility.split(self.type, ".")[2] or nil
        icon = type and getTexture("media/ui/vehicle_icons/" .. type .. "_Model.png") or nil
    elseif class == "Fluid" then
        icon = getTexture("Item_Waterdrop_Grey.png")
    elseif class == "Trait" or class == "Profession" then
        ---@cast object Trait|Profession
        icon = object:getTexture()
    elseif class == "ForageCategory" then
        icon = getTexture("media/textures/Foraging/pinIcon"..self.type..".png")
            or getTexture("media/textures/Foraging/pinIconUnknown.png")
    elseif class == "IsoAnimal" then
        ---@cast object IsoAnimal
        icon = object:getInventoryIconTexture()
    elseif class == "Crop" then
        ---@cast object IsoObject
        local cropProperties = farming_vegetableconf.props[self.type]
        local iconID = cropProperties.icon -- this gives "Item_{scriptIcon}"
        icon = getTexture("media/textures/"..iconID)
    elseif class == "Tile" then
        ---@cast object IsoObject
        local sprite = object:getSprite()
        icon = sprite:getTextureForCurrentFrame(object:getDir())
    end

    -- early return
    if not icon then return nil end

    -- cache
    self.icon = icon
    return icon
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
end

---Create a WikiElement instance.
---@param object Wikable
---@param type string
---@param class string
---@param _hideIfNoPage boolean|nil -- if true, don't create the element if no wiki page is found
---@return WikiElement|nil instance
function WikiElement:new(object, type, class, _hideIfNoPage)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.object = object
    o.type = type
    o.class = class
    o._hideIfNoPage = _hideIfNoPage or false

    -- if _hideIfNoPage then
    --     o:getWikiPage() -- force fetch of the wiki page for the checks
    -- end

    -- retrieve informations already previously cached about this object
    o:fetchCache()

    return o
end

return WikiElement