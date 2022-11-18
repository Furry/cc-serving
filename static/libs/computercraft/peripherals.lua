require "libs.tables"

Peripheral = {
    get = function (direction)
        local peripheral = peripheral.wrap(direction)
        if peripheral == nil then
            error("No peripheral found at " .. direction)
        end
        return peripheral
    end
}