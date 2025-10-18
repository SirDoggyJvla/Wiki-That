local WT = require "WikiThat!/WT_module"
require "WikiThat!/WT_main"

Events.OnFillInventoryObjectContextMenu.Add(WT.OnFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(WT.OnFillWorldObjectContextMenu)
Events.OnClickedAnimalForContext.Add(WT.OnClickedAnimalForContext)
Events.onFillSearchIconContextMenu.Add(WT.onFillSearchIconContextMenu)