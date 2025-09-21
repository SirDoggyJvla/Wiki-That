---@alias URL string
---@alias PageName string
---@alias ForageCategory table
---@alias Wikable InventoryItem|Item|Fluid|BaseVehicle|Moveable|Trait|Profession|ForageCategory

local WT = {
    backgroundColor_highlight = {r=0.48, g=0.07, b=0.09, a=1},
    backgroundColor_normal = {r=0.29, g=0.05, b=0.05, a=1},
    backgroundColor_darker = {r=0.24, g=0.04, b=0.05, a=1},
    backgroundColor_darkest = {r=0.20, g=0.05, b=0.05, a=0.5},

    cachePageFetch = {},
    cacheNameFetch = {},
}

return WT