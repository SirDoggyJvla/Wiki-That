local WT = require "WikiThat!/module"
require "WikiThat!/main"
require "WikiThat!/XpSystem/ISUI/ISCharacterScreen_patch"

Events.OnGameStart.Add(WT.OnInitGlobalModData)
Events.OnFillInventoryObjectContextMenu.Add(WT.OnFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(WT.OnFillWorldObjectContextMenu)
Events.OnClickedAnimalForContext.Add(WT.OnClickedAnimalForContext)
Events.onFillSearchIconContextMenu.Add(WT.onFillSearchIconContextMenu)