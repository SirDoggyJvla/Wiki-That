---@alias url string

---CACHE
local WT = require "WT_module"
WT.itemDictionary = require "data/WT_items"
WT.fluidDictionary = require "data/WT_fluids"
WT.vehicleDictionary = require "data/WT_vehicles"

local function printTable(tbl, lvl)
    lvl = lvl or 0
    for k, v in pairs(tbl) do
        print(string.rep(" ", lvl * 4) .. k, v)
        if type(v) == "table" and lvl < 1 then
            printTable(v, lvl + 1)
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
            local option = context:addOption("Wiki That!", pageName, WT.openWikiPage)
            option.iconTexture = getTexture("favicon-128.png")

            local tooltipObject = ISWorldObjectContextMenu.addToolTip()
            tooltipObject.description = "Open the wiki page for " .. pageName
            option.toolTip = tooltipObject
        end
    end
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
