local HttpService = game:GetService("HttpService")

local Block = require(script.Parent.Block)

local Chunk = {}

local CHUNK_SIZE = Vector3.new(16, 512, 16)
local MaxChunks = 16

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

local function new(x: number, y: number, buf: buffer?)
	local self = setmetatable({
		grid = {},
		x = x,
		y = y,
		amount = 0,
	}, {
		__index = Chunk,
	})

	if buf and buffer.len(buf) % 17 == 0 then
		self:_decompress(buf)
	end

	return self
end

function Chunk:_setBlockInPosition(x: number, y: number, z: number, block: Block.IBlock)
	local chunkPos = self.grid
	local _, buffer = block:GetBuffer()

	chunkPos[x] = chunkPos[x] or {}
	chunkPos[x][y] = chunkPos[x][y] or {}
	chunkPos[x][y][z] = buffer
end

function Chunk:_deleteBlockInPosition(x: number, y: number, z: number)
	local chunkPos = self.grid

	if chunkPos[x] and chunkPos[x][y] and chunkPos[x][y][z] then
		self.amount -= 1

		chunkPos[x][y][z] = nil
	end
end

function Chunk:_getBlockInPosition(x: number, y: number, z: number): Block.IBlock?
	local chunkPos = self.grid

	if chunkPos[x] and chunkPos[x][y] and chunkPos[x][y][z] then
		return chunkPos[x][y][z]
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

	local buf = self:_getBlockInPosition(x, y, z)

	if buf == nil then
		return
	end

	local block = Block.new(nil, buf)

	return block
end

function Chunk:Compress()
	local size = 0
	local blocks = {} :: { buffer }

	self:Iterate(function(block: Block.IBlock)
		local _, buf = block:GetBuffer()
		size += Block.BufferSize
		table.insert(blocks, buf)
	end)

	local buffurizedChunk = buffer.create(size)

	for i, block in blocks do
		local offset = (i - 1) * Block.BufferSize

		buffer.copy(buffurizedChunk, offset, block, 0, Block.BufferSize)
	end

	return buffurizedChunk
end

function Chunk:_decompress(buffurizedChunk: buffer)
	local size = buffer.len(buffurizedChunk) / Block.BufferSize

	self.amount = size

	for i = 0, size - 1 do
		local block = buffer.create(Block.BufferSize)

		buffer.copy(block, 0, buffurizedChunk, i * Block.BufferSize, Block.BufferSize)

		block = Block.new(nil, block)

		local x, y, z = block:GetPosition()

		x, y, z = getBlockPositionInChunk(x, y, z)

		self:_setBlockInPosition(x, y, z, block)
	end
end

--[[
x, y, z aren't the block position in the world -> position in chunk !
]]
function Chunk:InsertBlock(block: Block.IBlock, x: number, y: number, z: number): boolean
	if not verify(x, y, z) then
		return false
	end

	self:_setBlockInPosition(x, y, z, block)

	self.amount += 1

	return true
end

--[[
x, y, z aren't the block position in the world -> position in chunk !
]]
function Chunk:Iterate(callback: (block: Block.IBlock) -> ())
	local chunkPos = self.grid

	for _, i in chunkPos do
		for _, j in i do
			for _, k in j do
				if k == nil then
					continue
				end

				local block = Block.new(nil, k)

				callback(block)
			end
		end
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
