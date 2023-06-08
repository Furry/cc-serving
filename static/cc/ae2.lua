require "libs.tables";
require "libs.computercraft.peripherals";
require "libs.computercraft.inventories";
require "libs.computercraft.net";
require "libs.json"

print("Starting motem establishment")
local modem = Peripheral.get("back");
local collection = InventoryCollection.new();

print("Starting content scanning")
collection:discoverRemote(modem)

local function dumpEnderchests()
    local echests = collection:findAll("enderstorage:ender_storage")
    local others = Tables.filter(collection.inventories, function (x)
        return x.meta.name ~= "enderstorage:ender_storage"
    end)
    
    for _, echest in ipairs(echests) do
        local items = echest:all()

        for slot, item in pairs(items) do
            -- Tables.print(item)
            collection:smartInsertRemote(echest.name, item, slot);
        end
    end
end

print("Starting Dump #1")
dumpEnderchests()

local socket = Socket.new("wss://lua-served.ngrok.io:443/socket");

print("Sending Identify")
socket:sendJson({
    type = "identify",
    side = "server"
})

print("Sending Init")
socket:sendJson({
    type = "init",
    side = "server",
    items = collection:all()
});

print("Starting Update Loop")
-- while true do
    local message = socket.receive(5);
    if message then
        local data = JSON.decode(message);
        Tables.print(data.type);
        if data.type == "identify" then
            print("Sending init")
            socket:sendJson({
                type = "init",
                side = "server",
                items = collection:all()
            });
        end
    end
    dumpEnderchests()
-- end

-- local inv = Inventory.new(Peripheral.get("left"));
-- local q = {}
-- local r = {}
-- for slot, item in pairs(inv:list()) do
--     Tables.push(q, function ()
--         r[slot] = Tables.merge(item, inv.peripheral.getItemMeta(slot))
--     end)
-- end
-- parallel.waitForAll(unpack(q))
-- Tables.print(r[1]);

-- -- Tables.print(Peripheral.get("left").getItemMeta())
