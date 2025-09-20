local WT_utility = {}

---CACHE
local WT = require "WT_module"

---Utility to count entries in a dictionary (key-table).
WT_utility.lenDict = function(dict)
    local i = 0
    for _,_ in pairs(dict) do
        i = i + 1
    end
    return i
end


---Helper split function from https://stackoverflow.com/a/7615129
---@param inputstr string
---@param sep string|nil
---@return table
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

---Try to retrieve a vehicle icon texture based on the vehicle full type.
---@param fullType string
---@return Texture|nil
WT_utility.tryGetVehicleIcon = function(fullType)
    local type = split(fullType, ".")[2] or nil
    local icon = type and getTexture("media/ui/vehicle_icons/" .. type .. "_Model.png")
    return icon
end


---Retrieve every unique fluids contained in the provided fluid container.
---@param fluidContainer FluidContainer
---@return table
WT_utility.getFluidsInFluidContainer = function(fluidContainer)
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




---Retrieve the name of an entry by first checking the cache.
---@param entry any
---@return string
WT_utility.getName = function(entry)
    -- check cache first
    local cache = WT.cacheNameFetch[entry]
    if cache then return cache end

    local name = WT_utility.tryGetName(entry)

    -- store in cache
    WT.cacheNameFetch[entry] = name
    return name
end

---Try to retrieve the display name of an entry.
---@param entry Wikable
---@return string|nil
WT_utility.tryGetName = function(entry)
    if instanceof(entry,"Fluid") then
        ---@cast entry Fluid
        return entry:getDisplayName()
    end
    ---@cast entry -Fluid

    -- need to check if has name or this can error out in
    -- cases of entries like vehicles that don't have a name
    if instanceof(entry,"Fluid") or entry:getName() then
        return entry:getDisplayName()
    end
    return nil
end






---Converts a page name to its wiki URL.
---@param pageName PageName
---@return URL
WT_utility.pageNameToUrl = function(pageName)
    return "https://steamcommunity.com/linkfilter/?u=https://pzwiki.net/wiki/" .. pageName
end

--- Opens the wiki page for a given page name. Checks if the Steam overlay is
--- activated and used that or use the default browser.
---@param pageName PageName|nil
WT_utility.openWikiPage = function(pageName)
    if not pageName then return end
    -- pause the game
    local SC = UIManager.getSpeedControls()
    if SC and not SC:isPaused() then
        SC:Pause()
    end
    local url = WT_utility.pageNameToUrl(pageName)
    if isSteamOverlayEnabled() then
        activateSteamOverlayToWebPage(url)
    else
        openUrl(url)
    end
end

return WT_utility