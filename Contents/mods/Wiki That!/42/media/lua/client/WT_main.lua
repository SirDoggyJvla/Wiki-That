---CACHE
local WT = require "WT_module"
local WT_utility = require "WT_utility"
local WT_pages = require "WT_pages"
local WikiElement = require "Objects/WikiElement"
local cropDictionary = require "data/WT_crops"
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

---Handle Wiki That for inventory items. Detect the type of item if media, moveable or classic item. Also check if the item entries have fluid containers, and if so add the fluids to the elements too.
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
		-- retrieve a unique item, no need to check the ones of the same type
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end

        -- check if item has media data
        local media = item:getMediaData()
        if media then
            local rm_guid = media:getId()
            uniqueItems["Media."..rm_guid] = WikiElement:new(item, rm_guid, "Media")

        -- check if item is a moveable item aka tile in InventoryItem form
        elseif instanceof(item, "Moveable") then
            local spriteID = "Moveables."..item:getWorldSprite()
            uniqueItems[spriteID] = WikiElement:new(item, spriteID, "Moveable")

        -- handle classic item case
        else
            local fullType = item:getFullType()
            uniqueItems["InventoryItem."..fullType] = WikiElement:new(item, fullType, "InventoryItem")
        end
    end

    local uniqueEntries = WT.fetchFluidEntries(uniqueItems)
    WT.populateDictionary(context, uniqueEntries)
end

---Handle context menu for animals.
---@param playerIndex integer
---@param context ISContextMenu
---@param animals table<IsoAnimal>
WT.OnClickedAnimalForContext = function(playerIndex, context, animals, _)
    local uniqueEntries = {}
    for i = 1,#animals do
        local animal = animals[i] --[[@as IsoAnimal]]
        local fullType, wikiElement = WT.createAnimalEntry(animal)
        uniqueEntries[fullType] = wikiElement
    end
    WT.populateDictionary(context, uniqueEntries)
end

WT.onFillSearchIconContextMenu = function(context, icon)
    ---@TODO: are these checks needed ? Was from my hunting mod
    -- verify it's valid
    if not icon or not context then return end

    -- verify it's a forage icon
    if icon.iconClass ~= "forageIcon" then return end

    -- item to forage
    local itemType = icon.itemType
    local item = getScriptManager():FindItem(itemType)

    -- category to forage
    local catDef = icon.catDef

    local uniqueEntries = {
        ["ForageCategory."..catDef.name] = WikiElement:new(catDef,catDef.name,"ForageCategory"),
        ["Item."..itemType] = WikiElement:new(item, itemType, "Item"),
    }
    WT.populateDictionary(context, uniqueEntries)
end

---Handle context menu for world objects. Detect if the object is a crop or a tile.
---@param playerNum any
---@param context any
---@param worldObjects any
---@param test any
WT.OnFillWorldObjectContextMenu = function(playerNum, context, worldObjects, test)
    print("OnFillWorldObjectContextMenu")
    local objects = {}
    for i=1, #worldObjects do
        objects[worldObjects[i]] = true
    end

    -- retrieve wiki elements from world objects
    local uniqueEntries = {}
    for object, _ in pairs(objects) do repeat
        -- get object info
        local spriteID = object:getSprite():getName()
        local cropID = cropDictionary.__sprites__[spriteID]

        -- crop or simple tile
        if cropID then
            uniqueEntries[cropID] = WikiElement:new(object, cropID, "Crop")
        else
            ---@TODO: switch _hideIfNoPage to true here
            uniqueEntries[spriteID] = WikiElement:new(object, spriteID, "Tile", true)
        end

        -- check the square for animals or vehicles
        local square = object:getSquare()
        if not square then break end

        -- handle animals
        local animals = square:getAnimals()
        for i = 0, animals:size()-1 do
            local animal = animals:get(i)
            local fullType, wikiElement = WT.createAnimalEntry(animal)
            uniqueEntries[fullType] = wikiElement
        end
    until true end

    -- populate vehicle entries from the current vehicles
    for i = 1, #WT.currentVehicles do
        local vehicle = WT.currentVehicles[i]
        local fullType, wikiElement = WT.createVehicleEntry(vehicle)
        uniqueEntries[fullType] = wikiElement
    end
    WT.currentVehicles = {} -- reset table for next world right click

    WT.populateDictionary(context, uniqueEntries)
