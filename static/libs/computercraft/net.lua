require "libs.json"

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