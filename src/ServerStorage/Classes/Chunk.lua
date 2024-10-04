local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Waiter = require(ReplicatedStorage.Classes.Waiter)
local TileEntitiesManager = require(ServerStorage.Managers.TileEntitiesManager)
local Block = require(script.Parent.Block)
local TileEntity = require(script.Parent.TileEntity)
--local ExecutionTimer = require(ReplicatedStorage.Utils.ExecutionTimer)

local Chunk = {}

local CHUNK_SIZE = Vector3.new(16, 256, 16) -- 131072
local OCCURENCE_SIZE = 2 ^ 16 -- 65536

local bufcopy = buffer.copy
local bufwriteu16 = buffer.writeu16
local bufreadu16 = buffer.readu16

local MaxChunks = 25

local function getMaxCoordinate(): (number, number)
	return -MaxChunks, MaxChunks
end

local function getChunkPositionFromBlock(x: number, z: number): (number, number)
	return (x // CHUNK_SIZE.X), (z // CHUNK_SIZE.Z)
end

local function getBlockPositionInChunk(x: number, y: number, z: number): (number, number, number)
	local cx, cy = getChunkPositionFromBlock(x, z)

	return x - CHUNK_SIZE.X * cx, y, z - CHUNK_SIZE.Z * cy
end

local function verify(x: number, y: number, z: number): boolean
	return (x < CHUNK_SIZE.X and x >= 0 and y < CHUNK_SIZE.Y and y >= 0 and z < CHUNK_SIZE.Z and z >= 0)
end

local function writeOccurences(buf: buffer, id: number, occurences: number)
	local len = buffer.len(buf)

	local newBuf = buffer.create(len + 4)

	bufcopy(newBuf, 0, buf, 0, len)

	bufwriteu16(newBuf, len, id)
	bufwriteu16(newBuf, len + 2, occurences)

	return newBuf
end

local function getOccurences(buf: buffer, i: number)
	local occ = bufreadu16(buf, i + 2)

	occ = occ == 0 and OCCURENCE_SIZE or occ

	return bufreadu16(buf, i), occ, 4
end

local function getPointerToCoordinates(x: number, y: number, z: number): number
	local j = x + z * CHUNK_SIZE.X + y * (CHUNK_SIZE.X * CHUNK_SIZE.Z)

	return j
end

local function getCoordinatesFromPointer(pointer: number)
	local x = pointer % CHUNK_SIZE.X
	local y = pointer // (CHUNK_SIZE.X * CHUNK_SIZE.Z)
	local z = (pointer % (CHUNK_SIZE.X * CHUNK_SIZE.Z)) // CHUNK_SIZE.Z

	return x, y, z
end

local function new(x: number, y: number, buf: buffer?, entities: {}?)
	local self = setmetatable({
		buffer = buffer.create(CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z * 2),
		entity = entities or {},
		--encoded = buf,
		x = x,
		y = y,
		amount = 0,
	}, {
		__index = Chunk,
	})

	if buf then
		self:_decompress(buf)
	end

	return self
end

function Chunk:_setBlockInPosition(pointer: number, id: number)
	bufwriteu16(self.buffer, pointer * 2, id)
end

function Chunk:_deleteBlockInPosition(x: number, y: number, z: number)
	local pointer = getPointerToCoordinates(x, y, z)

	bufwriteu16(self.buffer, pointer * 2, 0)
end

function Chunk:_getBlockInPosition(x: number, y: number, z: number): Block.IBlock?
	local pointer = getPointerToCoordinates(x, y, z)

	--print(buffer.len(self.buffer), pointer * 2, x, y, z)
	local id = bufreadu16(self.buffer, pointer * 2)

	--x, z = x + (CHUNK_SIZE.X * self.x), z + (CHUNK_SIZE.Z * self.y)

	return Block.new(id, self:_getEntityFromPosition(x, y, z))
		:SetPosition(x + (CHUNK_SIZE.X * self.x), y, z + (CHUNK_SIZE.Z * self.y))
end

function Chunk:_getBlockIdAtPointer(pointer: number): number
	return bufreadu16(self.buffer, pointer * 2)
end

function Chunk:_setEntity(entity: TileEntity.TileEntity)
	local x, y, z = entity:GetPosition()

	if self:_getEntityFromPosition(x, y, z) == nil then
		table.insert(self.entity, entity:GetContainerData())
	end
end

function Chunk:_getEntityFromPosition(x: number, y: number, z: number): TileEntity.TileEntity?
	local pointer = getPointerToCoordinates(x, y, z)

	local id = self:_getBlockIdAtPointer(pointer)

	if TileEntitiesManager.Provider:GetData(id) == nil then
		return
	end

	local fentity

	x, z = x + (CHUNK_SIZE.X * self.x), z + (CHUNK_SIZE.Z * self.y)

	for _, _entity: { ID: number } in self.entity do
		local entity = TileEntitiesManager.Provider:GetData(_entity.ID):create(_entity)

		local fx, fy, fz = entity:GetPosition()

		if fx == x and fy == y and fz == z then
			fentity = entity

			break
		end
	end

	return fentity
end

function Chunk:_removeEntityFromPosition(x: number, y: number, z: number)
	local pointer = getPointerToCoordinates(x, y, z)

	local id = self:_getBlockIdAtPointer(pointer)

	if TileEntitiesManager.Provider:GetData(id) == nil then
		return
	end

	x, z = x + (CHUNK_SIZE.X * self.x), z + (CHUNK_SIZE.Z * self.y)

	for i, _entity: { ID: number } in self.entity do
		local entity = TileEntitiesManager.Provider:GetData(_entity.ID):create(_entity)

		local fx, fy, fz = entity:GetPosition()

		if fx == x and fy == y and fz == z then
			table.remove(self.entity, i)

			break
		end
	end
end

function Chunk:GetAmountOfBlock(): number
	return self.amount
end

--[[
x, y, z aren't the block position in the world -> position in chunk !
]]
function Chunk:GetBlockAtPosition(x: number, y: number, z: number): Block.IBlock?
	if not verify(x, y, z) then
		return
	end

	local block = self:_getBlockInPosition(x, y, z)

	if block:GetID() == 0 then
		block.entity = self:_getEntityFromPosition(x, y, z)

		return
	end

	return block
end

-- new Fast Occurences Compression (see RLE encoding)
function Chunk:Compress()
	local chunkBuffer = buffer.create(0)
	local totalSize = CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z

	local pointer, localId, occurences = 0, -1, 0

	local waiter = Waiter.new()

	while pointer < totalSize do
		local id = bufreadu16(self.buffer, pointer * 2) -- block and block:GetID() or 0 -- unusable [si quelqu'un passe par la kill me pls]

		if id == localId then
			occurences += 1
		else
			if localId ~= -1 then
				chunkBuffer = writeOccurences(chunkBuffer, localId, occurences)
				waiter:Update()
			end
			localId = id
			occurences = 1
		end

		pointer += 1
	end

	chunkBuffer = writeOccurences(chunkBuffer, localId, occurences)

	return chunkBuffer
end

function Chunk:_decompress(buffurizedChunk: buffer)
	local totalSize = CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z

	local localPointer, occurences = 0, 0
	local id, occ, len = 0, 0, 0

	local waiter = Waiter.new()

	while totalSize > occurences do
		id, occ, len = getOccurences(buffurizedChunk, localPointer)

		if id ~= 0 then
			waiter:Start()
			for j = occurences, occurences + occ - 1 do
				buffer.writeu16(self.buffer, j * 2, id)
			end

			waiter:Update()
			self.amount += occ
		end

		occurences += occ

		localPointer += len
	end
end

--[[
x, y, z aren't the block position in the world -> position in chunk !
]]
function Chunk:InsertBlock(block: Block.IBlock, x: number, y: number, z: number): boolean
	if not verify(x, y, z) then
		return false
	end

	local id = block:GetID()

	local pointer = getPointerToCoordinates(x, y, z)

	local tileClass = TileEntitiesManager.Provider:GetData(id)

	-- tileEntity creation and initialisation
	if tileClass then
		local tile = tileClass:create()

		x, z = x + (CHUNK_SIZE.X * self.x), z + (CHUNK_SIZE.Z * self.y)

		tile:SetPosition(x, y, z)

		self:_setEntity(tile)

		print(self.entity)
	end

	self:_setBlockInPosition(pointer, id)

	self.amount += 1

	return true
end

function Chunk:DeleteBlock(x: number, y: number, z: number)
	if not verify(x, y, z) then
		return
	end

	self.amount -= 1

	self:_removeEntityFromPosition(x, y, z)
	self:_deleteBlockInPosition(x, y, z)
end

function Chunk:GetPosition(): (number, number)
	return self.x, self.y
end

-- for testing
function Chunk:GetJSON()
	return HttpService:JSONEncode(self.chunkPositions)
end

export type Chunk = typeof(Chunk)

return {
	new = new,
	getChunkPositionFromBlock = getChunkPositionFromBlock,
	getBlockPositionInChunk = getBlockPositionInChunk,
	getMaxCoordinate = getMaxCoordinate,
	getCoordinatesFromPointer = getCoordinatesFromPointer,
	CHUNK_SIZE = CHUNK_SIZE,
	ChunkBlockSize = CHUNK_SIZE.X * CHUNK_SIZE.Z * CHUNK_SIZE.Y,
}
