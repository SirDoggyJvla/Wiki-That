local WT = require "WT_module"

require "ISUI/ISVehicleMenu"
local originalFillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    originalFillMenuOutsideVehicle(player, context, vehicle, test)

    local script = vehicle:getScript()

    local fullType = script:getFullType()
    local uniqueEntries = {[fullType] = vehicle,}
    WT.populateDictionary(context, uniqueEntries)
end