--[[

Utility functions

]]--
local WT_utility = {}

---CACHE
local WT = require "WT_module"
local WT_options = require "WT_modOptions"

---Utility to count entries in a dictionary (key-table).
---@param dict table
---@return integer
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
---@return table<integer, string>
WT_utility.split = function(inputstr, sep)
    sep = sep or "%s"
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end


---Retrieve the option icon for a given entry.
---@param wikiElement WikiElement|nil
---@param _isMain boolean|nil -- if true, this is the parent option "Wiki That!"
---@return Texture|nil
WT_utility.getOptionIcon = function(wikiElement, _isMain)
    if _isMain then
        return getTexture("favicon-128.png")
    end
    ---@cast wikiElement WikiElement
    return wikiElement:getIcon()
end

---Define a tooltip image rich text panel tag for a given texture.
---@FIXME sometimes the texture is just empty for moveables in certain directions (Red Oak Chair)
---@param texture Texture|nil
---@param _setHeight number|nil -- the height of the image (default: 40)
---@return string
WT_utility.getImageCentre = function(texture, _setHeight)
    if not texture then return "" end
    _setHeight = _setHeight or 40

    local width = texture:getWidth()
    local height = texture:getHeight()
    local texturePath = string.gsub(texture:getName(), "^.*media", "media")

    -- find proper texture size for the tooltip
    local ratio = width/height
    height = _setHeight -- fixed height
    width = height*ratio -- adjust width

    return "<IMAGECENTRE:"..texturePath..","..width..","..height..">\n"
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


WT_utility.instanceof = function(obj, className)
    return string.find(tostring(obj), className) ~= nil
end


---Retrieve the name of an entry by first checking the cache.
---@param entry any
---@return string|nil
WT_utility.getName = function(entry)
    -- check cache first
    local cache = WT.cacheNameFetch[entry]
    if cache then return cache end

    local name = WT_utility.tryGetName(entry)
    if not name then return nil end

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
    elseif WT_utility.instanceof(entry,"TraitFactory.Trait")
        or WT_utility.instanceof(entry,"ProfessionFactory.Profession") then
        ---@cast entry Trait
        return entry:getLabel()
    end
    ---@cast entry -Fluid
    ---@cast entry -Trait
    ---@cast entry -Profession

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
---@param context ISContextMenu
---@param wikiElement WikiElement
WT_utility.openWikiPage = function(context, wikiElement)
    local pageName = wikiElement:getWikiPage()
    if not pageName then return end
    -- pause the game
    if WT_options.Pause:getValue() then
        local SC = UIManager.getSpeedControls()
        if SC and not SC:isPaused() then
            SC:Pause()
        end
    end

    local url = WT_utility.pageNameToUrl(pageName)
    if isSteamOverlayEnabled() then
        activateSteamOverlayToWebPage(url)
    else
        openUrl(url)
    end
end

return WT_utility