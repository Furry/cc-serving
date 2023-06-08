require "libs.computercraft.peripherals"
require "libs.computercraft.inventories"
require "libs.tables"

local inv = Peripheral.get("back")
Tables.print(inv.getItem(1))