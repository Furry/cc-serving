require "libs.computercraft.shortcuts";
require "libs.computercraft.net";

local code = Net.get("https://lua-served.ngrok.io/cc/emcMonitor.lua").raw()
Shortcuts.install(
    code
)

loadstring(code)()