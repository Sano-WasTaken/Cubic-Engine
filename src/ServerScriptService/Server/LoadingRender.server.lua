--!native

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Waiter = require(ReplicatedStorage.Classes.Waiter)
local Chunk = require(ServerStorage.Classes.Chunk)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local BlockRenderManager = require(ServerStorage.Managers.BlockRenderManager)
local LoadingScreenNetwork = require(ReplicatedStorage.Networks.LoadingScreenNetwork)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)

WorldManager.Decompressed:Wait()

WorldManager.BlockAdded:Connect(function(block)
	BlockRenderManager.appendBlock(block)
end)

WorldManager.BlockRemoved:Connect(function(block)
	BlockRenderManager.deleteBlock(block)
end)

local CHUNK_SIZE = Chunk.CHUNK_SIZE
local totalSize = CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z

--[[local function AppendBlock(x: number, y: number, z: number, id: number, waiter)
	local neighbors = WorldManager:GetNeighbors(x, y, z)

	if neighbors.Size ~= 6 then
		local part = BlockRenderManager.createBlock(id)

		if part == nil then
			return
		end

		local block = WorldManager:GetBlock(x, y, z)

		local facing = block:GetFacing()

		part.CFrame = CFrame.new(Vector3.new(x, y, z) * 3) * BlockRenderManager.getPartOrientation(facing)
		part.Parent = workspace:FindFirstChild("RenderFolder") -- be replaced by a better solution.

		BlockRenderManager.setBlock(x, y, z, part)

		for _, normalId in Enum.NormalId:GetEnumItems() do
			local direction = Vector3.FromNormalId(normalId)

			local neighbor = neighbors[direction]

			if neighbor == nil then
				local texture = BlockRenderManager.createTexture(id, normalId, facing)

				if texture then
					texture.Parent = part
				end
			end
		end

		waiter:Update()
	else
		local success = BlockRenderManager.destroyBlock(x, y, z)

		if success then
			waiter:Update()
		end
	end
end]]

local function AppendBlock(x: number, y: number, z: number, id: number, waiter)
	local neighbors = WorldManager:GetNeighbors(x, y, z)
	local content = BlockDataProvider:GetData(id)

	if content == nil then
		return
	end

	if neighbors.Size ~= 6 or not content:IsCulled() or not BlockRenderManager.isNeighborsCulled(neighbors) then
		local part = BlockRenderManager.createBlock(id)

		if part == nil then
			return
		end

		local block = WorldManager:GetBlock(x, y, z)

		local facing = block:GetFacing()
		local inverted = block:GetInverted()

		part.CFrame = CFrame.new(Vector3.new(x, y, z) * 3) * BlockRenderManager.getPartOrientation(facing, inverted)
		part.Parent = workspace:FindFirstChild("RenderFolder") -- be replaced by a better solution.

		BlockRenderManager.setBlock(x, y, z, part)

		for _, normalId in Enum.NormalId:GetEnumItems() do
			--local direction = Vector3.FromNormalId(normalId)

			--local neighbor = neighbors[direction]

			local texture = BlockRenderManager.createTexture(id, normalId)

			if texture then
				texture.Parent = part
			end
		end

		waiter:Update()
	else
		local success = BlockRenderManager.destroyBlock(x, y, z)

		if success then
			waiter:Update()
		end
	end
end

local function iterateThroughChunk(chunk: Chunk.Chunk)
	local cx, cy = chunk:GetPosition()

	local pointer = 0
	local waiter = Waiter.new()

	while pointer < totalSize do
		local x, y, z = Chunk.getCoordinatesFromPointer(pointer)

		local id = chunk:_getBlockIdAtPointer(pointer)

		x, z = x + (CHUNK_SIZE.X * cx), z + (CHUNK_SIZE.Z * cy)

		if id ~= 0 then
			AppendBlock(x, y, z, id, waiter)
		end

		pointer += 1
	end
end

local chunks = WorldManager:GetChunks()

local amountOfChunks = #chunks
local loadedChunks = 0

local start = os.clock()
for _, chunk in chunks do
	iterateThroughChunk(chunk)
	loadedChunks += 1

	task.wait()
	LoadingScreenNetwork.IncrementLoadingBar.sendToAll({
		index = loadedChunks,
		max = amountOfChunks,
	})
end

WorldManager.BulkAdded:Connect(function(blocks)
	local waiter = Waiter.new()

	waiter:SetExecutionTime(1)

	for _, block in blocks do
		BlockRenderManager.appendBlock(block)
	end
end)

print("Blocks loaded in:", os.clock() - start, "for", #workspace:FindFirstChild("RenderFolder"):GetChildren(), "blocks")
warn("Total of blocks:", WorldManager:GetAmountOfBlocks())
WorldManager.ChunksGenerated:Fire(true)
LoadingScreenNetwork.LoadingSuccess.sendToAll()
