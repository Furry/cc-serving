require "libs.computercraft.inventories"
require "libs.computercraft.net"
require "libs.computercraft.turtle"
require "libs.strings"
require "libs.tables"
require "libs.events"
require "libs.computercraft.screen"

local recipes = Net.get("https://lua-served.ngrok.io/files/recipes.json").json();
-- Tables.print(turtle.getItemDetail(1))
local inv = Inventory.new(Peripheral.get("back"))
local turtle = Inventory.new(Peripheral.get("bottom"))
local screen = Screen.new(Peripheral.get("top"))
screen:clear()

local function find(item, ...)
    -- ... represents all inventories
    local inventories = {...}

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

local function countIngredients(recipe)
    local items = {}
    for _, item in pairs(recipes[recipe].recipe) do
        if recipes[item] ~= nil then
            for k2, v2 in pairs(countIngredients(item)) do
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
    return items
end

local function craft(item, count, output, ...)
    for i = 1, count do
        local entry = recipes[item];
        if entry == nil then
            screen:warn("No recipe for " .. item)
            return false;
        end
    
        screen:log("Crafting " .. item .. " (" .. i .. "/" .. count .. ")")
        local locations = {}
    
        for k, v in pairs(entry.recipe) do
            if v ~= nil then
                local location = find(v, ...);
                if location == nil then
                    screen:warn("Could not find " .. v)
                    if not craft(v, 1, output, ...) then
                        screen:error("Could not craft " .. v .. " aborting.")
                        return false;
                    end
                    location = find(v, ...);
                end
    
                Tables.push(locations, {
                    toSlot = tonumber(k),
                    location = location
                })
            end
        end
    
        for _, v in ipairs(locations) do
            v.location.inventory:push("bottom", v.location.slot, 1, Turtle.inventoryOffset(v.toSlot))
        end
    
        redstone.setOutput("bottom", true)
        os.sleep(0.5)
        redstone.setOutput("bottom", false)
        -- Redstone.oscillate("bottom", 5)
        output:pull("bottom", 1, 64)
        screen:log("Crafted " .. item)
        if i == count then
            return true;
        end
    end
end

-- local r = craft(
--     "ic2:itembatre|0",
--     Inventory.new(Peripheral.get("back")),

--     -- These are the input labels
--     Inventory.new(Peripheral.get("back")),
--     Inventory.new(Peripheral.get("left")),
--     Inventory.new(Peripheral.get("right"))
-- )

-- Tables.print(inv:list()[1])
-- if x ~= nil then
--     x.inventory:push("right", x.slot, 64, 4)
-- end

-- print(craft("ic2:itemcable|1"))

local r = craft(
    -- "ic2:itemcable|1",
    "ic2:blockgenerator|2",
    -- "ic2:blockmachinelv|0",
    1,
    Inventory.new(Peripheral.get("back")),

    -- These are the input labels
    Inventory.new(Peripheral.get("back")),
    Inventory.new(Peripheral.get("left")),
    Inventory.new(Peripheral.get("right"))
)

-- local x = countIngredients("ic2:blockgenerator|2")
-- local x = countIngredients("minecraft:furnace|0")
-- Tables.print(x)