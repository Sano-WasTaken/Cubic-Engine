local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ServerStorage.Classes.Block)
local Signal = require(ReplicatedStorage.Classes.Signal)
local Chunk = require(ServerStorage.Classes.Chunk)
local DataProviderManager = require(ServerStorage.Managers.DataProviderManager)

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local WorldManager = {
	Container = {
		Chunks = {},
		ExtraContents = {},
	},
	IslandOwner = nil,
	BlockAdded = Signal.new() :: Signal.Signal<Block>,
	BlockRemoved = Signal.new() :: Signal.Signal<Block>,
	ChunksGenerated = Signal.new() :: Signal.Signal<boolean>,
}

export type Block = Block.IBlock

function WorldManager:GetChunks()
	return self.Container.Chunks
end

function WorldManager:GetChunk(cx: number, cy: number)
	local chunks = self:GetChunks()

	chunks[tostring(cx)] = chunks[tostring(cx)] or {}

	local chunk = chunks[tostring(cx)][tostring(cy)]

	if chunk == nil then
		chunk = Chunk.new(cx, cy)
		chunks[tostring(cx)][tostring(cy)] = chunk
	end

	if typeof(chunk) == "buffer" then
		chunk = Chunk.new(cx, cy, chunk)

		chunks[tostring(cx)][tostring(cy)] = chunk
	end

	if typeof(chunk) == "string" then
		chunk = Chunk.new(cx, cy, HttpService:JSONDecode(chunk))

		chunks[tostring(cx)][tostring(cy)] = chunk
	end

	return chunk
end

function WorldManager:GetBlock(x: number, y: number, z: number)
	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = self:GetChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local block = chunk:GetBlockAtPosition(x, y, z)

	return block
end

function WorldManager:IsBlockExist(x: number, y: number, z: number)
	local block = self:GetBlock(x, y, z)

	if block == nil or BlockEnum[block:GetID()] == nil then
		return false
	end

	return (block:GetID() ~= 0 and BlockEnum[block:GetID()] ~= nil)
end

function WorldManager:Insert(block: Block)
	local x, y, z = block:GetPosition()

	if self:IsBlockExist(x, y, z) then
		return
	end

	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = self:GetChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local success = chunk:InsertBlock(block, x, y, z)

	if success then
		self.BlockAdded:Fire(block)
	end
end

function WorldManager:Delete(x: number, y: number, z: number)
	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = self:GetChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local block = chunk:GetBlockAtPosition(x, y, z)

	if block == nil then
		return
	end

	chunk:DeleteBlock(x, y, z)

	self.BlockRemoved:Fire(block)
end

function WorldManager:GetNeighbor(x: number, y: number, z: number, direction: Vector3)
	return self:GetBlock(x + direction.X, y + direction.Y, z + direction.Z)
end

function WorldManager:GetNeighbors(x: number, y: number, z: number)
	local neighbors = {}

	for _, normalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = self:GetNeighbor(x, y, z, direction)

		neighbors[direction] = neighbor
	end

	return neighbors
end

function WorldManager:DecompressChunks(compressedChunks: { [string]: { buffer } })
	local chunks = self.Container.Chunks

	for cx, rows in compressedChunks do
		for cy, chunk in rows do
			chunks[cx] = chunks[cx] or {}
			task.wait()

			chunk = Chunk.new(tonumber(cx), tonumber(cy), chunk)

			chunks[cx][cy] = chunk
		end
	end
end

function WorldManager:GetCompressedChunks()
	local compressedChunk: { { buffer } } = {}

	for cx, rows in self:GetChunks() do
		for cy, chunk in rows do
			compressedChunk[cx] = compressedChunk[cx] or {}

			compressedChunk[cx][cy] = chunk:Compress()
		end
	end

	return compressedChunk
end

function WorldManager:SetOwner(player: Player)
	self.IslandOwner = player
end

function WorldManager:GetOwner()
	return self.IslandOwner
end

function WorldManager:IsPlayerIsland()
	return self:GetOwner() ~= nil
end

function WorldManager:Init(chunks: { [string]: { buffer } })
	WorldManager:DecompressChunks(chunks)
end

function WorldManager:WaitForOwner()
	repeat
		task.wait()
	until self:GetOwner() ~= nil
end

function WorldManager:WaitForOwnerData()
	self.ChunksGenerated:Wait()
end

-- Auto Save
coroutine.wrap(function()
	if WorldManager:IsPlayerIsland() then
		while true do
			task.wait(5 * 60)

			print("About to save chunks")
			local start = os.clock()
			local compressedChunks = WorldManager:GetCompressedChunks()

			DataProviderManager.saveData(tostring(WorldManager:GetOwner().UserId), "Chunks", compressedChunks)
			print("Chunks saved in " .. os.clock() - start .. " secs", compressedChunks)
		end
	end
end)()

-- Bind to close
game:BindToClose(function()
	if WorldManager:IsPlayerIsland() then
		local compressedChunks = WorldManager:GetCompressedChunks()

		print("Data saved:", HttpService:JSONEncode(compressedChunks):len() .. " Octets")

		DataProviderManager.saveData(tostring(WorldManager:GetOwner().UserId), "Chunks", compressedChunks)
	end
end)

return WorldManager