end

WT.createAnimalEntry = function(animal)
    local fullType = animal:getAnimalType() .. animal:getBreed():getName()
    return fullType, WikiElement:new(animal, fullType, "IsoAnimal")
end

WT.createVehicleEntry = function(vehicle)
    local fullType = vehicle:getScript():getFullType()
    return "BaseVehicle."..fullType, WikiElement:new(vehicle, fullType, "BaseVehicle")
end

---Fetch fluid entries from the given dictionary of unique entries and add them to the same dictionary.
---@param uniqueEntries table<string, WikiElement>
---@return table
WT.fetchFluidEntries = function(uniqueEntries)
    for _, wikiElement in pairs(uniqueEntries) do repeat
        local entry = wikiElement.object
        if not instanceof(entry,"InventoryItem") then break end
        ---@cast entry InventoryItem

        local fluidContainer = entry:getFluidContainerFromSelfOrWorldItem()
        if not fluidContainer then break end

        -- get fluids in the fluid container and add them to the unique entries
        local fluidLog = WT_utility.getFluidsInFluidContainer(fluidContainer)
        for fluidType, fluid in pairs(fluidLog) do
            fluidType = "Base." .. fluidType
            uniqueEntries["Fluid."..fluidType] = WikiElement:new(fluid, fluidType, "Fluid")
        end
    until true end
    return uniqueEntries
end

---Populate the context menu with Wiki That for entries from the dictionaries.
---@param context ISContextMenu
---@param uniqueEntries table<string, WikiElement>
WT.populateDictionary = function(context, uniqueEntries)
    -- count valid entries and filter out invalid ones
    local entryCount, uniqueEntries = WT_utility.countValidElements(uniqueEntries)

    -- handle no entry case, we still want to show Wiki That in the menu
    if entryCount <= 0 then
        uniqueEntries["__EMPTY__"] = WikiElement:new(nil, nil, "__EMPTY__")
        entryCount = 1
    end

    -- handle single entry case
    if entryCount <= 1 then
        -- access unique option informations
        local wikiElement
        for _,v in pairs(uniqueEntries) do
            wikiElement = v
        end
        WT.createOptionEntry(context, wikiElement, true)

        return
    end

    -- main option
    local optionMain = context:addOption(getText("IGUI_WikiThat"))
    optionMain.iconTexture = WT_utility.getOptionIcon(nil, true)
    local subMenu = context:getNew(context)
    context:addSubMenu(optionMain, subMenu)

    for fullType, wikiElement in pairs(uniqueEntries) do
        WT.createOptionEntry(subMenu, wikiElement)
    end
end

---Create a context menu option entry
---@param context ISContextMenu
---@param wikiElement WikiElement
---@param _isMain boolean|nil -- if true, this is the parent option "Wiki That!"
---@return table
WT.createOptionEntry = function(context, wikiElement, _isMain)
    local pageName = wikiElement:getWikiPage()
    local displayName = wikiElement:getName()
    local tooltipObject = wikiElement:getTooltip()

    -- retrieve icon based on conditions
    local icon = WT_utility.getOptionIcon(wikiElement, _isMain)

    -- create option
    local optionName = _isMain and getText("IGUI_WikiThat") or displayName or wikiElement.type
    local option = context:addOption(optionName, context, WT_utility.openWikiPage, wikiElement) --[[@as table]]

    -- special case for fluids to show a fluid icon with the fluid color
    if wikiElement.class == "Fluid" then
        local object = wikiElement.object --[[@as Fluid]]
        -- set texture and option color field for the fluid color
        local c = object:getColor()
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
        -- update tooltip
        if tooltipObject then tooltipObject.description = text end
        option.notAvailable = true -- can't click it
    end

    -- assign icon and tooltip
    option.iconTexture = icon or nil
    option.toolTip = tooltipObject or nil

    return option
end
