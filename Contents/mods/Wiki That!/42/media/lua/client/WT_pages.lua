--[[

Handles anything related to getting pages informations.

]]--
local WT_pages = {}

---CACHE
local WT = require "WT_module"
local WT_utility = require "WT_utility"
-- data
local itemDictionary = require "data/WT_items"
local fluidDictionary = require "data/WT_fluids"
local vehicleDictionary = require "data/WT_vehicles"
local moveableDictionary = require "data/WT_moveables"
local mediaDictionary = require "data/WT_media"
local traitDictionary = require "data/WT_traits"
local professionDictionary = require "data/WT_professions"

---Retrieve the wiki page name for a given entry type and full type.
---@param fullType string
---@param entry Wikable
---@return PageName|nil
WT_pages.getPageName = function(fullType, entry)
    local cache = WT.cachePageFetch[entry]
    if cache then return cache end

    local pageName = WT_pages.tryGetPageName(fullType, entry)
    if not pageName then return nil end

    -- store in cache
    WT.cachePageFetch[entry] = pageName

    return pageName
end

---Try to retrieve the wiki page name of an entry.
---@param fullType string
---@param entry Wikable
---@return PageName|nil
WT_pages.tryGetPageName = function(fullType, entry)
    -- data
    if instanceof(entry,"Moveable") then
        ---@cast entry Moveable
        return moveableDictionary[fullType]
    elseif instanceof(entry,"InventoryItem") then
        ---@cast entry InventoryItem
        -- handle media unique pages
        local media = entry:getMediaData()
        if media then
            local rm_guid = media:getId()
            local page = mediaDictionary[rm_guid]
            if page then return page end
        end

        return itemDictionary[fullType]
    elseif instanceof(entry,"Item") then
        ---@cast entry Item
        return itemDictionary[fullType]
    elseif instanceof(entry,"Fluid") then
        ---@cast entry Fluid
        return fluidDictionary[fullType]
    elseif instanceof(entry,"BaseVehicle") then
        ---@cast entry BaseVehicle
        return vehicleDictionary[fullType]
    elseif WT_utility.instanceof(entry,"TraitFactory.Trait") then
        ---@cast entry Trait
        return traitDictionary[fullType]
    elseif WT_utility.instanceof(entry,"ProfessionFactory.Profession") then
        ---@cast entry Profession
        return professionDictionary[fullType]
    end
    return nil
end

return WT_pages