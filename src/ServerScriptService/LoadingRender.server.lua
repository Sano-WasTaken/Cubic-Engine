--!native

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldManager = require(ServerStorage.Managers.WorldManager)
local BlockRenderManager = require(ServerStorage.Managers.BlockRenderManager)
--local Chunk = require(ServerStorage.Classes.Chunk)
local LoadingScreenNetwork = require(ReplicatedStorage.Networks.LoadingScreenNetwork)
local CustomStats = require(ReplicatedStorage.Utils.CustomStats)

local IncrementLS = LoadingScreenNetwork.IncrementLoadingBar:Server()
local LoadingS = LoadingScreenNetwork.LoadingSucceed:Server()

WorldManager.BlockAdded:Connect(function(block)
	BlockRenderManager.appendBlock(block)
	CustomStats:IncrementStat("BlockCreated", 1)
end)

WorldManager.BlockRemoved:Connect(function(block)
	BlockRenderManager.deleteBlock(block)
	CustomStats:IncrementStat("BlockCreated", -1)
end)

local chunks = WorldManager:GetChunks()

task.wait(5) --// Wait a few seconds for nothing, just let the game load itself

--local iterationsCount = 0

local amountOfChunks = 0
local amountOfBlocks = 0

for _, rows in chunks do
	for _, _ in rows do
		amountOfChunks += 1
	end
end

local loadedChunks = 0

local function iterateThroughChunk(cx: number, cy: number)
	local chunk = WorldManager:GetChunk(cx, cy)

	chunk:Iterate(function(block)
		amountOfBlocks += 1
		CustomStats:IncrementStat("BlockCreated", 1)

		if amountOfBlocks % 1500 == 0 then
			task.wait()
			--IncrementLS:FireAll(loadedChunks, amountOfChunks)
		end

		BlockRenderManager.appendBlock(block)
	end)
end

for x, rows in chunks do
	for y, _ in rows do
		iterateThroughChunk(tonumber(x), tonumber(y))
		loadedChunks += 1

		task.wait()
		IncrementLS:FireAll(loadedChunks, amountOfChunks)
	end
end

WorldManager.ChunksGenerated:Fire(true)
LoadingS:FireAll()
