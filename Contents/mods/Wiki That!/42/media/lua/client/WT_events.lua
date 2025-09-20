local WT = require "WT_module"
require "WT_main"

Events.OnInitGlobalModData.Add(WT.OnInitGlobalModData)
Events.OnFillInventoryObjectContextMenu.Add(WT.OnFillInventoryObjectContextMenu)