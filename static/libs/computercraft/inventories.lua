require "libs.tables"
require "libs.computercraft.peripherals"

Inventory = {
    peripheral = {},
    new = function (peripheral)
        local c = { peripheral = peripheral }

        c.new = Inventory.new;
        c.list = Inventory.list;
        c.push = Inventory.push;
        c.get = Inventory.get;
        c.size = Inventory.size;

        return c
    end,

    list = function (self)
        return self.peripheral.list();
    end,

    push = function (self, direction, slot, count)
        self.peripheral.pushItems(direction, slot, count)
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
    end
}