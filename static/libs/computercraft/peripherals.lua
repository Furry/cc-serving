require "libs.tables"

Peripheral = {
    get = function (direction)
        local peripheral = peripheral.wrap(direction)
        if peripheral == nil then
            error("No peripheral found at " .. direction)
        end
        peripheral.direction = direction
        return peripheral
    end
}

Redstone = {
    oscillate = function (direction, count)
        for _ = 1, count do
            redstone.setOutput(direction, true)
            redstone.setOutput(direction, false)
        end
    end 
}