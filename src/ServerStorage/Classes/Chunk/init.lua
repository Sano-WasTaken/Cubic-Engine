local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(script.Parent.Block)
local TileEntitiesManager = require(ServerStorage.Managers.TileEntitiesManager)
local TileEntity = require(script.Parent.TileEntity)
local RLE = require(script.RLE)
--local ExecutionTimer = require(ReplicatedStorage.Utils.ExecutionTimer)

local Chunk = {}

local CHUNK_SIZE = Vector3.new(16, 256, 16) -- 131072

local bufwriteu16 = buffer.writeu16
local bufreadu16 = buffer.readu16

local MaxChunks = 25

local function booleanToNumber(value: boolean): number
	return value and 1 or 0
end

local function numberToBoolean(invert: number): boolean
	return invert == 1
end

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

--[[BITWISE OP PACK & UNPACK STATES]]
--
local function packStates(inverted: boolean, facing: number, active: boolean)
	return bit32.bor(
		bit32.lshift(booleanToNumber(active), 3), -- Shift active state to the left by 3 bits
		bit32.lshift(booleanToNumber(inverted), 2), -- Shift inverted state to the left by 2 bits
		facing -- Add the facing state directly
	)

	-- comment by GPT
end

local function unpackStates(states: number): (boolean, number, boolean)
	local active = bit32.band(bit32.rshift(states, 3), 1) -- Extract active state
	local inverted = bit32.band(bit32.rshift(states, 2), 1) -- Extract inverted state
	local facing = bit32.band(states, 3) -- Extract facing state

	-- comment by GPT

	return numberToBoolean(inverted), facing, numberToBoolean(active)
end

local function new(x: number, y: number, buf: buffer?, entities: {}?, states: buffer?)
	local self = setmetatable({
		buffer = buffer.create(CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z * 2),
		entity = entities or {},
		states = states or buffer.create(CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z),
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

function Chunk:_getStatesAtPointer(pointer: number): number
	local facing = buffer.readu8(self.states, pointer)

	return facing
end

function Chunk:_setStatesAtPointer(pointer: number, states: number)
	buffer.writeu8(self.states, pointer, states)
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
	local pointer = entity:GetPosition()

	if self:_getEntityFromPosition(getCoordinatesFromPointer(pointer)) == nil then
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

	for _, _entity: { p: number } in self.entity do
		if pointer == _entity.p then
			local entity = TileEntitiesManager.Provider:GetData(id):create(_entity)
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

	for i, _entity: { p: number } in self.entity do
		if _entity.p == pointer then
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
function Chunk.GetBlockAtPosition(self: Chunk, x: number, y: number, z: number): Block.IBlock?
	if not verify(x, y, z) then
		return
	end

	local pointer = getPointerToCoordinates(x, y, z)

	local block = self:_getBlockInPosition(x, y, z)
	local states = self:_getStatesAtPointer(pointer)

	local inverted, facing, active = unpackStates(states) -- active not use (DEFAULT VALUE IS false)

	block.facing = facing
	block.inverted = inverted
	block.active = active

	if block:GetID() == 0 then
		block.entity = self:_getEntityFromPosition(x, y, z)

		return
	end

	return block
end

-- new Fast Occurences Compression/Decompression (see RLE encoding)
function Chunk:Compress()
	local decodedChunk = RLE.encode(self.buffer, { idSize = 2, occurencesSize = 2, doWait = true })
	return decodedChunk
end

function Chunk:_decompress(encodedChunk: buffer)
	local buf, amount = RLE.decode(
		encodedChunk,
		{ idSize = 2, occurencesSize = 2, doWait = true },
		CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z
	)

	self.buffer = buf

	self.amount = amount
end

--[[
x, y, z aren't the block position in the world -> position in chunk !
]]
function Chunk.InsertBlock(self: Chunk, block: Block.IBlock, x: number, y: number, z: number): boolean
	if not verify(x, y, z) then
		return false
	end

	local id = block:GetID()
	local entity = block:GetEntity()

	local pointer = getPointerToCoordinates(x, y, z)

	if entity then
		entity:SetPosition(pointer)

		self:_setEntity(entity)
	end

	local states = packStates(block.inverted, block.facing, block.active)

	self:_setStatesAtPointer(pointer, states)
	self:_setBlockInPosition(pointer, id)

	self.amount += 1

	return true
end

function Chunk.DeleteBlock(self: Chunk, x: number, y: number, z: number)
	if not verify(x, y, z) then
		return
	end

	self.amount -= 1

	local pointer = getPointerToCoordinates(x, y, z)
	self:_setStatesAtPointer(pointer, 0)

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

export type Chunk = typeof(Chunk) & {
	amount: number,
}

return {
	new = new,
	getChunkPositionFromBlock = getChunkPositionFromBlock,
	getBlockPositionInChunk = getBlockPositionInChunk,
	getMaxCoordinate = getMaxCoordinate,
	getCoordinatesFromPointer = getCoordinatesFromPointer,
	getPointerToCoordinates = getPointerToCoordinates,
	CHUNK_SIZE = CHUNK_SIZE,
	ChunkBlockSize = CHUNK_SIZE.X * CHUNK_SIZE.Z * CHUNK_SIZE.Y,
	Class = Chunk,
}
