Shortcuts = {
    install = function (code)
        -- save it to the startup file
        local file = fs.open("startup", "w")
        file.write(code)
        file.close()
    end
}