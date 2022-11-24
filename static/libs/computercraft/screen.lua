Screen = {
    screen = {},
    new = function (peripheral)
        local c = { 
            screen = peripheral,
            x = 1,
            y = 1
         }

        c.write = Screen.write;
        c.clear = Screen.clear;
        c.writeLine = Screen.writeLine;
        c.center = Screen.center;
        c.warn = Screen.warn;
        c.error = Screen.error;
        c.log = Screen.log;
        c.newline = Screen.newline;

        return c
    end,

    write = function (self, text)
        self.screen.write(text)
        self.x = self.x + string.len(text)
        self.screen.setCursorPos(self.x, self.y);
    end,

    writeLine = function (self, text, color)
        self.screen.write(text)

        self.x = 1
        self.y = self.y + 1
        self.screen.setCursorPos(self.x, self.y);
    end,

    error = function (self, text)
        self.screen.setTextColor(colors.red)
        self:writeLine(text)
        self.screen.setTextColor(colors.white)
    end,

    warn = function (self, text)
        self.screen.setTextColor(colors.yellow)
        self:writeLine(text)
        self.screen.setTextColor(colors.white)
    end,

    log = function (self, text)
        self.screen.setTextColor(colors.green)
        self:writeLine(text)
        self.screen.setTextColor(colors.white)
    end,

    set = function(self, x, y)
        self.x = x
        self.y = y
        self.screen.setCursorPos(self.x, self.y);
    end,

    clear = function (self)
        self.screen.clear()
        self.screen.setCursorPos(1, 1)
        self.x = 1
        self.y = 1
    end,

    center = function (self, text)
        local width, height = self.screen.getSize()
        local x = math.floor(width / 2) - math.floor(string.len(text) / 2)
        self.screen.setCursorPos(x, self.y)
        self.screen.write(text)
        self.y = self.y + 1
        self.x = 1
        self.screen.setCursorPos(self.x, self.y);
    end,

    newline = function (self)
        self.y = self.y + 1
        self.x = 1
        self.screen.setCursorPos(self.x, self.y);
    end,

    getSize = function (self)
        return self.screen.getSize()
    end
}

Cursor = {
    data = {x = nil, y = nil},
    new = function (screen, y)
        local c = {
            screen = screen,
            y = y,
            x = 1
        }

        c.clear = Cursor.clear;
        c.write = Cursor.write;
        c.writeCenter = Cursor.writeCenter;

        return c
    end,

    clear = function (self)
        local width, _ = self.screen.getSize();
        local prevx, prevy = self.screen.getCursorPos();
        self.screen.setCursorPos(1, self.y)
        self.screen.write(string.rep(" ", width))
        self.x = 1
        self.screen.setCursorPos(prevx, prevy)
    end,

    write = function (self, text)
        -- Store the previous
        local prevx, prevy = self.screen.getCursorPos();

        Cursor.clear(self)
        self.screen.setCursorPos(self.x, self.y)
        self.screen.write(text)
        self.x = self.x + string.len(text)

        -- Set the cursor back to the previous
        self.screen.setCursorPos(prevx, prevy)
    end,

    writeCenter = function (self, text)
        -- Store the previous
        local prevx, prevy = self.screen.getCursorPos();

        Cursor.clear(self)
        local width, _ = self.screen.getSize();
        local x = math.floor(width / 2) - math.floor(string.len(text) / 2)
        self.screen.setCursorPos(x, self.y)
        self.screen.write(text)
        self.x = 1

        -- Set the cursor back to the previous
        self.screen.setCursorPos(prevx, prevy)
    end
}