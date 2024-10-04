--!native

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Chunk = require(ServerStorage.Classes.Chunk)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local BlockRenderManager = require(ServerStorage.Managers.BlockRenderManager)
--local Chunk = require(ServerStorage.Classes.Chunk)
local LoadingScreenNetwork = require(ReplicatedStorage.Networks.LoadingScreenNetwork)
local CustomStats = require(ReplicatedStorage.Utils.CustomStats)
--local ExecutionTimer = require(ReplicatedStorage.Utils.ExecutionTimer)

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

WorldManager.Decompressed:Wait()

local chunks = WorldManager:GetChunks()
--task.wait(5) --// Wait a few seconds for nothing, just let the game load itself
print(chunks)
--local iterationsCount = 0

local amountOfChunks = 0

local CALCUL_LIMIT = 0.1

for _, rows in chunks do
	for _, _ in rows do
		amountOfChunks += 1
	end
end

local loadedChunks = 0

local CHUNK_SIZE = Chunk.CHUNK_SIZE

local function iterateThroughChunk(cx: number, cy: number)
	local chunk = WorldManager:GetChunk(cx, cy)

	local totalSize = CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z

	local pointer = 0
	local startTime = os.clock()
	local deltaT = 0
	local maxDuration = 0

	while pointer < totalSize do
		local x, y, z = Chunk.getCoordinatesFromPointer(pointer)

		local id = chunk:_getBlockIdAtPointer(pointer)

		if id ~= 0 then
			x, z = x + (CHUNK_SIZE.X * cx), z + (CHUNK_SIZE.Z * cy)

			local neighbors = WorldManager:GetNeighbors(x, y, z)

			if neighbors.Size ~= 6 then
				local part = BlockRenderManager.createBlock(id)

				part.Position = Vector3.new(x, y, z) * 3
				part.Parent = workspace:FindFirstChild("RenderFolder") -- be replaced by a better solution.

				BlockRenderManager.setBlock(x, y, z, part)

				for _, normalId in Enum.NormalId:GetEnumItems() do
					local direction = Vector3.FromNormalId(normalId)

					local neighbor = neighbors[direction]

					if neighbor == nil then
						local texture = BlockRenderManager.createTexture(id, normalId)

						if texture then
							texture.Parent = part
						end
					end
				end

				--amountOfBlocks += 1

				if os.clock() - startTime >= maxDuration then
					deltaT = RunService.Heartbeat:Wait()
					--IncrementLS:FireAll(loadedChunks, amountOfChunks)
					maxDuration = math.clamp(deltaT / 1, 0, CALCUL_LIMIT)
					startTime = os.clock()
				end
			end
		end

		pointer += 1
	end
end

local start = os.clock()
for x: string, rows in chunks do
	for y: string, _ in rows do
		iterateThroughChunk(tonumber(x) :: number, tonumber(y) :: number)
		loadedChunks += 1

		task.wait()
		IncrementLS:FireAll(loadedChunks, amountOfChunks)
	end
end
print("Blocks loaded in:", os.clock() - start, "for", #workspace:FindFirstChild("RenderFolder"):GetChildren(), "blocks")
warn("Total of blocks:", WorldManager:GetAmountOfBlocks())
WorldManager.ChunksGenerated:Fire(true)
LoadingS:FireAll()
