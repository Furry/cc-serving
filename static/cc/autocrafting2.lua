require "libs.computercraft.inventories"
require "libs.computercraft.turtle"
require "libs.computercraft.screen"
require "libs.computercraft.net"
require "libs.strings"
require "libs.tables"
require "libs.events"

local modem = peripheral.wrap("front")
modem.open(6969)

local recipes = Net.get("https://lua-served.ngrok.io/files/recipes.json").json();
local screen = Screen.new(Peripheral.get("top"))
screen:clear()

local right = Inventory.new(Peripheral.get("right"))

local function findInInventory(item, inventory)
    local damage = 0
    if string.find(item, "|") then
        local split = Strings.split(item, "|")
        item = split[1]

        damage = tonumber(split[2])
    end

    for k, v in pairs(inventory:list()) do
        if v.name == item and v.damage == damage then
            return {
                inventory = inventory,
                slot = k,
                direction = inventory.direction
            }
        end
    end
end

local function find(item, ...)
    local inventories = { ... }

    local damage = 0
    if string.find(item, "|") then
        local split = Strings.split(item, "|")
        item = split[1]
        damage = tonumber(split[2])
    end

    for i = 1, #inventories do
        local inv = inventories[i]
        for k, v in pairs(inv:list()) do
            if v.name == item and v.damage == damage then
                return {
                    inventory = inv,
                    slot = k,
                    drection = inv.direction
                }
            end
        end
    end
    return nil
end

local function getItems(...)
    local inventories = { ... }
    local items = {}

    for i = 1, #inventories do
        local inv = inventories[i]
        for k, v in pairs(inv:list()) do
            if items[v.name .. "|" .. v.damage] == nil then
                items[v.name .. "|" .. v.damage] = {
                    total = v.count,
                    entries = { v }
                }
            else
                items[v.name .. "|" .. v.damage].total = items[v.name .. "|" .. v.damage].total + v.count
                table.insert(items[v.name .. "|" .. v.damage].entries, v)
            end
        end
    end
    return items
end

local function countIngredients(recipe, count)
    local items = {}
    local crafts = 1
    for _, item in pairs(recipes[recipe].recipe) do
        if recipes[item] ~= nil then
            local counts, nestedCrafts = countIngredients(item)
            crafts = crafts + nestedCrafts
            for k2, v2 in pairs(counts) do
                if items[k2] == nil then
                    items[k2] = v2
                else
                    items[k2] = items[k2] + v2
                end
            end
        else
            if items[item] == nil then
                items[item] = 1
            else
                items[item] = items[item] + 1
            end
        end
    end
    return items, crafts
end

local function waitForCraft()
    modem.transmit(6969, 6969, "craft")
    Events.await(function ()
        return ({ os.pullEvent("modem_message") })[5] == "complete"
    end)
end

local function craft(item, count, output, ...)
    for i = 1, count do
        local entry = recipes[item];
        if entry == nil then
            Events.emit("craftingError", "noRecipe", item)
            return false;
        end

        local locations = {}
        local discoverStart = os.epoch("utc")

        for k, v in pairs(entry.recipe) do
            if v ~= nil then
                print("Finding " .. v)
                local location = find(v, ...);
                if location == nil then
                    if not craft(v, 1, output, ...) then
                        Events.emit("craftingError", "Nested Error", v)
                        return false;
                    end
                    print("Finding other location")
                    location = findInInventory(v, output);
                end
    
                if location == nil then
                    Events.emit("craftingError", "No Location", v)
                    return false;
                end

                Tables.push(locations, {
                    toSlot = tonumber(k),
                    location = location
                })
            end
        end

        print("Discover Time: " .. (os.epoch("utc") - discoverStart) .. "ms")
        local moveStart = os.epoch("utc")
        for _, v in ipairs(locations) do
            v.location.inventory:push("bottom", v.location.slot, 1, Turtle.inventoryOffset(v.toSlot))
        end
        print("Move Time: " .. (os.epoch("utc") - moveStart) .. "ms")

        Events.emit("craftingStart", item)
        waitForCraft()
        output:pull("bottom", 1, 64)
        Events.emit("craftingFinished", item)
        if i == count then
            return true;
        end
    end
