---CACHE
local WT = require "WT_module"
local WT_utility = require "WT_utility"
local cropDictionary = require "data/WT_crops"
-- wiki elements
local WikiElement = require "Objects/WikiElement"
local WEInventoryItem = require "Objects/WikiElements/WEInventoryItem"
local WEItem = require "Objects/WikiElements/WEItem"
local WEFluid = require "Objects/WikiElements/WEFluid"
local WEBaseVehicle = require "Objects/WikiElements/WEBaseVehicle"
local WEIsoAnimal = require "Objects/WikiElements/WEIsoAnimal"
local WEForageCategory = require "Objects/WikiElements/WEForageCategory"
local WETile = require "Objects/WikiElements/WETile"
local WECrop = require "Objects/WikiElements/WECrop"
local WEMoodle = require "Objects/WikiElements/WEMoodle"
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

	for i = 1,#items do repeat -- repeat to have break act as a continue
		-- retrieve a unique item, no need to check the ones of the same type
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end

        -- check if item has media data
        local media = item:getMediaData()
        if media then
            local rm_guid = media:getId()
            uniqueItems["Media."..rm_guid] = WEInventoryItem:new(item, rm_guid, "Media")
            break

        -- check if item is a moveable item aka tile in InventoryItem form
        elseif instanceof(item, "Moveable") then
            local spriteID = "Moveables."..item:getWorldSprite()
            local wikiElement = WEInventoryItem:new(item, spriteID, "Moveable")

            -- this check needs to be done for items that are Moveables but are considered as items such as radio items
            local wikiPage = wikiElement:getWikiPage()
            if wikiPage then
                uniqueItems[wikiElement:getWikiPage()] = wikiElement -- using the wiki page as key to avoid duplicate tiles
                break
            end
        end

        -- handle classic item case
        local fullType = item:getFullType()
        uniqueItems["InventoryItem."..fullType] = WEInventoryItem:new(item, fullType, "InventoryItem")
    until true end

    local uniqueEntries = WT.fetchFluidEntries(uniqueItems)
    WT.populateDictionary(context, uniqueEntries)
end

---Handle context menu for animals.
---@param playerIndex integer
---@param context ISContextMenu
---@param animals table<IsoAnimal>
WT.OnClickedAnimalForContext = function(playerIndex, context, animals, _)
    for i = 1,#animals do
        local animal = animals[i] --[[@as IsoAnimal]]
        table.insert(WT.selectedAnimals, animal) -- store for use in the world object context menu
    end
end

---Handle context menu for foraging search icons.
---@param context ISContextMenu
---@param icon ISBaseIcon
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
        ["ForageCategory."..catDef.name] = WEForageCategory:new(catDef,catDef.name,"ForageCategory"),
        ["Item."..itemType] = WEItem:new(item, itemType, "Item"),
    }
    WT.populateDictionary(context, uniqueEntries)
end

---Handle context menu for world objects. Detect if the object is a crop or a tile.
---
---Also uses the selected vehicles and animals from the previous context menu events to add them too.
---The events used are `OnClickedAnimalForContext` and a hook to `ISVehicleMenu.FillMenuOutsideVehicle` which trigger before, to store the relevant other objects.
---@param playerNum any
---@param context any
---@param worldObjects any
---@param test any
WT.OnFillWorldObjectContextMenu = function(playerNum, context, worldObjects, test)
    local objects = {}
    for i=1, #worldObjects do
        objects[worldObjects[i]] = true
    end

    -- find unique wiki elements from world objects and other elements
    local uniqueEntries = {}

    -- retrieve the right clicked moodle if one is hovered
    local moodlesUI = MoodlesUI.getInstance()
    if WT_utility.getJavaField(moodlesUI, "mouseOver") then
        local mouseOverSlot = WT_utility.getJavaField(moodlesUI, "mouseOverSlot") --[[@as number]]
        local moodleSlotsPos = WT_utility.getJavaField(moodlesUI, "moodleSlotsPos") --[[@as table]]
        local player = getSpecificPlayer(playerNum)
        local moodles = player:getMoodles()

        -- verify that a moodle is being hovered, meaning it was right clicked
        local uiPos = 0 -- int2 in decompile for MoodlesUI.render
        for int3 = 0, MoodleType.ToIndex(MoodleType.MAX) - 1 do
            -- check if the moodle is currently visibile
            if moodleSlotsPos[int3] and moodleSlotsPos[int3] ~= 10000 then
                -- check if this is the moodle being hovered
                if uiPos == mouseOverSlot then
                    local moodleIndex = int3 - 1
                    local moodleType = MoodleType.FromIndex(moodleIndex):toString()
                    local wikiElement = WEMoodle:new(moodles, moodleType, "Moodle")
                    uniqueEntries["Moodle."..moodleType] = wikiElement
                end
                uiPos = uiPos + 1
            end
        end
    end

    -- retrieve wiki elements from world objects
    for object, _ in pairs(objects) do repeat
        -- get object info
        local sprite = object:getSprite()
        if not sprite then break end
        local spriteID = sprite:getName()
        local cropID = cropDictionary.__sprites__[spriteID] -- check the sprite is for a crop

        -- crop or simple tile
        if cropID then
            uniqueEntries[cropID] = WECrop:new(object, cropID, "Crop")
            break

        -- check placed radios and TVs
        elseif instanceof(object, "IsoWaveSignal") then
            local fullType, item = WT_utility.getWorldItem(object)
            if not fullType then break end -- type nil = item nil
            ---@cast item Item
            uniqueEntries["Item."..fullType] = WEItem:new(item, fullType, "Item")
            break
        end

        -- normal tile
        local wikiElement = WETile:new(object, spriteID, "Tile", true)
        uniqueEntries[spriteID] = wikiElement
    until true end

    -- populate animal entries from the selected animals
    for i = 1, #WT.selectedAnimals do
        local animal = WT.selectedAnimals[i]
        local fullType, wikiElement = WT.createAnimalEntry(animal)
        uniqueEntries[fullType] = wikiElement
    end
    WT.selectedAnimals = {} -- reset table for next world right click

    -- populate vehicle entries from the selected vehicles
    for i = 1, #WT.selectedVehicles do
        local vehicle = WT.selectedVehicles[i]
        local fullType, wikiElement = WT.createVehicleEntry(vehicle)
        uniqueEntries[fullType] = wikiElement
    end
    WT.selectedVehicles = {} -- reset table for next world right click

    WT.populateDictionary(context, uniqueEntries)
end

WT.createAnimalEntry = function(animal)
    local fullType = animal:getAnimalType() .. animal:getBreed():getName()
    return fullType, WEIsoAnimal:new(animal, fullType, "IsoAnimal")
end

WT.createVehicleEntry = function(vehicle)
    local fullType = vehicle:getScript():getFullType()
    return "BaseVehicle."..fullType, WEBaseVehicle:new(vehicle, fullType, "BaseVehicle")
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
            uniqueEntries["Fluid."..fluidType] = WEFluid:new(fluid, fluidType, "Fluid")
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
    local option = context:addOption(optionName, wikiElement, wikiElement.openWikiPage) --[[@as table]]

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
