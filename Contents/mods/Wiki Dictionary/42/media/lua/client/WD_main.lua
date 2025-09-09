local WD = require "WD_module"
WD.itemDictionary = require "data/WD_items"
WD.fluidDictionary = require "data/WD_fluids"
WD.vehicleDictionary = require "data/WD_vehicles"

local function printTable(tbl, lvl)
    lvl = lvl or 0
    for k, v in pairs(tbl) do
        print(string.rep(" ", lvl * 4) .. k, v)
        if type(v) == "table" and lvl < 1 then
            printTable(v, lvl + 1)
        end
    end
end

WD.OnFillInventoryObjectContextMenu = function(playerIndex, context, items)
    print("\n\n\nOnFillInventoryObjectContextMenu")

    -- printTable(items)

	for i = 1,#items do repeat
		-- retrieve the item
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end

        local fullType = item:getFullType()
        print(fullType)
        print(WD.itemDictionary[fullType])

        local pageName = WD.itemDictionary[fullType]
        if not pageName then break end

        local option = context:addOption("Open wiki", pageName, WD.openWikiPage)
        option.iconTexture = getTexture("favicon-128.png")

        local tooltipObject = ISWorldObjectContextMenu.addToolTip()
        tooltipObject.description = "Open the wiki page for " .. pageName
        option.toolTip = tooltipObject
    until true end
end


WD.openWikiPage = function(pageName)
    if type(pageName) ~= "string" then return end
    local url = "https://steamcommunity.com/linkfilter/?u=https://pzwiki.net/wiki/"
    url = url .. pageName
    print(url)

    if isSteamOverlayEnabled() then
        activateSteamOverlayToWebPage(url)
    else
        openUrl(url)
    end
end
