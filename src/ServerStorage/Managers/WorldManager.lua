--local Debris = game:GetService("Debris")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--local RunService = game:GetService("RunService")
local Waiter = require(ReplicatedStorage.Classes.Waiter)
local DatabaseManager = require(script.Parent.DatabaseManager)
local Block = require(ServerStorage.Classes.Block)
local BulkImport = require(ServerStorage.Classes.BulkImport)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Chunk = require(ServerStorage.Classes.Chunk)
--local TileEntitiesManager = require(ServerStorage.Managers.TileEntitiesManager)
local DataProviderManager = require(ServerStorage.Managers.DatabaseManager)

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local MAX_CHUNK_RADIUS = 30

-- [CLASS DECLARATION] --
--
local WorldManager = {
	-- [ISLAND CONTENTS] --
	--
	Container = {
		Chunks = {},
	},
	IslandOwner = nil :: Player?,

	-- [OTHER VALUES] --
	--
	IsGenerated = false,

	-- [SIGNALS] --
	--
	BlockAdded = Signal.new() :: Signal.Signal<Block.IBlock>,
	BlockRemoved = Signal.new() :: Signal.Signal<Block.IBlock>,
	BulkAdded = Signal.new() :: Signal.Signal<{ Block.IBlock }>,
	ChunksGenerated = Signal.new() :: Signal.Signal<boolean>,
	Decompressed = Signal.new() :: Signal.Signal<boolean>,
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
function WorldManager:IsChunkOut(cx: number, cy: number): boolean
	return cx > MAX_CHUNK_RADIUS or cy > MAX_CHUNK_RADIUS
end

function WorldManager:GetChunks(): { Chunk.Chunk }
	local chunks = {}

	for _, rows in self.Container.Chunks do
		for _, chunk in rows do
			table.insert(chunks, chunk)
		end
	end

	return chunks
end

function WorldManager:GetChunk(cx: number, cy: number): Chunk.Chunk?
	if WorldManager:IsChunkOut(cx, cy) then
		return
	end

	local chunks = self.Container.Chunks

	chunks[cx] = chunks[cx] or {}

	local chunk = chunks[cx][cy]

	if chunk == nil then
		chunk = Chunk.new(cx, cy)
		chunks[cx][cy] = chunk
	end

	-- [[ you can add other schematics for chunks like custom chunks data organizing. ]] --

	if typeof(chunk.chunk) == "buffer" then
		chunk = Chunk.new(cx, cy, chunk.buffer, chunk.entity)

		chunks[cx][cy] = chunk
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

function WorldManager:GetBlock(x: number, y: number, z: number): Block.IBlock?
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

function WorldManager:BulkInsert(): BulkImport.BulkImport
	local bulkImport = BulkImport.new()

	bulkImport.Stopped:Connect(function(queue)
		local waiter = Waiter.new()

		for index, block in queue.container do
			local x, y, z = block:GetPosition()

			if self:IsBlockExist(x, y, z) then
				table.remove(queue.container, index)
				continue
			end

			local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

			local chunk = self:GetChunk(cx, cy)

			if chunk == nil then
				continue
			end

			waiter:Update()

			x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

			local success = chunk:InsertBlock(block, x, y, z)

			if not success then
				table.remove(queue.container, index)
			end
		end

		WorldManager.BulkAdded:Fire(queue.container)
	end)

	return bulkImport
end

function WorldManager:Insert(block: Block)
	local x, y, z = block:GetPosition()

	if self:IsBlockExist(x, y, z) then
		return
	end

	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = self:GetChunk(cx, cy)

	if chunk == nil then
		return
	end

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local success = chunk:InsertBlock(block, x, y, z) -- dono why i make this

	if success then
		self.BlockAdded:Fire(block)
	end
end

function WorldManager:Delete(x: number, y: number, z: number)
	local cx, cy = Chunk.getChunkPositionFromBlock(x, z)

	local chunk = self:GetChunk(cx, cy)

	if chunk == nil then
		return
	end

	x, y, z = Chunk.getBlockPositionInChunk(x, y, z)

	local block = chunk:GetBlockAtPosition(x, y, z)

	if block == nil then
		return
	end

	chunk:DeleteBlock(x, y, z)

	self.BlockRemoved:Fire(block)
end

function WorldManager:GetNeighbor(x: number, y: number, z: number, direction: Vector3 | Enum.NormalId): Block.IBlock
	local newDirection: Vector3 = (
		typeof(direction) == "Vector3" and direction or Vector3.FromNormalId(direction :: Enum.NormalId)
	)

	return self:GetBlock(x + newDirection.X, y + newDirection.Y, z + newDirection.Z)
end

function WorldManager:GetNeighbors(x: number, y: number, z: number): { [Vector3]: Block.IBlock, Size: number }
	local neighbors = {}

	local sum = 0

	for _, normalId: Enum.NormalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = self:GetNeighbor(x, y, z, direction)

		if neighbor then
			neighbors[direction] = neighbor
			sum += 1
		end
	end

	neighbors.Size = sum

	return neighbors
end

local function getCardinalDirection(direction: Vector3): Block.Facing?
	local north = Vector3.new(0, 0, 1)
	local south = Vector3.new(0, 0, -1)
	local east = Vector3.new(1, 0, 0)
	local west = Vector3.new(-1, 0, 0)

	-- Comparer avec les directions cardinales en utilisant des produits scalaires
	local dotNorth = direction:Dot(north)
	local dotSouth = direction:Dot(south)
	local dotEast = direction:Dot(east)
	local dotWest = direction:Dot(west)

	-- Trouver la direction la plus proche
	local maxDot = math.max(dotNorth, dotSouth, dotEast, dotWest)

	local facing

	if maxDot == dotNorth then
		facing = "NORTH"
	elseif maxDot == dotSouth then
		facing = "SOUTH"
	elseif maxDot == dotEast then
		facing = "EAST"
	elseif maxDot == dotWest then
		facing = "WEST"
	end

	return facing
end

local function getInverted(mouseLocalY: number, normal: Vector3): boolean
	local inverted = false

	inverted = mouseLocalY > 0

	if normal == Vector3.new(0, -1, 0) then
		inverted = true
	elseif normal == Vector3.new(0, 1, 0) then
		inverted = false
	end

	return inverted
end

function WorldManager:LocalRaycastV2(
	origin: Vector3,
	direction: Vector3,
	range: number
): { Block: Block.IBlock?, Normal: Vector3, Facing: Block.Facing, Inverted: boolean }?
	local params = RaycastParams.new()

	params.FilterDescendantsInstances = { workspace:FindFirstChild("RenderFolder"):GetChildren() }
	params.FilterType = Enum.RaycastFilterType.Include

	local raycastResult = workspace:Raycast(origin, direction * range, params)

	if raycastResult and raycastResult.Instance then
		local position: Vector3 = (raycastResult.Instance.Position / 3):Floor()
		local normal = (raycastResult.Normal + Vector3.new(1e-4, 1e-4, 1e-4)):Floor()

		local mousePos = CFrame.new(position):PointToObjectSpace(raycastResult.Position / 3)

		local block = WorldManager:GetBlock(position.X, position.Y, position.Z)

		return {
			Block = block,
			Normal = normal,
			Facing = getCardinalDirection(direction),
			Inverted = getInverted(mousePos.Y, normal),
		}
	end

	return
end

--[[function WorldManager:LocalRaycastV1(
	origin: Vector3,
	direction: Vector3,
	range: number,
	listId: { number }?
): { Block: Block.IBlock, Distance: number }?
	listId = listId or {}

	local DEBUG = RunService:IsStudio()

	local tileSize = 1
	local blockSize = 3
	local halfBlockSize = blockSize / 2

	local pos = (origin / blockSize)
	local dir = direction.Unit

	local stepX = (dir.X > 0) and 1 or -1
	local stepY = (dir.Y > 0) and 1 or -1
	local stepZ = (dir.Z > 0) and 1 or -1

	local tMaxX = (dir.X > 0) and (math.ceil(pos.X) - pos.X) or (pos.X - math.floor(pos.X))
	local tMaxY = (dir.Y > 0) and (math.ceil(pos.Y) - pos.Y) or (pos.Y - math.floor(pos.Y))
	local tMaxZ = (dir.Z > 0) and (math.ceil(pos.Z) - pos.Z) or (pos.Z - math.floor(pos.Z))

	tMaxX = tMaxX / math.abs(dir.X)
	tMaxY = tMaxY / math.abs(dir.Y)
	tMaxZ = tMaxZ / math.abs(dir.Z)

	local tDeltaX = blockSize / math.abs(dir.X)
	local tDeltaY = blockSize / math.abs(dir.Y)
	local tDeltaZ = blockSize / math.abs(dir.Z)

	local distanceTravelled = 0

	local function createPart(x: number, y: number, z: number)
		local part = Instance.new("Part")

		part.Size = Vector3.one * 3
		part.Position = Vector3.new(x, y, z) * 3
		part.Transparency = 0.7
		part.Material = Enum.Material.Neon

		part.Anchored = true
		part.Parent = workspace
		part.CanCollide = false
		part.CanQuery = false

		Debris:AddItem(part, 5)

		return part
	end

	while distanceTravelled < range do
		local vec = pos:Floor()

		createPart(vec.X, vec.Y, vec.Z)

		if tMaxX < tMaxY and tMaxX < tMaxZ then
			pos = pos + Vector3.new(stepX, 0, 0)
			distanceTravelled = tMaxX
			tMaxX += tDeltaX
		elseif tMaxY < tMaxZ then
			pos = pos + Vector3.new(0, stepY, 0)
			distanceTravelled = tMaxY
			tMaxY += tDeltaY
		else
			pos = pos + Vector3.new(0, 0, stepZ)
			distanceTravelled = tMaxZ
			tMaxZ += tDeltaZ
		end

		local vec = pos:Floor()

		--local relative = (pos % blockSize) - Vector3.new(halfBlockSize, halfBlockSize, halfBlockSize)

		local block = WorldManager:GetBlock(vec.X, vec.Y, vec.Z)

		if block then
			local highlight = Instance.new("Highlight")

			highlight.FillColor = Color3.new(1, 0, 0)

			local part = createPart(vec.X, vec.Y, vec.Z)

			highlight.Parent = part
			highlight.Adornee = part

			return { Block = block, Distance = distanceTravelled }
		end
	end

	return
end]]

function WorldManager:GetAmountOfBlocks(): number
	local sum = 0

	local chunks = WorldManager:GetChunks()

	for _, chunk in chunks do
		sum += chunk:GetAmountOfBlock()
	end

	return sum
end

-- [DATA DECOMPRESSION/COMPRESSION] --
--
function WorldManager:DecompressChunks(compressedChunks: { DatabaseManager.chunk })
	local chunks: { { Chunk.Chunk } } = self.Container.Chunks

	for _, chunk in compressedChunks do
		local cx, cy = chunk.cx, chunk.cy

		chunks[cx] = chunks[cx] or {}

		local e = chunk.tileEntities

		if type(e) == "buffer" then
			e = HttpService:JSONDecode(buffer.readstring(e, 0, buffer.len(e)))
		end

		chunk = Chunk.new(cx, cy, chunk.chunk, e, chunk.states)

		chunks[cx][cy] = chunk
	end
end

function WorldManager:GetCompressedChunks(): { DatabaseManager.chunk }
	local compressedChunk = {}

	for _, chunk in self:GetChunks() :: { { Chunk.Chunk } } do
		--task.wait(ExecutionTimer:GetDeltaTime() * 10)

		if chunk:GetAmountOfBlock() == 0 then
			continue
		end

		local cx, cy = chunk:GetPosition()

		local formatChunk: DatabaseManager.chunk = {
			chunk = chunk:Compress(),
			tileEntities = buffer.fromstring(HttpService:JSONEncode(chunk.entity)),
			cx = cx,
			cy = cy,
			states = chunk.states,
		}

		table.insert(compressedChunk, formatChunk)
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

	WorldManager.Decompressed:Connect(function()
		warn("Total blocks saved:", WorldManager:GetAmountOfBlocks())
	end)

	WorldManager.Decompressed:Fire(true)
end

function WorldManager:GetIslandData(): DataProviderManager.Island
	return {
		Chunks = self:GetCompressedChunks() :: {},
	}
end

function WorldManager:Save()
	if self:IsPlayerIsland() and self.IsGenerated then
		local data: DatabaseManager.Island = self:GetIslandData()

		local bufSizes = 0

		for _, chunk in data.Chunks do
			bufSizes += buffer.len(chunk.chunk)
		end

		warn("Total bytes saved:", HttpService:JSONEncode(data):len() .. " bytes encoded [base64 JSONEncode]")
		warn("Total bytes saved:", bufSizes .. " bytes non encoded [base64 JSONEncode]")
		warn("Total blocks saved:", WorldManager:GetAmountOfBlocks())
		DatabaseManager:SaveIslandData(self:GetOwner().UserId, data)
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
