local HttpService = game:GetService("HttpService")

local ChunkUtils = require(script.Parent.ChunkUtils)

local function isBlockDataIsInPalette(
	palette: { ChunkUtils.BlockData },
	blockData: ChunkUtils.BlockData
): (boolean, number)
	for id, data in palette do
		if HttpService:JSONEncode(data) == HttpService:JSONEncode(blockData) then
			return true, id
		end
	end

	return false, -1
end

local function getPaletteLenght(palette: { ChunkUtils.BlockData }): number
	return #palette + 1
end

local function getBlockDataFromId(palette: { ChunkUtils.BlockData }, id: number): ChunkUtils.BlockData
	return palette[id] or { name = "air" }
end

local function getBitsPerBlock(palette: { ChunkUtils.BlockData }): number
	local paletteNumber = getPaletteLenght(palette)

	return math.ceil(math.log(paletteNumber) / math.log(2))
end

local function removeBlockDataInPalette(palette: { ChunkUtils.BlockData }, blockData: ChunkUtils.BlockData | number)
	if typeof(blockData) == "number" then
		palette[blockData] = nil
	else
		for id, data in palette do
			if HttpService:JSONEncode(data) == HttpService:JSONEncode(blockData) then
				palette[id] = nil
				break
			end
		end
	end
end



return {
	removeBlockDataInPalette = removeBlockDataInPalette,
	isBlockDataIsInPalette = isBlockDataIsInPalette,
	getBlockDataFromId = getBlockDataFromId,
	getPaletteLenght = getPaletteLenght,
	getBitsPerBlock = getBitsPerBlock,
}
