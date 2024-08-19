local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)

export type Stats = {
    Memory: number,
    BlockCreated: number,
    BlockRendered: number,
}

return {
	UpdateStats = Red.Event("UpdateStats", function(stats: Stats)
        return stats
    end),

    GetStats = Red.Function("GetStats", function(...) return ... end, function(stats: Stats)
        return stats
    end)
}