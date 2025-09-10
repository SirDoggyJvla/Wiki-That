---@alias URL string
---@alias PageName string

---CACHE
local WT = require "WT_module"
-- data
WT.itemDictionary = require "data/WT_items"
WT.fluidDictionary = require "data/WT_fluids"
WT.vehicleDictionary = require "data/WT_vehicles"
WT.moveableDictionary = require "data/WT_moveables"
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
    end

    local uniqueEntries = WT.fetchFluidEntries(uniqueItems)
    WT.populateDictionary(context, uniqueEntries)
end

---Utility to count entries in a dictionary (key-table).
local lenDict = function(dict)
    local i = 0
    for _,_ in pairs(dict) do
        i = i + 1
    end
    return i
end

WT.getFluidsInFluidContainer = function(fluidContainer)
    local fluidLog = {}
    local fluids = Fluid.getAllFluids();
    for i=0,fluids:size()-1 do
        local fluid = fluids:get(i);
        local amount = fluidContainer:getSpecificFluidAmount(fluid)
        if amount > 0 then
            fluidLog[fluid:getFluidTypeString()] = fluid
        end
    end
    return fluidLog
end

---comment
---@param uniqueEntries table
---@return table
WT.fetchFluidEntries = function(uniqueEntries)
    for _, item in pairs(uniqueEntries) do repeat
        local fluidContainer = item:getFluidContainerFromSelfOrWorldItem()
        if not fluidContainer then break end

        local fluidLog = WT.getFluidsInFluidContainer(fluidContainer)
        for fluidType, fluid in pairs(fluidLog) do
            fluidType = "Base." .. fluidType
            uniqueEntries[fluidType] = fluid
        end
    until true end
    return uniqueEntries
end

---Populate the context menu with Wiki That for entries from the dictionaries.
---@param context ISContextMenu
---@param uniqueEntries table
WT.populateDictionary = function(context, uniqueEntries)
    local entryCount = lenDict(uniqueEntries)
    if entryCount <= 0 then return end -- skip since nothing to add

    -- handle single entry case
    if entryCount == 1 then
        -- access unique option informations
        local fullType, entry
        for k,v in pairs(uniqueEntries) do
            fullType, entry = k,v
        end

        local pageName = WT.fetchPageName(fullType, entry)
        local option = context:addOption(getText("IGUI_WikiThat"), pageName, WT.openWikiPage)
        option.iconTexture = getTexture("favicon-128.png")
        if not pageName then
            option.notAvailable = true
        end

        local tooltipObject = WT.getToolTip(entry)
        if tooltipObject then
            if not pageName then
                tooltipObject.description = getText("IGUI_WikiThat_NoPage")
            end
            option.toolTip = tooltipObject
        end

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
    -- data
    if instanceof(entry,"Moveable") then
        local moveableDictionary = WT.moveableDictionary
        return moveableDictionary[fullType]
    elseif instanceof(entry,"InventoryItem") then
        local itemDictionary = WT.itemDictionary
        return itemDictionary[fullType]
    elseif instanceof(entry,"Fluid") then
        local fluidDictionary = WT.fluidDictionary
        return fluidDictionary[fullType]
    elseif instanceof(entry,"BaseVehicle") then
        local vehicleDictionary = WT.vehicleDictionary
        return vehicleDictionary[fullType]
    end
    return nil
end

WT.createOptionEntry = function(context, fullType, entry)
    local pageName = WT.fetchPageName(fullType, entry)

    local displayName = entry:getDisplayName()
    local tooltip = WT.getToolTip(entry)

    local icon = nil
    if instanceof(entry,"InventoryItem") then
        icon = entry:getTexture()
    -- elseif instanceof(entry,"Fluid") then
    end

    -- create option
    local option = context:addOption(displayName, pageName, WT.openWikiPage)
    if not pageName then
        tooltip.description = getText("IGUI_WikiThat_NoPage")
        option.notAvailable = true
    end

    if icon then option.iconTexture = icon end
    if tooltip then option.toolTip = tooltip end
    return option
end

---comment
---@param entry InventoryItem|Fluid|BaseVehicle
---@return ISToolTip|nil
WT.getToolTip = function(entry)
    local tooltipObject = ISWorldObjectContextMenu.addToolTip()
    local valid = false

    -- inventory item
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
        valid = true
        local script = entry:getScript()
        local carName = script:getCarModelName() or script:getName()
        local name = getText("IGUI_VehicleName" .. carName)
        -- draw tooltip
        local s = "<CENTRE>" .. name
        tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)
    end

    return valid and tooltipObject or nil
end

---Finds the start y coordinates used to render the context menu options borders and backgrounds
---@param context ISContextMenu
---@return integer
WT.getStartY = function(context)
    local y = context.padTopBottom
	local dy = 0
	if context:getScrollHeight() > context:getScrollAreaHeight() then
		dy = context.scrollIndicatorHgt
		y = y + dy
	end
    return y
end

---Find the context menu option with specified `name` and return its index position and the option table
---@param context ISContextMenu
---@param name string
---@return integer|nil
---@return table|nil
WT.getOptionIndexFromName = function(context, name)
    local options = context.options -- context menu options
    for i=1,#options do
        local option = options[i]
        if option.name == name then
            return i,option
        end
    end
    return nil, nil
end

--- Converts a page name to its URL
---@param pageName PageName
---@return URL
WT.pageNameToUrl = function(pageName)
    return "https://steamcommunity.com/linkfilter/?u=https://pzwiki.net/wiki/" .. pageName
end

--- Opens the wiki page for a given page name. Checks if the Steam overlay is
--- activated and used that or use the default browser.
---@param pageName PageName
WT.openWikiPage = function(pageName)
    if not pageName then return end
    local url = WT.pageNameToUrl(pageName)
    if isSteamOverlayEnabled() then
        activateSteamOverlayToWebPage(url)
    else
        openUrl(url)
    end
end
