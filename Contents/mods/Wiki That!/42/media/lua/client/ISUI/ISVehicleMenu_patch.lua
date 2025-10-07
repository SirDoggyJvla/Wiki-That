local WT = require "WT_module"
local WikiElement = require "Objects/WikiElement"

require "ISUI/ISVehicleMenu"
local originalFillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    print("FillMenuOutsideVehicle")
    originalFillMenuOutsideVehicle(player, context, vehicle, test)

    table.insert(WT.currentVehicles, vehicle)

    -- local fullType = vehicle:getScript():getFullType()
    -- local uniqueEntries = {["BaseVehicle."..fullType] = WikiElement:new(vehicle, fullType, "BaseVehicle"),}
    -- WT.populateDictionary(context, uniqueEntries)
end