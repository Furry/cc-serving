require "libs.computercraft.shortcuts"

local code = [[
local modem = peripheral.wrap("left")
modem.open(6969)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    if message == "craft" then
        turtle.craft(64)
        modem.transmit(6969, 6969, "complete")
    end
end
]]
Shortcuts.install(code)
loadstring(code)()