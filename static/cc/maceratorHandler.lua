require "libs.tables"
require "libs.computercraft.inventories"

local macerators = {
    "left",
    "right",
    "front",
    "back"
}

local function fillFront()
    -- Fill first slot to 64
    turtle.select(1);
    local count = turtle.getItemCount()

    turtle.suckDown(64)
    turtle.drop()
end

local function emptyFront()
    turtle.select(2)
    turtle.suck()
    turtle.dropDown()
    local count = turtle.getItemCount(2)
    if count > 0 then
        turtle.dropUp()
    end
end

-- while true do
--     -- Fill the macerator infront of the turtle
--     turtle.select(1)
-- end

local function fill()
    turtle.select(1)
    local count = turtle.getItemCount()
    turtle.suckDown(64 - count)
    turtle.drop()
end

local function empty()
    turtle.select(2)
    turtle.suck()
    turtle.dropUp()
end

while true do
    fill()
    empty()
    turtle.turnLeft()
end