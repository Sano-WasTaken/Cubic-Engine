local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local StatsNetwork = require(ReplicatedStorage.Networks.ServerStatsNetwork)
local CustomStats = require(ReplicatedStorage.Utils.CustomStats)

local updateStats = StatsNetwork.UpdateStats:Server()
local getStats = StatsNetwork.GetStats

local function getStatsInfo(): StatsNetwork.Stats
	return {
		Memory = Stats:GetTotalMemoryUsageMb(),
		BlockCreated = CustomStats:GetStat("BlockCreated"),
		BlockRendered = #workspace:FindFirstChild("RenderFolder"):GetChildren(),
	}
end

task.defer(function()
	while task.wait(60) do
		local stats: StatsNetwork.Stats = getStatsInfo()

		updateStats:FireAll(stats)
	end
end)

getStats:SetCallback(function(_: Player)
	return getStatsInfo()
end)
