local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ServerStorage.Classes.Block)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Chunk = require(ServerStorage.Classes.Chunk)
--local TileEntitiesManager = require(ServerStorage.Managers.TileEntitiesManager)
local DataProviderManager = require(ServerStorage.Managers.DatabaseManager)

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local ExecutionTimer = require(ReplicatedStorage.Utils.ExecutionTimer)

-- [CLASS DECLARATION] --
--
local WorldManager = {
	-- [ISLAND CONTENTS] --
	--
	Container = {
		Chunks = {},
		ExtraContent = {},
	},
	IslandOwner = nil :: Player?,

	-- [OTHER VALUES] --
	--
	IsGenerated = false,

	-- [SIGNALS] --
	--
	BlockAdded = Signal.new(),
	BlockRemoved = Signal.new(),
	ChunksGenerated = Signal.new(),
	Decompressed = Signal.new(),
}

WorldManager.ChunksGenerated:Connect(function()
	WorldManager.IsGenerated = true
end)

export type Block = Block.IBlock

-- [SIGNALS METHODS] --
--
function WorldManager:BlockAddedByIdSignal(id: number)
	local signal = Signal.new()

	self.BlockAdded:Connect(function(block)
		if block:GetID() == id then
			signal:Fire(block)
		end
	end)

	return signal
end

function WorldManager:BlockAddedInPosition(x: number, y: number, z: number)
	local signal = Signal.new()

	self.BlockAdded:Connect(function(block)
		local bx, by, bz = block:GetPosition()
		if bx == x and by == y and bz == z then
			signal:Fire(block)
		end
	end)

	return signal
end

-- [CHUNKS UTILS] --
--
function WorldManager:GetChunks(): { [string]: Chunk.Chunk }
	return self.Container.Chunks
end

function WorldManager:GetChunk(cx: number, cy: number): Chunk.Chunk?
	local chunks = self:GetChunks()

	chunks[tostring(cx)] = chunks[tostring(cx)] or {}

	local chunk = chunks[tostring(cx)][tostring(cy)]

	if chunk == nil then
		chunk = Chunk.new(cx, cy)
		chunks[tostring(cx)][tostring(cy)] = chunk
	end

	-- [[ you can add other schematics for chunks like custom chunks data organizing. ]] --

	if typeof(chunk) == "buffer" then
		chunk = Chunk.new(cx, cy, chunk)

		chunks[tostring(cx)][tostring(cy)] = chunk
	end

	-- If you want to use JSON Encoding for the chunk
	--[[if typeof(chunk) == "string" then 
		chunk = Chunk.new(cx, cy, HttpService:JSONDecode(chunk))

		chunks[tostring(cx)][tostring(cy)] = chunk
	end]]

	return chunk
end

-- [BLOCKS UTILS] --
--
function WorldManager:SwapId(block: Block, id: number)
	block:_setId(id)
	self.BlockRemoved:Fire(block)
	self.BlockAdded:Fire(block)
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

	if self:IsBlockExist(x, y, z) then -- what the hell is this thing... (just checking this position)
		return
	end

	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = self:GetChunk(cx, cy)

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local success = chunk:InsertBlock(block, x, y, z) -- dono why i make this

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

function WorldManager:GetNeighbor(x: number, y: number, z: number, direction: Vector3 | Enum.NormalId)
	local direction: Vector3 = typeof(direction) == "Vector3" and direction
		or Vector3.FromNormalId(direction :: Enum.NormalId)

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

-- [DATA DECOMPRESSION/COMPRESSION] --
--
function WorldManager:DecompressChunks(compressedChunks: { [string]: { [string]: buffer } })
	local chunks: { [string]: { [string]: buffer } } = self.Container.Chunks

	for cx: string, rows in compressedChunks do
		for cy: string, chunk in rows do
			--print(chunk)
			task.wait(ExecutionTimer:GetDeltaTime() * 10)

			chunks[cx] = chunks[cx] or {}

			chunk = Chunk.new(tonumber(cx) :: number, tonumber(cy) :: number, chunk)

			chunks[cx][cy] = chunk
		end
	end
end

function WorldManager:GetCompressedChunks()
	local compressedChunk: { { buffer } } = {}

	for cx, rows in self:GetChunks() do
		for cy, chunk in rows do
			--print(chunk)
			task.wait(ExecutionTimer:GetDeltaTime() * 10)

			compressedChunk[cx] = compressedChunk[cx] or {}

			compressedChunk[cx][cy] = chunk:Compress()
		end
	end

	return compressedChunk
end

-- [OWNER STATE] --
--
function WorldManager:SetOwner(player: Player)
	self.IslandOwner = player
end

function WorldManager:GetOwner()
	return self.IslandOwner
end

function WorldManager:IsPlayerIsland()
	return self:GetOwner() ~= nil
end

function WorldManager:Init(island: DataProviderManager.Island)
	self:DecompressChunks(island.Chunks)

	--task.wait(ExecutionTimer:GetDeltaTime() * 1000)
	print("decompressed !")

	WorldManager.Decompressed:Connect(function(...: boolean)
		print("decrompréssée !")
	end)

	WorldManager.Decompressed:Fire(true)
end

function WorldManager:GetIslandData(): DataProviderManager.Island
	return {
		Chunks = self:GetCompressedChunks(),
		--ExtraContent = self.Container.ExtraContent, -- TODO: create management for this
		ExtraContent = {},
	}
end

function WorldManager:Save()
	if self:IsPlayerIsland() and self.IsGenerated then
		local data = self:GetIslandData()

		local bufSizes = 0

		for _, rows in data.Chunks do
			for _, buf in rows do
				bufSizes += buffer.len(buf)
			end
		end

		warn("total bytes saved:", HttpService:JSONEncode(data):len() .. " bytes encoded [base64 JSONEncode]")
		warn("total bytes saved:", bufSizes .. " bytes non encoded [base64 JSONEncode]")
		DataProviderManager:SaveIslandData(self:GetOwner().UserId, data)
	end
end

-- [WAITING FOR METHODS] --
function WorldManager:WaitForOwner()
	local owner = self:GetOwner()

	repeat
		if owner then
			break
		end
		owner = self:GetOwner()

		task.wait()
	until owner ~= nil

	return owner
end

function WorldManager:WaitForOwnerData()
	return self.ChunksGenerated:Wait()
end

function WorldManager:WaitForDecompression()
	return self.Decompressed:Wait()
end

do -- [just bc i want netsing the code nvm] --
	-- Auto Save
	coroutine.wrap(function()
		while true do
			task.wait(5 * 60)

			WorldManager:Save()
		end
	end)()

	-- Bind to close
	game:BindToClose(function()
		WorldManager:Save()
	end)
end

return WorldManager
