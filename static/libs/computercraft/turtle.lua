Turtle = {
    inventoryOffset = function (input)
        -- A minecraft crafting grid is 3x3, but the turtle's inventory is 4x4.
        -- This function converts the 4x4 numbers into 3x3.
        local c = input
        if input > 3 then
            input = input + 1
        end
        if input > 7 then
            input = input + 1
        end
        return input
    end
}