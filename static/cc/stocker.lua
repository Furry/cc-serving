require "libs.tables"
require "libs.ae2"
require "libs.logging"

local stock = AE2.new(peripheral.wrap("left"))
local main = AE2.new(peripheral.wrap("right"))

while true do
    local maincontents = main:stock()
    for k, v in pairs(stock:stock()) do
        if maincontents[k] == nil then
            print("Missing: " .. k .. " Uncraftable!")
        else
            if maincontents[k].count < v.count then
                if not main:isJob(k) then
                    print("Low: " .. k .. " " .. maincontents[k].count .. "/" .. v.count)
                    print("Crafting " .. k .. " " .. v.count - maincontents[k].count)
                    main:findAndCraft(k, v.count - maincontents[k].count)
                end
            end
        end
    end

    main:sweepJobs()
    sleep(1)
end

-- main:stock()
