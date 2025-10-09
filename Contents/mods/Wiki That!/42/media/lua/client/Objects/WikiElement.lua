---Default class for a wikable element. This is used to store the object, its type, class and retrieve its wiki page, name and icon. It also retrieves the tooltip of the object and opens the wiki page if needed.
---@TODO: ability for modders to easily create their own WikiElement class for custom objects.
---
---@class WikiElement : ISBaseObject
---@field object Wikable
---@field type string
---@field class string
---@field _hideIfNoPage boolean
---@field _url URL
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
local WT_options = require "WT_modOptions"
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



---[[ OBJECT NAME ]]

---Get the object name.
---@return string|nil
function WikiElement:getName()
    if self.class == "__EMPTY__" then return nil end -- empty WikiElement
    if self.name then return self.name end

    local name = self:_getName()
    if not name then return nil end

    -- early return
    if not name then return nil end

    -- cache
    self.name = name
    -- WikiElement.cacheNameFetch[self.object] = name -- deactivated because some objects are recycled and thus this might break their page access
    return name
end

---Default the object name to its wiki page if no other method is implemented.
---@return string|nil
function WikiElement:_getName()
    return WikiElement:getWikiPage()
end



---[[ ICON ]]

---Get the icon texture of the element.
---@return Texture|nil
function WikiElement:getIcon()
    if self.class == "__EMPTY__" then return nil end -- empty WikiElement
    if self.icon then return self.icon end

    local icon = self:_getIcon()
    if not icon then return nil end

    -- cache
    self.icon = icon
    return icon
end

---No icon by default.
---@return Texture|nil
function WikiElement:_getIcon()
    return nil
end



---[[ TOOLTIP ]]

---Used to get the tooltip for the element.
---@return ISToolTip
function WikiElement:getTooltip()
    local tooltipObject = ISWorldObjectContextMenu.addToolTip()

    -- retrieve tooltip text
    local s = self:getTooltipContent()

    tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)

    return tooltipObject
end

---Generic tooltip content, the element icon and name.
---@return string
function WikiElement:getTooltipContent()
    local texture = self:getIcon()
    return self:getTooltipImage(texture) .. "<CENTRE>" .. (self:getName() or "")
end

---Get the tooltip image string with the element name.
---@param texture Texture|nil
---@return string
function WikiElement:getTooltipImage(texture)
    if not texture then return "" end

    -- adjust icon size
    local _setHeight = 40
    local width = texture:getWidth()
    local height = texture:getHeight()

    -- fix path of the image
    local texturePath = string.gsub(texture:getName(), "^.*media", "media")

    -- find proper texture size for the tooltip
    local ratio = width/height
    height = _setHeight -- fixed height
    width = height*ratio -- adjust width

    return "<IMAGECENTRE:"..texturePath..","..width..","..height..">\n"
end




---[[ INTERACTIONS ]]

---Pause the game if the player activated it in the mod options.
function WikiElement:pauseGame()
    -- check mod option
    if WT_options.Pause:getValue() then
        -- pause game if not already paused
        local SC = UIManager.getSpeedControls()
        if SC and not SC:isPaused() then
            SC:Pause()
        end
    end
end

---Open the wiki page of this element if it has a page. This will try to pause the game and open the page in the Steam overlay or the browser depending on the mod options.
function WikiElement:openWikiPage()
    -- nothing to open, another check already disables the option so this is a simple safeguard
    local page = self:getWikiPage()
    if not page then return end

    self:pauseGame() -- pause the game

    -- open the wiki page
    local url = string.format(self._url, page)
    if isSteamOverlayEnabled() and not WT_options.Browser:getValue() then
        activateSteamOverlayToWebPage(url) -- steam overlay
    else
        openUrl(url) -- browser
    end
end



---[[ CONSTRUCTOR ]]

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
---@return WikiElement instance
function WikiElement:new(object, type, class, _hideIfNoPage)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.object = object
    o.type = type
    o.class = class
    o._hideIfNoPage = _hideIfNoPage or false

    o._url = "https://pzwiki.net/wiki/%s"

    -- retrieve informations already previously cached about this object
    o:fetchCache()

    return o
end

return WikiElement