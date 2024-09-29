local HttpService = game:GetService("HttpService")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(script.Parent.Block)
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

local function new(x: number, y: number, buf: buffer?)
	local self = setmetatable({
		buffer = buffer.create(CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z * 2),
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
	local blockBuf = buffer.create(2)
	bufwriteu16(blockBuf, 0, id)

	bufcopy(self.buffer, pointer * 2, blockBuf, 0, 2)
end

function Chunk:_deleteBlockInPosition(x: number, y: number, z: number)
	local pointer = getPointerToCoordinates(x, y, z)

	buffer.fill(self.buffer, pointer * 2, 0, 2)
end

function Chunk:_getBlockInPosition(x: number, y: number, z: number): Block.IBlock?
	local pointer = getPointerToCoordinates(x, y, z)

	--print(buffer.len(self.buffer), pointer * 2, x, y, z)
	local id = buffer.readu16(self.buffer, pointer * 2)

	return Block.new(id):SetPosition(x + (CHUNK_SIZE.X * self.x), y, z + (CHUNK_SIZE.Z * self.y))
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
		return
	end

	return block
end

-- new Fast Occurences Compression (see RLE encoding)
function Chunk:Compress()
	local chunkBuffer = buffer.create(0)
	local totalSize = CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z

	local pointer, localId, occurences = 0, -1, 0

	while pointer < totalSize do
		local id = bufreadu16(self.buffer, pointer * 2) -- block and block:GetID() or 0 -- unusable [si quelqu'un passe par la kill me pls]

		if id == localId then
			occurences += 1
		else
			if localId ~= -1 then
				chunkBuffer = writeOccurences(chunkBuffer, localId, occurences)
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

	while totalSize > occurences do
		id, occ, len = getOccurences(buffurizedChunk, localPointer)

		if id ~= 0 then
			for j = occurences, occurences + occ - 1 do
				--self:_setBlockInPosition(j, id) -- reducing __index metamethod

				--local blockBuf = buffer.create(2)
				buffer.writeu16(self.buffer, j * 2, id)

				--buffer.copy(self.buffer, j * 2, blockBuf, 0, 2) -- bro wtf?
			end
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

	local pointer = getPointerToCoordinates(x, y, z)

	self:_setBlockInPosition(pointer, block:GetID())

	self.amount += 1

	return true
end

--[[
x, y, z aren't the block position in the world -> position in chunk !
]]
function Chunk:Iterate(callback: (block: Block.IBlock) -> ())
	local totalSize = CHUNK_SIZE.X * CHUNK_SIZE.Y * CHUNK_SIZE.Z

	local id, pointer, block = 0, 0, nil

	local x, y, z = 0, 0, 0

	while pointer < totalSize do
		id = bufreadu16(self.buffer, pointer * 2) -- block and block:GetID() or 0 -- unusable [si quelqu'un passe par la kill me pls]

		if id ~= 0 then
			x, y, z = getCoordinatesFromPointer(pointer)

			block = Block.new(id):SetPosition(x + (CHUNK_SIZE.X * self.x), y, z + (CHUNK_SIZE.Z * self.y))

			callback(block)
		end

		pointer += 1
	end
end

function Chunk:DeleteBlock(x: number, y: number, z: number)
	if not verify(x, y, z) then
		return
	end

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
	CHUNK_SIZE = CHUNK_SIZE,
	ChunkBlockSize = CHUNK_SIZE.X * CHUNK_SIZE.Z * CHUNK_SIZE.Y,
}
