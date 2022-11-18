Tables = {
    --[[
    -- @param table tbl
    -- @param table newTbl
    -- @return table
    --]]
    merge = function(tbl, newTbl)
        for k, v in pairs(newTbl) do
            if type(v) == "table" then
                if type(tbl[k]) == "table" then
                    tables.merge(tbl[k], v)
                else
                    tbl[k] = v
                end
            else
                tbl[k] = v
            end
        end
        return tbl
    end,

    --[[
    -- Filters a table by a provided function.
    -- @param table tbl
    -- @param string query
    -- @return table
    ]]
    filter = function (tbl, callable)
        local newTbl = {}
        for k, v in pairs(tbl) do
            if callable(v) then
                newTbl[#newTbl+1] = v
            end
        end
        return newTbl
    end,

    --[[
    -- Maps a table by a provided function.
    -- @param table tbl
    -- @param function The expression to map
    -- @return table
    ]]
    map = function (tbl, callable)
        local newTbl = {}
        for k, v in pairs(tbl) do
            newTbl[k] = callable(v)
        end
        return newTbl
    end,

    --[[
    -- Prints a table.
    -- @param table tbl
    ]]
    print = function (tbl)
        if type(tbl) ~= "table" then
            print(tbl)
            return
        end
        for k, v in pairs(tbl) do
            print(k, v)
        end
    end,

    --[[
    -- Reverses a table.
    -- @param table tbl
    ]]
    reverse = function (tbl)
        local newTbl = {}
        for i = #tbl, 1, -1 do
            newTbl[#newTbl+1] = tbl[i]
        end
        return newTbl
    end,

    --[[
    -- Checks if a table includes a value in keys or values.
    -- @param table tbl
    -- @param value value
    ]]
    includes = function (tbl, value)
        for k, v in pairs(tbl) do
            if v == value then
                return true
            end
            if k == value then
                return true
            end
        end
        return false
    end,

    beautify = function (tbl)
        local str = "{"
        for k, v in pairs(tbl) do
            str = str .. k .. ": " .. v .. ", "
        end
        str = str:sub(1, -3) .. "}"
        return str
    end,

    clone = function (tbl)
        local newTbl = {}
        for k, v in pairs(tbl) do
            newTbl[k] = v
        end
        return newTbl
    end,

    spread = function (tbl1, tbl2)
        for k, v in pairs(tbl2) do
            tbl1[k] = v
        end
        return tbl1
    end,

    sort = function (tbl, callable)
        local copy = Tables.clone(tbl)
        table.sort(copy, callable)
        return copy
    end,
}