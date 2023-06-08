require "libs.tables"

AE2 = {
    jobs = {},
    connection = {},
    new = function (p)
        local c = {
            connection = p,
            jobs = {}
        }

        c.stock = AE2.stock;
        c.findAndCraft = AE2.findAndCraft;
        c.find = AE2.find;
        c.sweepJobs = AE2.sweepJobs;
        c.isJob = AE2.isJob;

        return c
    end,

    stock = function (self)
        local s = {}
        for i, item in ipairs(self.connection.listAvailableItems()) do
            s[item.name .. "@" .. item.damage] = item
        end

        return s
    end,

    sweepJobs = function (self)
        -- Go over every job, if the os time is greater than the end time, remove it.
        for i, job in ipairs(self.jobs) do
            if os.time() > job.endtime then
                self.jobs = Tables.remove(self.jobs, i)
            end
        end
    end,

    isJob = function (self, item)
        Tables.filter(self.jobs, function (job)
            return job.item == item
        end)

        return Tables.length(self.jobs) > 0
    end,

    findAndCraft = function (self, item, count)
        self:sweepJobs()
        local items = self.connection.findItems(item)
        if Tables.length(items) > 0 then
            local i = items[1]

            Tables.push(self.jobs, {
                item = item,
                count = count,
                endtime = os.time() + count * 1.2
            })

            -- If it has the key 'craft'
            if i.craft ~= nil then
                i.craft(count)
            end
        end
    end
}