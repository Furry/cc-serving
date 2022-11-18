require "libs.tables";
require "libs.events";
require "libs.computercraft.fs";
require "libs.computercraft.inventories";
require "libs.computercraft.net";
require "libs.computercraft.screen";
require "libs.computercraft.shortcuts";
require "libs.json";

local invLeft = Inventory.new(Peripheral.get("left"))
local screen = Screen.new(Peripheral.get("top"))

if not Cache.has("totalEmc") or not Cache.has("startTime") or not Cache.has("conversionTable") or not Cache.has("itemTally") then
    Cache.set("totalEmc", 0)
    Cache.set("startTime", os.epoch("utc"))
    Cache.set("conversionTable", Net.get("https://lua-served.ngrok.io/files/pregenerated_emc.json").raw())
    Cache.set("itemTally", JSON.encode({}))
end

local size = invLeft:size()
local count = tonumber(Cache.get("totalEmc"))
local startTime = tonumber(Cache.get("startTime"))
local data = JSON.decode(Cache.get("conversionTable"))
local tally = JSON.decode(Cache.get("itemTally"))

local function formatNumber(n)
    local suffixes = { "", "k", "m", "b", "t", "q", "Q", "s" }
    local suffixNum = 1
    while n >= 1000 do
        n = n / 1000
        suffixNum = suffixNum + 1
    end
    return string.format("%.2f%s", n, suffixes[suffixNum])
end

-- For printing
local currentItemCursor = Cursor.new(screen.screen, 3)

while true do
    for i = 1, size do
        local item = invLeft:get(i)
        if item ~= nil then
            if data[item.name .. "|" .. item.damage] ~= nil then
                count = count + (data[item.name .. "|" .. item.damage] * item.count)
                if tally[item.name .. "|" .. item.damage] == nil then
                    tally[item.name .. "|" .. item.damage] = item.count
                else
                    tally[item.name .. "|" .. item.damage] = tally[item.name .. "|" .. item.damage] + item.count
                end
            end
            currentItemCursor:clear()
            currentItemCursor:writeCenter(item.name .. " (" .. item.count .. "): " .. (data[item.name .. "|" .. item.damage] * item.count))
            invLeft:push("right", item.slot, item.count)
        end
        -- print(count)
    end
    
    -- Print how much count changes a second, minute, hour, day.
    local currentTime = os.epoch("utc")
    -- Count how many seconds have passed since the start of the program.
    local secondsPassed = (currentTime - startTime) / 1000
    local countPerSecond = count / secondsPassed
    local countPerMinute = countPerSecond * 60
    local countPerHour = countPerMinute * 60
    local countPerDay = countPerHour * 24

    Cache.set("totalEmc", count)

    screen:clear()
    screen:center("EMC Calculator - AurorasPalace")
    screen:newline()
    screen:newline()
    screen:writeLine("EMC/s: " .. formatNumber(countPerSecond))
    screen:writeLine("EMC/m: " .. formatNumber(countPerMinute))
    screen:writeLine("EMC/h: " .. formatNumber(countPerHour))
    screen:writeLine("EMC/d: " .. formatNumber(countPerDay))
    screen:newline()
    screen:center("Total EMC: " .. formatNumber(count))
    screen:newline()
    screen:center("Top 5 Items:")

    local sortedTally = Tables.sort(tally, function (a, b) return a > b end)
    local indx = 1
    for key, value in pairs(sortedTally) do
        if indx == 6 then
            break
        end
        -- Strip anything before : and after |
        local itemName = key:match(":(.+)|")
        screen:center(itemName .. ": " .. value)
    end
    Cache.set("itemTally", JSON.encode(tally))
end
