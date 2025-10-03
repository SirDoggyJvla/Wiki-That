local WT = require "WT_module"
local WikiElement = require "Objects/WikiElement"

require "ISUI/ISVehicleMenu"
local originalFillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    originalFillMenuOutsideVehicle(player, context, vehicle, test)

    local script = vehicle:getScript()

    local fullType = script:getFullType()
    local uniqueEntries = {["BaseVehicle."..fullType] = WikiElement:new(vehicle, fullType, "BaseVehicle"),}
    WT.populateDictionary(context, uniqueEntries)
end