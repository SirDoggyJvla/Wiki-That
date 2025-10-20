--[[

Utility functions

]]--
local WT_utility = {}

---CACHE
local WT_options = require "WikiThat!/modOptions"

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

---Utility to count valid WikiElements in the dictionary to show.
---@param dict table<string, WikiElement>
WT_utility.countValidElements = function(dict)
    local validElements = {}
    for id, wikiElement in pairs(dict) do
        if not wikiElement._hideIfNoPage or wikiElement:getWikiPage() then
            validElements[id] = wikiElement
        end
    end

    return WT_utility.lenDict(validElements), validElements
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


WT_utility.getJavaField = function(object, field)  -- (IsoZombie instance, "strength")
    local offset = string.len(field)
    for i = 0, getNumClassFields(object) - 1 do
        local m = getClassField(object, i)
        if string.sub(tostring(m), -offset) == field then
            return getClassFieldVal(object, m)
        end
    end
    return nil -- no field found
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

---Retrieve the world item from a given object.
---@param object IsoObject
---@return string|nil fullType
---@return Item|nil
WT_utility.getWorldItem = function(object)
    -- access item properties and get the item fullType
    local containerProperties = object:getProperties()
    if not containerProperties then return end
    local fullType = containerProperties:Val("CustomItem")
    if not fullType then return end

    -- get the item script
    local item = getItem(fullType)
    if not item then return end

    return fullType, item
end



local SLIDEY = 10
WT_utility.resetContextMenu = function(context,x,y)
    local player = 0
    context:hideAndChildren()
    context:setVisible(true)
    context:clear()
    context:setFontFromOption()
	context.forceVisible = true
    context.parent = nil
    context.requestX = x
    context.requestY = y
    context:setSlideGoalX(x + 20, x)
    context:setSlideGoalY(y - SLIDEY, y)
    context:bringToTop()
    context:setVisible(true)
    context.visibleCheck = true
    if context.instanceMap then
        for _,v in pairs(context.instanceMap) do
            v:setVisible(false)
            v:removeFromUIManager()
            table.insert(context.subMenuPool, v)
        end
        table.wipe(context.instanceMap)
    end
    context.instanceMap = context.instanceMap or {}
    context.subMenuPool = context.subMenuPool or {}
    context.subOptionNums = 0
    context.subInstance = nil
    context.subMenu = nil
	context.player = player
	context:setForceCursorVisible(false)
	return context
end


return WT_utility