---@alias url string

---CACHE
local WT = require "WT_module"
WT.itemDictionary = require "data/WT_items"
WT.fluidDictionary = require "data/WT_fluids"
WT.vehicleDictionary = require "data/WT_vehicles"

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


WT.OnFillInventoryObjectContextMenu = function(playerIndex, context, items)
    print("\n\nOnFillInventoryObjectContextMenu")

	for i = 1,#items do
		-- retrieve the item
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end

        local fullType = item:getFullType()

        local pageName = WT.itemDictionary[fullType]
        if pageName then
            WT.createContextMenuOption(context, item, pageName)
            return
        end
    end
end

---
---@param context ISContextMenu
---@param item InventoryItem
---@param pageName any
WT.createContextMenuOption = function(context, item, pageName)
    local option = context:addOptionOnTop(getText("IGUI_WikiThat"), pageName, WT.openWikiPage)
    option.iconTexture = getTexture("favicon-128.png")
    -- option.iconTexture = item:getTexture()

    -- get item texture
    local texture = item:getTexture()
    local width = texture:getWidth()
    local height = texture:getHeight()
    local texturePath = string.gsub(texture:getName(), "^.*media", "media")

    -- find proper texture size for the tooltip
    local ratio = width/height
    height = 40 -- fixed height
    width = height*ratio -- adjust width

    -- draw tooltip
    local tooltipObject = ISWorldObjectContextMenu.addToolTip()
    local s = "<IMAGECENTRE:"..texturePath..","..width..","..height..">\n<CENTRE>" .. item:getDisplayName()
    tooltipObject.description = string.format(getText("IGUI_WikiThat_Tooltip"), s)
    option.toolTip = tooltipObject
end

-- hook to render
WT.originalRender = ISContextMenu.render

---Adjust the context menu option border and background color
---@param self table
WT.renderOptionHook = function(self)
    WT.originalRender(self)

    local i, option = WT.getOptionIndexFromName(self, getText("IGUI_WikiThat"))
    if option then
        local y = WT.getStartY(self)
        y = y + self.itemHgt*(i-1)

        self:drawRect(0, y, self.width, self.itemHgt, 0.1, 1, 0.6, 0)
        self:drawRectBorder(0, y, self.width, self.itemHgt, 0.2, 1, 0, 0)
    end
end
ISContextMenu.render = WT.renderOptionHook -- replace original with our hook

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
---@param pageName string
---@return url
WT.pageNameToUrl = function(pageName)
    return "https://steamcommunity.com/linkfilter/?u=https://pzwiki.net/wiki/" .. pageName
end

--- Opens the wiki page for a given page name. Checks if the Steam overlay is
--- activated and used that or use the default browser.
---@param pageName string
WT.openWikiPage = function(pageName)
    local url = WT.pageNameToUrl(pageName)
    if isSteamOverlayEnabled() then
        activateSteamOverlayToWebPage(url)
    else
        openUrl(url)
    end
end
