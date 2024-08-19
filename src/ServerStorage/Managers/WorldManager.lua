local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Block = require(ServerStorage.Classes.Block)
local Signal = require(ReplicatedStorage.Classes.Signal)
local Chunk = require(ServerStorage.Classes.Chunk)
local DataProviderManager = require(ServerStorage.Managers.DataProviderManager)

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local isPlayerIsland = true

local player = Players.PlayerAdded:Wait()

local bufferChunk: { { Chunk.Chunk | buffer } } = isPlayerIsland
		and (DataProviderManager.getData(tostring(player.UserId), "Chunks") or {})
	or {}

local chunksToPreGen = 2

local blockAdded = Signal.new()
local blockRemoved = Signal.new()
local chunksGenerated = Signal.new()

export type Block = Block.IBlock

local function DecompressAll()
	for cx, rows in bufferChunk do
		for cy, chunk in rows do
			task.wait()

			chunk = Chunk.new(tonumber(cx), tonumber(cy), chunk)

			bufferChunk[cx][cy] = chunk
		end
	end
end

local function GetCompressedChunks()
	local compressedChunk: { { buffer } } = {}

	for cx, rows in bufferChunk do
		for cy, chunk in rows do
			compressedChunk[cx] = compressedChunk[cx] or {}

			compressedChunk[cx][cy] = chunk:Compress()
		end
	end

	print(compressedChunk)

	return compressedChunk
end

local function getChunk(cx: number, cy: number): Chunk.Chunk
	bufferChunk[tostring(cx)] = bufferChunk[tostring(cx)] or {}

	local chunk = bufferChunk[tostring(cx)][tostring(cy)]

	if chunk == nil then
		chunk = Chunk.new(cx, cy)
		bufferChunk[tostring(cx)][tostring(cy)] = chunk
	end

	if typeof(chunk) == "buffer" then
		chunk = Chunk.new(cx, cy, chunk)

		bufferChunk[tostring(cx)][tostring(cy)] = chunk
	end

	if typeof(chunk) == "string" then
		chunk = Chunk.new(cx, cy, HttpService:JSONDecode(chunk))

		bufferChunk[tostring(cx)][tostring(cy)] = chunk
	end

	return chunk
end

local function pregenChunks()
	for x = -chunksToPreGen, chunksToPreGen do
		for y = -chunksToPreGen, chunksToPreGen do
			getChunk(x, y) -- TODO: maybe you can create something better
		end
	end

	chunksGenerated:Fire()
end

local function getBlock(x: number, y: number, z: number): Block.IBlock
	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = getChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local block = chunk:GetBlockAtPosition(x, y, z)

	return block
end

local function isBlockExist(x: number, y: number, z: number)
	local block = getBlock(x, y, z)

	if block == nil or BlockEnum[block:GetID()] == nil then
		return false
	end

	return (block:GetID() ~= 0 and BlockEnum[block:GetID()] ~= nil)
end

local function insert(block: Block.IBlock)
	local x, y, z = block:GetPosition()

	if isBlockExist(x, y, z) then
		return
	end

	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = getChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local success = chunk:InsertBlock(block, x, y, z)

	if success then
		blockAdded:Fire(block)
	end
end

local function delete(x: number, y: number, z: number)
	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = getChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local block = chunk:GetBlockAtPosition(x, y, z)

	if block == nil then
		return
	end

	chunk:DeleteBlock(x, y, z)

	blockRemoved:Fire(block)
end

local function getNeighbor(x: number, y: number, z: number, direction: Vector3): Block.IBlock
	return getBlock(x + direction.X, y + direction.Y, z + direction.Z)
end

local function getNeighbors(x: number, y: number, z: number): ({ [Vector3]: Block.IBlock }, number)
	local neighbors = {}

	for _, normalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = getNeighbor(x, y, z, direction)

		neighbors[direction] = neighbor
	end

	return neighbors
end

-- Decompress all the chunks
--DecompressAllChunks()
DecompressAll()

-- Pregen 5 by 5 region
pregenChunks()

-- Auto Save
coroutine.wrap(function()
	if isPlayerIsland then
		while true do
			task.wait(5 * 60)

			print("About to save chunks")
			local start = os.clock()
			local compressedChunks = GetCompressedChunks()

			DataProviderManager.saveData(tostring(player.UserId), "Chunks", compressedChunks)
			print("Chunks saved in " .. os.clock() - start .. " secs", compressedChunks)
		end
	end
end)()
--

game:BindToClose(function()
	if isPlayerIsland then
		local compressedChunks = GetCompressedChunks()

		print("Data saved:", HttpService:JSONEncode(compressedChunks):len() .. " Octets")

		DataProviderManager.saveData(tostring(player.UserId), "Chunks", compressedChunks)
	end
end)

return {
	getBlock = getBlock,
	getNeighbor = getNeighbor,
	insert = insert,
	BlockAdded = blockAdded,
	BlockRemoved = blockRemoved,
	ChunksGenerated = chunksGenerated,
	getNeighbors = getNeighbors,
	delete = delete,
	isLinkedToRenderer = false,
	getChunk = getChunk,
	getChunks = function()
		return bufferChunk
	end,
	IsPlayerIsland = isPlayerIsland,
}
