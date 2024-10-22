local HttpRbxApiService = game:GetService("HttpRbxApiService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)
local chunkBuffer = require(ReplicatedStorage.Classes.BufferManager.chunkBuffer)
local ChunkUtils = require(script.ChunkUtils)
local Compression = require(script.Compression)
local PaletteUtils = require(script.PaletteUtils)

local chunkBuffer = BufferManager.chunkBuffer

--[[
CHUNKS DATA MANAGEMENT.

Chunk:TAG_CHUNK:
- SECTIONS:TAG_ARRAY:
- - Y: TAG_INT
- - Palette:TAG_ARRAY:
- - - Name:TAG_STRING
- - - Properties:TAG_ARRAY:
- - - - Name:TAG_STRING
- - Block_states: TAG_BIT_MAP(n bits per blocks)
]]
local ChunkInterface = {}

export type ChunkInterface = typeof(ChunkInterface) & {
	chunk: ChunkUtils.Chunk,
}

local function new(cx: number, cy: number): ChunkInterface
	return setmetatable({
		chunk = ChunkUtils.createChunk(cx, cy),
	}, { __index = ChunkInterface }) :: any
end

function ChunkInterface.GetChunkPosition(self: ChunkInterface): (number, number)
	return self.chunk.x, self.chunk.y
end

function ChunkInterface.GetSection(self: ChunkInterface, sy: number): ChunkUtils.Section?
	return self.chunk.sections[sy + 1]
end

function ChunkInterface.GenerateSection(self: ChunkInterface, sy: number): ChunkUtils.Section?
	if self:GetSection(sy) == nil then
		local section = ChunkUtils.createSection(sy + 1)

		self.chunk.sections[sy + 1] = section

		return section
	end

	return
end

function ChunkInterface.SetBlockInChunk(
	self: ChunkInterface,
	bx: number,
	by: number,
	bz: number,
	blockData: ChunkUtils.BlockData
) -- TODO: verify the
	if HttpService:JSONEncode({ name = "air" }) == HttpService:JSONEncode(blockData) then
		warn("You should use ChunkInterface:RemoveBlock()")
		return
	end

	local sy = ChunkUtils.getSectionHeightFromBlockHeight(by)

	local section = self:GetSection(sy) or self:GenerateSection(sy)

	local palette = section.palette

	local itIs, id = PaletteUtils.isBlockDataIsInPalette(palette, blockData)

	if not itIs then
		id = #palette + 1
		table.insert(palette, id, blockData)
		section.occurences[id] = 0
	end

	local bicPos = ChunkUtils.getBlockPositionInChunk(bx, by, bz)

	local pointer = ChunkUtils.getPointerFromBlockPositionInChunk(bicPos.X, bicPos.Y, bicPos.Z)

	local blockStates = section.blockStates

	section.occurences[id] += 1

	chunkBuffer.encode12BitAtIndex(blockStates, id, pointer)
end

function ChunkInterface.GetBlockDataAtChunkPosition(
	self: ChunkInterface,
	x: number,
	y: number,
	z: number
): ChunkUtils.BlockData
	local sy = ChunkUtils.getSectionHeightFromBlockHeight(y)

	--local pointer = ChunkUtils.getPointerFromBlockPositionInChunk(x, sy, z)

	local section = self:GetSection(sy)

	if section then
		local blockStates = section.blockStates

		local bicPos = ChunkUtils.getBlockPositionInChunk(x, y, z)

		local pointer = ChunkUtils.getPointerFromBlockPositionInChunk(bicPos.X, bicPos.Y, bicPos.Z)

		local id = chunkBuffer.decode12BitAtIndex(blockStates, pointer)

		local blockData = section.palette[id]

		if blockData then
			return blockData
		end
	end

	return {
		name = "air",
	}
end

function ChunkInterface.RemoveBlockAtChunkPosition(self: ChunkInterface, x: number, y: number, z: number)
	local sy = ChunkUtils.getSectionHeightFromBlockHeight(y)

	local section = self:GetSection(sy)

	if section then
		local blockStates = section.blockStates

		local bicPos = ChunkUtils.getBlockPositionInChunk(x, y, z)

		local pointer = ChunkUtils.getPointerFromBlockPositionInChunk(bicPos.X, bicPos.Y, bicPos.Z)

		local id = chunkBuffer.decode12BitAtIndex(blockStates, pointer)

		chunkBuffer.encode12BitAtIndex(blockStates, 0, pointer)

		section.occurences[id] -= 1

		local occurence = section.occurences[id]

		if occurence == 0 then
			PaletteUtils.removeBlockDataInPalette(section.palette, id)
			section.occurences[id] = nil
		end
	end
end

--[[
@param id number
]]
function ChunkInterface.RemoveBlocksFromBlockData(self: ChunkInterface, blockData: ChunkUtils.BlockData)
	for _, section in self.chunk.sections do
		local isIn, id = PaletteUtils.isBlockDataIsInPalette(section.palette, blockData)

		if not isIn then
			continue
		end

		local pointer, size = 0, ChunkUtils.SECTION_SIZE ^ 3

		while pointer < size do
			local bid = chunkBuffer.decode12BitAtIndex(section.blockStates, pointer)

			if bid == id then
				chunkBuffer.encode12BitAtIndex(section.blockStates, 0, pointer)
				section.occurences[id] -= 1
			end

			pointer += 1
		end

		section.occurences[id] = nil
		PaletteUtils.removeBlockDataInPalette(section.palette, blockData)

		ChunkUtils.shiftSection(section)
		-- make a shifter for the entire section
	end
end

type CompressedChunk = {
	sections: { Compression.CompressedSection },
	tileEntities: {},
}

function ChunkInterface.Compress(self: ChunkInterface): buffer
	local compressedChunk: CompressedChunk = {
		sections = {},
		tileEntities = self.chunk.tileEntities,
	}

	for _, section in self.chunk.sections do
		local compressedSection = Compression.compressSection(section)

		if compressedSection then
			table.insert(compressedChunk.sections, compressedSection)
		end
	end

	return buffer.fromstring(HttpService:JSONEncode(compressedChunk))
end

function ChunkInterface.Decompress(self: ChunkInterface, compressedChunk: buffer): ChunkInterface
	local compressedChunk =
		HttpService:JSONDecode(buffer.readstring(compressedChunk, 0, buffer.len(compressedChunk))) :: CompressedChunk

	self.chunk.tileEntities = compressedChunk.tileEntities

	for _, section in compressedChunk.sections do
		local decompressedSection = Compression.decompressSection(section)

		self.chunk.sections[decompressedSection.y] = decompressedSection
	end

	return self
end

return {
	new = new,
}
