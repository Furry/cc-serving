require "libs.tables"
require "libs.computercraft.peripherals"
require "libs.strings"

Inventory = {
    peripheral = {},

    remote = function(name, modem)
        local c = { name = name, modem = modem, peripheral = nil }
        local locations = {}
        local counts = {};

        c.meta = modem.callRemote(name, "getMetadata");
        c.list = Inventory.list;
        c.all = Inventory.all;

        c.locations = locations
        c.counts = counts

        for k, v in pairs(c:list()) do
            local alias = v.name .. "|" .. v.damage;
            if locations[alias] == nil then
                locations[alias] = {}
            end
            locations[alias][k] = v.count;
            counts[alias] = (counts[alias] or 0) + v.count
        end

        return c;
    end,

    new = function (peripheral)
        local c = { peripheral = peripheral }
        local locations = {}
        local counts = {}

        c.meta = peripheral.getMetadata();
        c.list = Inventory.list;
        c.push = Inventory.push;
        c.get = Inventory.get;
        c.size = Inventory.size;
        c.suck = Inventory.suck;
        c.pull = Inventory.pull;
        c.list = Inventory.list;
        c.items = Inventory.items;
        c.fetch = Inventory.fetch;
        c.all = Inventory.all;

        c.direction = peripheral.direction
        c.locations = locations
        c.counts = counts
        c.cache = {}

        -- Cache all items in this inventory
        for k, v in pairs(c:list()) do
            local alias = v.name .. "|" .. v.damage;
            if locations[alias] == nil then
                locations[alias] = {}
            end
            locations[alias][k] = v.count;
            counts[alias] = (counts[alias] or 0) + v.count
        end

        return c
    end,

    list = function (self)
        if self.peripheral == nil then
            return self.modem.callRemote(self.name, "list");
        end

        return self.peripheral.list();
    end,

    push = function (self, direction, slot, count, toSlot)
        return self.peripheral.pushItems(direction, slot, count, toSlot)
    end,

    get = function (self, slot)
        local item = self.peripheral.getItem(slot);
        if item == nil then
            return nil
        else
            item.slot = slot
            return Tables.spread(item, item.getMetadata())
        end
    end,

    size = function (self)
        return self.peripheral.size()
    end,

    suck = function (self, count)
        self.peripheral.suckItems(count)
    end,

    pull = function (self, direction, slot, count, toSlot)
        self.peripheral.pullItems(direction, slot, count, toSlot)
    end,

    items = function(self)
        local cache = {}
        local list = self.peripheral.list();
        for k in pairs(list) do
            local item = list[k]
            cache[item.name .. "|" .. item.damage] = {
                slot = k,
                count = item.count,
                damage = item.damage
            }
        end
        return cache
    end,

    all = function (self)
        local cache = {}
        local list = self:list();
        for k, item in pairs(list) do
            cache[tostring(k)] = {
                count = item.count,
                damage = item.damage,
                name = item.name
            }
        end
        return cache
    end,

    fetch = function(self, item)
        local name = item
        local damage = 0
        if string.find(item, "|") then
            local split = Strings.split(item, "|")
            name = split[1]
            damage = tonumber(split[2])
        end

        if (self.counts[item] or 0) <= 0 then
            return nil
        end

        local locations = self.locations[item]
        for k, v in pairs(locations) do
            if self.locations[item][k] > 1 then
                self.locations[item][k] = self.locations[item][k] - 1
            else
                self.locations[item][k] = nil
            end
            return k
        end
    end
}

InventoryCollection = {
    cache = {
        inventories = {}
    },
    new = function ()
        local c = {
            inventories = {}
        }

        c.discover = InventoryCollection.discover;
        c.discoverRemote = InventoryCollection.discoverRemote;
        c.all = InventoryCollection.all;
        c.findAll = InventoryCollection.findAll;
        c.smartInsertRemote = InventoryCollection.smartInsertRemote;

        return c
    end,

    discover = function (self)
        local peripherals = Peripheral.all()
        for k, v in pairs(peripherals) do
            if v.type == "inventory" then
                self.cache.inventories[k] = Inventory.new(v)
            end
        end
    end,

    discoverRemote = function (self, modem)
        local q = {};
        for i, v in ipairs(modem.getNamesRemote()) do
            q[i] = function()
                if (Tables.includes(modem.getMethodsRemote(v), "list")) then
                    Tables.push(self.inventories, Inventory.remote(v, modem))
                end
            end
        end
        parallel.waitForAll(unpack(q))
    end,

    all = function (self)
        local q = {};
        local items = {};
        local tmp = 0
        for i, v in ipairs(self.inventories) do
            q[i] = function()
                for _, y in pairs(v:all()) do
                    tmp = tmp + 1
                    items[tmp] = y
                    -- Tables.push(items, y)
                end
            end
        end

        parallel.waitForAll(unpack(q))
        return items
    end,

    findAll = function (self, name)
        local q = {};
        for _, v in ipairs(self.inventories) do
            if v.meta.name == name then
                Tables.push(q, v)
            end
        end
        return q;
    end,

    smartInsertRemote = function (self, from, item, count, slot)
        -- Iterate over every item in all inventories
        
        -- Navigate through every slot in every inventory,
        local others = Tables.filter(self.inventories, function (v)
            return v.name ~= from
        end)

        local start = os.epoch("utc")
        for _, inv in ipairs(others) do
            -- Tables.print(item)
            local fullName = item.name .. "|" .. item.damage;
            if inv.counts[fullName] ~= nil then
                Tables.print(inv.counts[fullName])
            end
        end
        print("Took " .. os.epoch("utc") - start .. "ms")
    end
}