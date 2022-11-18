Events = {
    events = {},
    on = function (name, callback)
        if Events.events[name] == nil then
            Events.events[name] = {}
        end
        table.insert(Events.events[name], callback)
    end,

    emit = function (name, ...)
        if Events.events[name] == nil then
            return
        end
        for _, callback in pairs(Events.events[name]) do
            callback(...)
        end
    end,

    clear = function (name)
        Events.events[name] = {}
    end
}