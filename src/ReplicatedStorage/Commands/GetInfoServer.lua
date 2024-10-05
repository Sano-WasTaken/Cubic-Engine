local ServerStorage = game:GetService("ServerStorage")
local Stats = game:GetService("Stats")
local WorldManager = require(ServerStorage.Managers.WorldManager)
return function()
	local stats = Stats:GetTotalMemoryUsageMb()
	local nbOfParts = #workspace:FindFirstChild("RenderFolder"):GetChildren()
	local totalBlocks = WorldManager:GetAmountOfBlocks()

	return `Server Memory: {stats}MB | Parts in Server: {nbOfParts} | Blocks in save {totalBlocks}`
end