end

local sum = 0
local function getRequired2(recipe, count, contents, cache)
    if cache == nil then
        cache = {
            toCraft = {},
            fromStorage = {},
            missing = {},
            craftingStack = {},
            remainder = {}
        }
    end

    for _, item in pairs(recipes[recipe].recipe) do
        -- This is the total amount of the item in the inventory
        local total = 0
        if contents[item] ~= nil then
            total = contents[item].total
        end
    
        if (cache.remainder[item] or 0) > 0 then
            -- Then there's a remainder from a previous craft. Use this instead!
            cache.remainder[item] = cache.remainder[item] - 1
        elseif (cache.fromStorage[item] or 0) >= total then
            -- We check to see if the item is craftable.
            if recipes[item] ~= nil then -- It is

                -- Calculate the ingredients for the recipe
                -- print("Crafting " .. item)
                getRequired2(item, 1, contents, cache)
                Tables.push(cache.craftingStack, item)

                -- Add it to the 'toCraft' list
                if cache.toCraft[item] == nil then
                    cache.toCraft[item] = 1
                else
                    cache.toCraft[item] = cache.toCraft[item] + 1
                end

                -- Add the remainder of the craft (if it exists :/)
                cache.remainder[item] = (cache.remainder[item] or 0) + recipes[item].quantity - 1;
            else -- The component is missing and there's no way to craft it.
                if cache.missing[item] == nil then
                    cache.missing[item] = 1
                else
                    sum = sum + 1
                    -- print("Incrementing " .. item .. " from " .. cache.missing[item] .. " -> " .. (cache.missing[item] + 1))
                    cache.missing[item] = cache.missing[item] + 1
                end
            end
        else
            -- It's being pulled from stoage!
            if cache.fromStorage[item] == nil then
                cache.fromStorage[item] = 1
            else
                cache.fromStorage[item] = cache.fromStorage[item] + 1
            end
        end
    end
    return cache
end

local function startCraftOperation(item)
    screen:center("Autocraft - AurorasPalace")
    screen:newline()
    screen:newline()
    screen:newline()
    local status = Cursor.new(screen.screen, 2)

    local contents = getItems(
        Inventory.new(Peripheral.get("back")),
        Inventory.new(Peripheral.get("left")),
        Inventory.new(Peripheral.get("right"))
    )

    local trueStart = os.epoch("utc")
    local status = Cursor.new(screen.screen, 2)

    local results = getRequired2(item, 1, contents);

    for k, v in pairs(results.fromStorage) do
        screen:log(k .. " " .. v)
    end

    for k, v in pairs(results.toCraft) do
        screen:warn(k .. " " .. v)
    end

    for k, v in pairs(results.missing) do
        screen:error(k .. " " .. v)
    end

    -- If there's anything in the missing list, then we can't craft it.
    if Tables.length(results.missing) > 0 then
        screen:error("Missing items! Aborting.")
        return false;
    end

    for k, v in ipairs(results.craftingStack) do
        status:writeCenter("Crafting " .. v)
        craft(v, 1, 
        Inventory.new(Peripheral.get("back")),
        Inventory.new(Peripheral.get("back")),
        Inventory.new(Peripheral.get("left")),
        Inventory.new(Peripheral.get("right")))
    end

    local start = nil;
    Events.on("craftingStart", function (item)
        status:writeCenter("Crafting " .. item);
        start = os.epoch("utc")
    end)

    Events.on("craftingFinished", function (item)
        status:writeCenter("Finished " .. item .. " in " .. (os.epoch("utc") - start) .. "ms");
    end)

    Events.on("craftingError", function (type, item)
        print("Error: " .. type .. " " .. item)
        status:writeCenter("Error " .. type .. " " .. item);
    end)

    status:writeCenter("Crafting " .. item)
    craft(item, 1,
        Inventory.new(Peripheral.get("back")),
        Inventory.new(Peripheral.get("left")),
        Inventory.new(Peripheral.get("back")),
        Inventory.new(Peripheral.get("right")))

    status:writeCenter("Finished " .. item .. " in " .. (os.epoch("utc") - trueStart) .. "ms");
end

startCraftOperation("ic2:blockcompactedgenerator|3");
