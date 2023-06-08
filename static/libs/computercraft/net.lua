require "libs.json";
require "libs.events";

local NetUtilityFunctions = {
    ToFormatOption = function (text)
        return {
            raw = function ()
                return text
            end,
            json = function ()
                return JSON.decode(text)
            end
        }
    end
}

Net = {
    get = function (url, headers)
        local request = http.get(url, headers)
        if request == nil then
            error("Failed to get " .. url)
        end
        local response = request.readAll()
        request.close()
        return NetUtilityFunctions.ToFormatOption(response)
    end
}

Socket = {
    new = function (url)
        local o = {};
        local ws, err = http.websocket(url)
        if not ws then
            error("Failed to connect to " .. url .. ": " .. err)
        end

        o.ws = ws;
        o.send = ws.send;
        o.receive = ws.receive;
        o.close = ws.close;
        o.sendJson = Socket.sendJson;

        return o;
    end,

    sendJson = function (self, tbl)
        local json = JSON.encode(tbl);
        self.ws.send(json)
    end
}