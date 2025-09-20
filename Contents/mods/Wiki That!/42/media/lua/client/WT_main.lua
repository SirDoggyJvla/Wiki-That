---@alias URL string
---@alias PageName string
---@alias Wikable InventoryItem|Fluid|BaseVehicle|Moveable

---CACHE
local WT = require "WT_module"
local WT_utility = require "WT_utility"
local WT_pages = require "WT_pages"
-- data
WT.itemDictionary = require "data/WT_items"
WT.fluidDictionary = require "data/WT_fluids"
WT.vehicleDictionary = require "data/WT_vehicles"
WT.moveableDictionary = require "data/WT_moveables"
WT.mediaDictionary = require "data/WT_media"
-- reset pool
WT.tooltipPool = {}
WT.tooltipsUsed = {}

---@DEBUG
local function printTable(tbl, maxLvl, _lvl)
    if type(tbl) ~= "table" then print("not a table") return end
    _lvl = _lvl or 0
    maxLvl = maxLvl or 2
    for k, v in pairs(tbl) do
        DebugLog.log(string.rep(" ", _lvl * 4) .. tostring(k) .. " " .. tostring(v))
        -- DebugLog.log(tostring(k))
        if type(v) == "table" and _lvl < maxLvl then
            printTable(v, maxLvl, _lvl + 1)
        end
    end
end

WT.OnInitGlobalModData = function(newGame)
    -- init cache
    WT.cachePageFetch = {}
    WT.cacheNameFetch = {}
end

---Add a single context menu option "Wiki That!" to the inventory context menu.
---@param playerIndex integer
---@param context ISContextMenu
---@param items table
WT.OnFillInventoryObjectContextMenu = function(playerIndex, context, items)
    -- wipe tooltip pool
    for _,tooltip in ipairs(WT.tooltipsUsed) do
        table.insert(WT.tooltipPool, tooltip)
    end
    table.wipe(WT.tooltipsUsed)

    local uniqueItems = {}

	for i = 1,#items do
		-- retrieve the item
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end

        local fullType = item:getFullType()
        uniqueItems[fullType] = item

        -- DebugLog.log(fullType .. "   " .. tostring(item))
        -- local media = item:getMediaData()
        -- print(media)
    end

    local uniqueEntries = WT.fetchFluidEntries(uniqueItems)
    WT.populateDictionary(context, uniqueEntries)
end




---Fetch fluid entries from the given dictionary of unique entries and add them to the same dictionary.
---@param uniqueEntries table<string, Wikable>
---@return table
WT.fetchFluidEntries = function(uniqueEntries)
    for _, entry in pairs(uniqueEntries) do repeat
        if not instanceof(entry,"InventoryItem") then break end
        ---@cast entry InventoryItem

        local fluidContainer = entry:getFluidContainerFromSelfOrWorldItem()
        if not fluidContainer then break end

        local fluidLog = WT_utility.getFluidsInFluidContainer(fluidContainer)
        for fluidType, fluid in pairs(fluidLog) do
            fluidType = "Base." .. fluidType
            uniqueEntries[fluidType] = fluid
        end
    until true end
    return uniqueEntries
end

---Populate the context menu with Wiki That for entries from the dictionaries.
---@param context ISContextMenu
---@param uniqueEntries table<string, Wikable>
WT.populateDictionary = function(context, uniqueEntries)
    local entryCount = WT_utility.lenDict(uniqueEntries)
    if entryCount <= 0 then return end -- skip since nothing to add

    -- handle single entry case
    if entryCount == 1 then
        -- access unique option informations
        local fullType, entry
        for k,v in pairs(uniqueEntries) do
            fullType, entry = k,v
        end
        WT.createOptionEntry(context, fullType, entry, true)

        return
    end

    -- main option
    local optionMain = context:addOption(getText("IGUI_WikiThat"))
    optionMain.iconTexture = getTexture("favicon-128.png")
    local subMenu = context:getNew(context)
    context:addSubMenu(optionMain, subMenu)

    for fullType, entry in pairs(uniqueEntries) do
        WT.createOptionEntry(subMenu, fullType, entry)
    end
end

WT.fetchPageName = function(fullType, entry)
    -- check cache first
    local cache = WT.cachePageFetch[entry]
    if cache then return cache end

    local pageName = WT.tryFetchPageName(fullType, entry)

    -- store in cache
    WT.cachePageFetch[entry] = pageName
    return pageName
end

---Retrieve the wiki page name for a given entry type and full type.
---@param fullType string
---@param entry Wikable
---@return string|nil
WT.tryFetchPageName = function(fullType, entry)
    local cache = WT.tryFetchFromCache(entry)
    if cache then return cache end

    -- data
    if instanceof(entry,"Moveable") then
        ---@cast entry Moveable
        local moveableDictionary = WT.moveableDictionary
        return moveableDictionary[fullType]
    elseif instanceof(entry,"InventoryItem") then
        ---@cast entry InventoryItem
        -- handle media unique pages
        local media = entry:getMediaData()
        if media then
            local rm_guid = media:getId()
            local mediaDictionary = WT.mediaDictionary
            local page = mediaDictionary[rm_guid]
            if page then return page end
        end

        local itemDictionary = WT.itemDictionary
        return itemDictionary[fullType]
    elseif instanceof(entry,"Fluid") then
        ---@cast entry Fluid
        local fluidDictionary = WT.fluidDictionary
        return fluidDictionary[fullType]
    elseif instanceof(entry,"BaseVehicle") then
        ---@cast entry BaseVehicle
        local vehicleDictionary = WT.vehicleDictionary
        return vehicleDictionary[fullType]
    end
    return nil
