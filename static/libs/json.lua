require "libs.tables"

local JSONUtils = {
    isArray = function (obj)
        local i = 0
        for _ in pairs(obj) do
            i = i + 1
            if obj[i] == nil then return false end
        end
        return true
    end
}

JSON = {
    sanitize = function (tbl)
        return Tables.map(tbl, function (v)
            if type(v) == "function" then
                return tostring(v)
            elseif type(v) == "table" then
                return JSON.sanitize(v)
            end
        end)
    end,

    encode = function (tbl)
        return textutils.serialiseJSON(JSON.sanitize(tbl))
    end,

    decode = function (str)
        return textutils.unserializeJSON(str)
    end
}