local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bitBuffer = require(ReplicatedStorage.Classes.BufferManager.bitBuffer)
local chunkBuffer = require(ReplicatedStorage.Classes.BufferManager.chunkBuffer)
local ChunkUtils = require(script.Parent.ChunkUtils)
-- 16x16x16 = 4096

-- 2^12 = 4096

-- buffer MAX size = 16x16x16 x 12

local function calculateBitsFromPaletteLenght(len: number): number
	return math.ceil(math.log(len) / math.log(2))
end

export type CompressedSection = {
	y: number,
	palette: { ChunkUtils.BlockData },
	blockStates: buffer,
}

local function compressSection(section: ChunkUtils.Section): CompressedSection?
	local amountOfBlocks = ChunkUtils.getBlockAmountInSection(section)

	if amountOfBlocks == 0 then
		return nil
	end

	local bitNumberPerBlock = calculateBitsFromPaletteLenght(#section.palette + 1)

	local size = ChunkUtils.SECTION_SIZE ^ 3

	local encodedBufN = bitBuffer.createNBitBuffer(bitNumberPerBlock, size)
	local buf = section.blockStates

	local pointer = 0

	while pointer < size do
		local id = chunkBuffer.decode12BitAtIndex(buf, pointer)

		if id ~= 0 then
			bitBuffer.WriteNBit(encodedBufN, pointer, id)
		end

		pointer += 1
	end

	return {
		y = section.y,
		blockStates = encodedBufN.buf,
		palette = section.palette,
	}
end

local function decompressSection(compressedSection: CompressedSection): ChunkUtils.Section
	local size = ChunkUtils.SECTION_SIZE ^ 3

	local buf = chunkBuffer.create12BitBuffer(size)

	local bitNumberPerBlock = calculateBitsFromPaletteLenght(#compressedSection.palette + 1)

	local encodedBufN = bitBuffer.createNBitBuffer(bitNumberPerBlock, size)

	local pointer = 0

	while pointer < size do
		local id = bitBuffer.ReadNBit(encodedBufN, pointer)

		if id ~= 0 then
			chunkBuffer.encode12BitAtIndex(buf, id, pointer)
		end

		pointer += 1
	end

	return {
		blockStates = buf,
		palette = compressedSection.palette,
		y = compressedSection.y,
		occurences = {},
	}
end

return {
	compressSection = compressSection,
	decompressSection = decompressSection,
}
