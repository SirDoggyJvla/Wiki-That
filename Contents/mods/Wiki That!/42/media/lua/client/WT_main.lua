---CACHE
local WT = require "WT_module"
local WT_utility = require "WT_utility"
local WT_pages = require "WT_pages"
local WikiElement = require "Objects/WikiElement"
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
        uniqueItems[fullType] = WikiElement:new(item, fullType, "InventoryItem")
    end

    local uniqueEntries = WT.populateFluidEntries(uniqueItems)
    WT.populateDictionary(context, uniqueEntries)
end

WT.OnClickedAnimalForContext = function(playerIndex, context, animals, _)
    ---@TODO: waiting for the wiki pages proper creation to ID animals
    -- print(animals)
    -- for i = 1,#animals do
    --     local animal = animals[i]
    --     print(animal:getAnimalType())
    --     print(animal:getFullName())
    -- end
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
        [catDef.name] = WikiElement:new(catDef,catDef.name,"ForageCategory"),
        [itemType] = WikiElement:new(item, itemType, "Item"),
    }
    printTable(catDef)
    WT.populateDictionary(context, uniqueEntries)
end




---Fetch fluid entries from the given dictionary of unique entries and add them to the same dictionary.
---@param uniqueEntries table<string, WikiElement>
---@return table
WT.populateFluidEntries = function(uniqueEntries)
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
            uniqueEntries[fluidType] = WikiElement:new(fluid, fluidType, "Fluid")
        end
    until true end
    return uniqueEntries
end

---Populate the context menu with Wiki That for entries from the dictionaries.
---@param context ISContextMenu
---@param uniqueEntries table<string, WikiElement>
WT.populateDictionary = function(context, uniqueEntries)
    local entryCount = WT_utility.lenDict(uniqueEntries)
    if entryCount <= 0 then return end -- skip since nothing to add

    -- handle single entry case
    if entryCount == 1 then
        -- access unique option informations
        local fullType, wikiElement
        for k,v in pairs(uniqueEntries) do
            fullType, wikiElement = k,v
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

---Retrieve the tooltip for this type of entry
---@param entry Wikable
---@return ISToolTip|nil
WT.getToolTip = function(entry, fullType)
    local tooltipObject = ISWorldObjectContextMenu.addToolTip()

    -- inventory item / moveable
    local s = ""
    if instanceof(entry,"InventoryItem") then
        ---@cast entry InventoryItem
        -- get item texture
        local texture = entry:getTexture()

        -- draw tooltip
        local imgString = WT_utility.getImageTooltip(texture)
        s = imgString .. "<CENTRE>" .. entry:getDisplayName()

    elseif instanceof(entry,"Item") then
        ---@cast entry Item
        -- get item texture
        local texture = entry:getNormalTexture()

        -- draw tooltip
        local imgString = WT_utility.getImageTooltip(texture)
        s = imgString .. "<CENTRE>" .. entry:getDisplayName()

    -- fluid
    elseif instanceof(entry,"Fluid") then
        ---@cast entry Fluid
        -- fluid color tooltip
        local color = entry:getColor()
        local r,g,b = color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat()
        local w,h = 50,50

        s = "<FLUIDBOXCENTRE:"..w..","..h..","..r..","..g..","..b..">\n<CENTRE>" .. entry:getDisplayName()

    -- vehicle
    elseif instanceof(entry,"BaseVehicle") then
        ---@cast entry BaseVehicle

        -- get item texture
        local texture = WT_utility.tryGetVehicleIcon(fullType)

        local script = entry:getScript()
        local carName = script:getCarModelName() or script:getName()
        local name = getText("IGUI_VehicleName" .. carName)

        -- draw tooltip
        local imgString = WT_utility.getImageTooltip(texture)
        s = imgString .. "<CENTRE>" .. name

    elseif WT_utility.instanceof(entry,"TraitFactory.Trait") or WT_utility.instanceof(entry,"ProfessionFactory.Profession") then
        ---@cast entry Trait/Profession
        -- get trait icon
        local texture = entry:getTexture()

        -- draw tooltip
        local imgString = WT_utility.getImageTooltip(texture)
        s = imgString .. "<CENTRE>" .. entry:getLabel()
    end

    tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)

    return tooltipObject
end


