type StatsItem = "BlockCreated" | "Machines" | "BlockRendered"

local Stats: {[StatsItem]: number} = {
    BlockCreated = 0,
    Machines = 0,
    BlockRendered = 0,
}

function Stats:UpdateStat(name: StatsItem, value: any)
    Stats[name] = value
end

function Stats:GetStat(name: StatsItem)
    return Stats[name] or 0
end

function Stats:IncrementStat(name: StatsItem, increment: number)
    self[name] = self[name] or 0

    self[name] += increment
end

return Stats