local function random(length)
    local str = "";
    for i = 1, length do
        str = str .. string.char(math.random(97, 122));
    end
    return str;
end

local function contains(input, sub)
    return input:find(sub, 1, true) ~= nil
end

local function startswith(input, start)
    return input:sub(1, #start) == start
end

local function endswith(input, ending)
    return ending == "" or input:sub(-#ending) == ending
end

local function replace(input, old, new)
    local s = input
    local search_start_idx = 1

    while true do
        local start_idx, end_idx = s:find(old, search_start_idx, true)
        if (not start_idx) then
            break
        end

        local postfix = s:sub(end_idx + 1)
        s = s:sub(1, (start_idx - 1)) .. new .. postfix

        search_start_idx = -1 * postfix:len()
    end

    return s
end

local function insert(input, pos, text)
    return input:sub(1, pos - 1) .. text .. input:sub(pos)
end

-- Format seconds to days, hours, minutes, seconds.
local function formatSeconds(seconds)
   local str = "";
    local days = math.floor(seconds / 86400);
    local hours = math.floor((seconds % 86400) / 3600);
    local minutes = math.floor((seconds % 3600) / 60);
    local seconds = math.floor(seconds % 60);
    if days > 0 then
        str = str .. days .. "d ";
    end
    if hours > 0 then
        str = str .. hours .. "h ";
    end
    if minutes > 0 then
        str = str .. minutes .. "m ";
    end
    if seconds > 0 then
        str = str .. seconds .. "s";
    end
    return str; 
end

chars = {
    random = random,
    contains = contains,
    startswith = startswith,
    endswith = endswith,
    replace = replace,
    insert = insert,
    formatSeconds = formatSeconds
}