end

WT.tryFetchFromCache = function(entry)
    return WT.cachePageFetch[entry]
end

---Create a context menu option entry
---@param context ISContextMenu
---@param fullType string
---@param entry Wikable
---@param _isMain boolean|nil -- if true, this is the parent option "Wiki That!"
---@return table
WT.createOptionEntry = function(context, fullType, entry, _isMain)
    local pageName = WT.fetchPageName(fullType, entry)

    local displayName = WT_utility.getName(entry)
    local tooltipObject = WT.getToolTip(entry, fullType)

    -- retrieve icon based on conditions
    local icon = nil
    if _isMain then
        icon = getTexture("favicon-128.png")
    elseif instanceof(entry,"InventoryItem") then
        ---@cast entry InventoryItem
        icon = entry:getTexture()
    elseif instanceof(entry,"BaseVehicle") then
        ---@cast entry BaseVehicle
        icon = WT.tryGetVehicleIcon(fullType)
    end

    -- create option
    local optionName = _isMain and getText("IGUI_WikiThat") or displayName or fullType
    local option = context:addOption(optionName, pageName, WT_utility.openWikiPage) --[[@as table]]

    -- special case for fluids to show a fluid icon with the fluid color
    if instanceof(entry,"Fluid") or not _isMain then
        ---@cast entry Fluid

        -- set texture and option color field for the icon color
        option.iconTexture = getTexture("Item_Waterdrop_Grey.png")
        local c = entry:getColor()
        option.color = {
            r = c:getRedFloat(),
            g = c:getGreenFloat(),
            b = c:getBlueFloat(),
        }
    end

    -- handle no wiki page case
    if not pageName then
        local text
        if displayName then
            text = string.format(getText("IGUI_WikiThat_NoPage"), displayName)
        else -- case where entry can't have a name (burnt vehicles without names for example)
            text = getText("IGUI_WikiThat_NoPage_noName")
        end
        tooltipObject.description = text
        option.notAvailable = true -- can't click it
    end

    -- assign icon and tooltip
    if icon then option.iconTexture = icon end
    if tooltipObject then option.toolTip = tooltipObject end
    return option
end

---Retrieve the tooltip for this type of entry
---@param entry Wikable
---@return ISToolTip|nil
WT.getToolTip = function(entry, fullType)
    local tooltipObject = ISWorldObjectContextMenu.addToolTip()
    local valid = false

    -- inventory item / moveable
    if instanceof(entry,"InventoryItem") then
        ---@cast entry InventoryItem
        valid = true
        -- get item texture
        local texture = entry:getTexture()
        local width = texture:getWidth()
        local height = texture:getHeight()
        local texturePath = string.gsub(texture:getName(), "^.*media", "media")

        -- find proper texture size for the tooltip
        local ratio = width/height
        height = 40 -- fixed height
        width = height*ratio -- adjust width

        -- draw tooltip
        ---@FIXME sometimes the texture is just empty for moveables in certain directions (Red Oak Chair)
        local s = "<IMAGECENTRE:"..texturePath..","..width..","..height..">\n<CENTRE>" .. entry:getDisplayName()
        tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)

    -- fluid
    elseif instanceof(entry,"Fluid") then
        ---@cast entry Fluid
        valid = true
        -- fluid color tooltip
        local color = entry:getColor()
        local r,g,b = color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat()
        local w,h = 50,50

        local s = "<FLUIDBOXCENTRE:"..w..","..h..","..r..","..g..","..b..">\n<CENTRE>" .. entry:getDisplayName()
        tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)

    -- vehicle
    elseif instanceof(entry,"BaseVehicle") then
        ---@cast entry BaseVehicle
        WT.tryGetVehicleIcon(fullType)

        -- get item texture
        local texture = WT.tryGetVehicleIcon(fullType)
        local imgString
        if texture then
            local width = texture:getWidth()
            local height = texture:getHeight()
            local texturePath = string.gsub(texture:getName(), "^.*media", "media")

            -- find proper texture size for the tooltip
            local ratio = width/height
            height = 40 -- fixed height
            width = height*ratio -- adjust width

            imgString = "<IMAGECENTRE:"..texturePath..","..width..","..height..">\n"
        end

        valid = true
        local script = entry:getScript()
        local carName = script:getCarModelName() or script:getName()
        local name = getText("IGUI_VehicleName" .. carName)
        -- draw tooltip
        local s = "<CENTRE>" .. name
        s = imgString and imgString .. s or s

        tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)
    end

    return valid and tooltipObject or nil
end


