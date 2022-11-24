require "libs.tables"
require "libs.computercraft.peripherals"

Inventory = {
    peripheral = {},
    new = function (peripheral)
        local c = { peripheral = peripheral }

        c.list = Inventory.list;
        c.push = Inventory.push;
        c.get = Inventory.get;
        c.size = Inventory.size;
        c.suck = Inventory.suck;
        c.pull = Inventory.pull;
        c.list = Inventory.list;
        c.items = Inventory.items;

        c.direction = peripheral.direction

        return c
    end,

    list = function (self)
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
    end
}