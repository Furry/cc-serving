while true do    
    -- Refuel if fuel level is below 100
    if turtle.getFuelLevel() < 100 then
        -- Suck from the right chest
        turtle.turnRight()
        turtle.select(16)
        turtle.suck(1)
        turtle.turnLeft()
        turtle.refuel()
        turtle.select(1)
    end
    
    
    -- Take 1 of the first item from the inventory on its left and put it in its first slot
    turtle.turnLeft()
    turtle.suck(1)
    turtle.turnRight()
    
    -- Dig forward, move forward, dig forward
    turtle.dig()
    turtle.forward()
    turtle.dig()
    
    -- Place the item in its first slot, move back, place the item in its second slot
    turtle.place()
    turtle.back()
    turtle.select(2)
    turtle.place()
    
    --   Empty inventory
    for i = 1, 16 do
        turtle.select(i)
        turtle.dropDown()
    end
    
    -- Equip back to the first slot
    turtle.select(1)

    os.sleep(7)
end
