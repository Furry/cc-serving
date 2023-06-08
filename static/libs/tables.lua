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

    sort = function (tbl, callable)
        local copy = Tables.clone(tbl)
        for i = 1, #tbl do
            for j = 1, #tbl do
                if callable(copy[i], copy[j]) then
                    local temp = copy[i]
                    copy[i] = copy[j]
                    copy[j] = temp
                end
            end
        end
        return copy
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

    push = function (tbl, value)
        tbl[#tbl+1] = value
        return tbl
    end,

    range = function (start, stop)
        local tbl = {}
        for i = math.min(start, stop), math.max(start, stop) do
            tbl[#tbl+1] = i
        end
        if start > stop then
            tbl = Tables.reverse(tbl)
        end
        return tbl
    end,

    insert = function (tbl, value, index)
        if index == nil then
            return Tables.push(tbl, value)
        end

        local newTbl = {}
        for i = 1, #tbl do
            if i == index then
                newTbl[#newTbl+1] = value
            end
            newTbl[#newTbl+1] = tbl[i]
        end

        return newTbl
    end,

    length = function (tbl)
        local i = 0
        for k, v in pairs(tbl) do
            i = i + 1
        end
        return i
    end,

    union = function (tbl1, tbl2)
        local newTbl = {}
        for k, v in pairs(tbl1) do
            newTbl[k] = v
        end
        for k, v in pairs(tbl2) do
            newTbl[k] = v
        end
        return newTbl
    end,

    difference = function (tbl1, tbl2)
        local newTbl = {}
        for k, v in pairs(tbl1) do
            if not Tables.includes(tbl2, v) then
                newTbl[k] = v
            end
        end
        return newTbl
    end,

    remove = function (tbl, value)
        local newTbl = {}
        for k, v in pairs(tbl) do
            if v ~= value then
                newTbl[k] = v
            end
        end
        return newTbl
    end,

    min = function (tbl)
        local min = nil
        for k, v in pairs(tbl) do
            if min == nil or v < min then
                min = v
            end
        end
        return min
    end,
}