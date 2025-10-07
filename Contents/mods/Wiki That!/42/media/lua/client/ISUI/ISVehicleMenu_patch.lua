local WT = require "WT_module"
local WikiElement = require "Objects/WikiElement"

require "ISUI/ISVehicleMenu"
local originalFillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle
function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, test)
    originalFillMenuOutsideVehicle(player, context, vehicle, test)

    -- store for use in the world object context menu
    table.insert(WT.selectedVehicles, vehicle)
end