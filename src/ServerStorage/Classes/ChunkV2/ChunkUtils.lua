local AnalyticsService = game:GetService("AnalyticsService")
local ProcessInstancePhysicsService = game:GetService("ProcessInstancePhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)

local chunkBuffer = BufferManager.chunkBuffer

export type BlockData = {
	name: string,
	properties: {
		[string]: any, -- UTF-8 ONLY !
	}?,
}

export type Section = {
	y: number,
	palette: { BlockData },
	occurences: { number },
	blockStates: buffer,
}

export type Chunk = {
	x: number,
	y: number,
	sections: { Section },
	tileEntities: { any },
}

local SECTION_SIZE = 16
local MAX_HEIGHT = 256
local CHUNK_SIZE = Vector3.new(SECTION_SIZE, MAX_HEIGHT, SECTION_SIZE)

--[[
CREATE BLOCK FOR INSERTING IT IN THE PALETTE

@param name string
@param properties { [string]: any } | nil (MUST BE UTF-8 VALID)

@return BlockData
]]
local function createBlockData(name: string, properties: { [string]: any }?): BlockData
	return {
		name = name,
		properties = properties,
	}
end

--[[
CREATE CHUNK FROM CHUNK 2D POSITION WITHOUT DATA

@param cx number
@param cy number

@return Chunk
]]
local function createChunk(cx: number, cy: number): Chunk
	return {
		x = cx,
		y = cy,
		sections = {},
		tileEntities = {},
	}
end

--[[
CREATE SECTION FROM SECTION Y VALUE

@param sy number

@return Section
]]
local function createSection(sy: number): Section
	return {
		y = sy,
		palette = {}, -- ARRAY of Block & States that provide unique ID for the buffer (limit of unique Block in is 16 ^ 3 thats why i use 12 bits for one chunk)
		occurences = {},
		blockStates = chunkBuffer.create12BitBuffer(SECTION_SIZE ^ 3),
	}
end

--[[
GET SECTION HEIGHT FROM BLOCK HEIGHT

@param by number

@return section height
]]
local function getSectionHeightFromBlockHeight(by: number): number
	return (by // 16)
end

--[[
GET CHUNK 2D POSITION FROM BLOCK

@param bx number
@param bz number

@return chunk position
]]
local function getChunkPositionFromBlockPosition(bx: number, bz: number): Vector2
	local cx, cy = (bx // SECTION_SIZE), (bz // SECTION_SIZE)

	return Vector2.new(cx, cy)
end

--[[
GET THE BLOCK CHUNK AND SECTION

@param bx number
@param by number
@param bz number

@return Sector 3D Position
- x: CHUNK_POS_X
- y: SECTION_IN_CHUNK_Y
- z: CHUNK_POS_Y
]]
local function getBlockLocactionFromWorldPosition(bx: number, by: number, bz: number): Vector3
	local sy = getSectionHeightFromBlockHeight(by)
	local cx, cy = getChunkPositionFromBlockPosition(bx, bz)

	return Vector3.new(cx, sy, cy)
end

--[[
GET POINTER FOR BLOCK BUFFER FROM THE BLOCK POSITION IN CHUNK

@param bx number
@param by number
@param bz number

@return pointer (number)
]]
local function getPointerFromBlockPositionInChunk(bx: number, by: number, bz: number): number
	local pointer = bx + bz * SECTION_SIZE + by * (SECTION_SIZE * SECTION_SIZE)

	return pointer
end

local function getBlockPositionInChunkFromPointer(pointer)
	local bz = (pointer // SECTION_SIZE) % SECTION_SIZE
	local by = pointer // (SECTION_SIZE * SECTION_SIZE)
	local bx = pointer % SECTION_SIZE

	return bx, by, bz
end

--[[
GET BLOCK POSITION IN WORLD (NOT IN CHUNK)

@param bx number
@param by number
@param bz number

@return block position in world (Vector3)
]]
local function getBlockPositionInChunk(x: number, y: number, z: number): Vector3
	local chunkPos = getChunkPositionFromBlockPosition(x, z)
	local sy = getSectionHeightFromBlockHeight(y)

	return Vector3.new(x - SECTION_SIZE * chunkPos.X, y - SECTION_SIZE * sy, z - SECTION_SIZE * chunkPos.Y)
end

local function isBlockHeightOutOfChunk(by: number): boolean
	return by >= 0 and by < MAX_HEIGHT
end

local function isBlockIsInChunk(bx: number, bz: number, cx: number, cy: number): boolean
	local chunkPos = getChunkPositionFromBlockPosition(bx, bz)

	return chunkPos.X == cx and chunkPos.Y == cy
end

local function getBlockWorldPosition(bx: number, by: number, bz: number, cx: number, cy: number): Vector3
	return Vector3.new(bx + (cx * SECTION_SIZE), by, bz + (cy * SECTION_SIZE))
end

local function iterateThroughSection(callback: (pointer: number) -> boolean?)
	local size = SECTION_SIZE ^ 3

	local pointer = 0

	while pointer < size do
		local result = callback(pointer)

		if result == true then -- be sure it's true :<) <-- this is a smiley not a piece of pizza.
			break
		end

		pointer += 1
	end
end

local function getBlockOccurencesInSectionFromId(section: Section, id: number): number
	return section.occurences[id]
end

local function shiftSection(section: Section)
	assert(#section.occurences == #section.palette, "man wtf?")

	local palette = section.palette

	local blockStates = section.blockStates

	for i = 1, table.maxn(section.palette) do
		if palette[i] == nil then
			print("i need to shift", i, "at the", section.y .. "th section.")

			local pointer, size = 0, SECTION_SIZE ^ 3

			while pointer < size do
				local id = chunkBuffer.decode12BitAtIndex(blockStates, pointer)

				if id > i then
					chunkBuffer.encode12BitAtIndex(blockStates, id - 1, pointer)
				end

				pointer += 1
			end
		end
	end

	for i = 1, table.maxn(section.palette) do
		if palette[i] == nil then
			table.remove(section.occurences, i)
			table.remove(section.palette, i)
		end
	end
end

local function getBlockAmountInSection(section: Section): number
	local amount = 0

	for _, occurence in section.occurences do
		amount += occurence
	end

	return amount
end

return {
	createBlockData = createBlockData,
	createSection = createSection,
	createChunk = createChunk,

	getBlockLocactionFromWorldPosition = getBlockLocactionFromWorldPosition,
	getPointerFromBlockPositionInChunk = getPointerFromBlockPositionInChunk,
	getBlockPositionInChunkFromPointer = getBlockPositionInChunkFromPointer,
	getBlockOccurencesInSectionFromId = getBlockOccurencesInSectionFromId,
	getChunkPositionFromBlockPosition = getChunkPositionFromBlockPosition,
	getSectionHeightFromBlockHeight = getSectionHeightFromBlockHeight,
	getBlockPositionInChunk = getBlockPositionInChunk,
	getBlockAmountInSection = getBlockAmountInSection,
	getBlockWorldPosition = getBlockWorldPosition,

	isBlockHeightOutOfChunk = isBlockHeightOutOfChunk,
	isBlockIsInChunk = isBlockIsInChunk, -- POSITION

	shiftSection = shiftSection,
	--isBlockInSection = true,

	iterateThroughSection = iterateThroughSection,

	CHUNK_SIZE = CHUNK_SIZE,
	SECTION_SIZE = SECTION_SIZE,
}
