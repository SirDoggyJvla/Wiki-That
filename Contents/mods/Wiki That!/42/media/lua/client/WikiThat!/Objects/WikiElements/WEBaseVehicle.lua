--[[

WikiElement for BaseVehicle

]]

local WikiElement = require "WikiThat!/Objects/WikiElement"

---@class WEBaseVehicle : WikiElement
---@field object BaseVehicle
local WEBaseVehicle = WikiElement:derive("WEBaseVehicle")

---CACHE
local WT_utility = require "WikiThat!/WT_utility"

function WEBaseVehicle:_getName()
    local script = self.object:getScript()
    local carName = script:getCarModelName() or script:getName()
    return getText("IGUI_VehicleName" .. carName)
end

function WEBaseVehicle:_getIcon()
    local type = WT_utility.split(self.type, ".")[2] or nil
    return type and getTexture("media/ui/vehicle_icons/" .. type .. "_Model.png") or nil
end

return WEBaseVehicle
