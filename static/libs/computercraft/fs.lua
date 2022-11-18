Fs = {

}

Cache = {
    cacheDirectory = "/.cache",
    set = function(key, value)
        local file = fs.open(Cache.cacheDirectory .. "/" .. key, "w")
        file.write(textutils.serialize(value))
        file.close()
    end,

    get = function(key)
        local file = fs.open(Cache.cacheDirectory .. "/" .. key, "r")
        if file == nil then
            return nil
        end
        local value = textutils.unserialize(file.readAll())
        file.close()
        return value
    end,

    has = function(key)
        return fs.exists(Cache.cacheDirectory .. "/" .. key)
    end
}