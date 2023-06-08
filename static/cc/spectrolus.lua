require "libs.tables"


-- Check if there's redstone signal on the left side
local s_counts = {}
for i = 1, 16 do
    s_counts = Tables.insert(s_counts, turtle.getItemCount(i))
end

local min = Tables.min(s_counts)
local iters = min - 1;

for i = 1, 1 do
    local left = redstone.getInput("left")
    if not left then
        for indx = 1, 16 do
            turtle.select(indx)
            turtle.drop(1)
        end
        turtle.select(1)
    end
end

