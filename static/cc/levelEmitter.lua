require "libs.computercraft.shortcuts"

local code = [[
local threshold = 1000
local bsu = peripheral.wrap("front");
local directions = {"left", "right", "top", "bottom", "back", "front"}
while true do
    local item = bsu.getItem(1)
    if item ~= nil then
        local meta = item.getMetadata()
        if meta["count"] > threshold then
            for _, direction in ipairs(directions) do
                redstone.setOutput(direction, true)
            end
        else
            for _, direction in ipairs(directions) do
                redstone.setOutput(direction, false)
            end
        end
    end
    os.sleep(0.1)
end
]]

Shortcuts.install(code)
loadstring(code)();