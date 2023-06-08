require "libs.json"

Logging = {
    url = "https://lua-served.ngrok.io/logs",
    post = function(self, contents)
        -- If contents is a table
        if type(contents) == "table" then
            contents = JSON.encode(contents)
        end

        local r = http.post(self.url, contents, {
            ["Content-Type"] = "text/plain"
        })
    end,
}