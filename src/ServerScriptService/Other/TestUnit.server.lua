local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BlockData = require(ReplicatedStorage.Classes.BlockData)
local Waiter = require(ReplicatedStorage.Classes.Waiter)
local ChunkV2 = require(ServerStorage.Classes.ChunkV2)
local ChunkUtils = require(ServerStorage.Classes.ChunkV2.ChunkUtils)

local blockData = BlockData.newBlockData(1, "stone")

blockData
	:CreateVariant(BlockData.newVariant("andesite"))
	:CreateVariant(BlockData.newVariant("diorite"))
	:CreateVariant(BlockData.newVariant("granite"))
	:CreateVariant(BlockData.newVariant("bedrock"))
	:CreateVariant(BlockData.newVariant("red_stone"))
	:CreateVariant(BlockData.newVariant("green_stone"))

local airVariants = BlockData.newBlockData(2, "air")

airVariants:CreateVariant(BlockData.newVariant("generated"))

--local c = ChunkV2.new(0, 0)

--c:SetBlockInChunk(0, 50, 0, { name = blockData:GetPSIDFromVNID(1) })
--c:SetBlockInChunk(0, 51, 0, { name = blockData:GetPSIDFromVNID(2) })
--c:SetBlockInChunk(0, 55, 0, { name = blockData:GetPSIDFromVNID(3) })
--c:SetBlockInChunk(0, 55, 5, { name = blockData:GetPSIDFromVNID(3) })

local size = 16 * 16 * 256

local colors = {
	[blockData:GetPSIDFromVNID(1)] = Color3.fromRGB(111, 111, 111),
	[blockData:GetPSIDFromVNID(2)] = Color3.fromRGB(204, 204, 204),
	[blockData:GetPSIDFromVNID(3)] = Color3.fromRGB(255, 114, 68),
	[blockData:GetPSIDFromVNID(4)] = Color3.fromRGB(14, 14, 14),
	[blockData:GetPSIDFromVNID(5)] = Color3.fromRGB(233, 30, 30),
	[blockData:GetPSIDFromVNID(6)] = Color3.fromRGB(24, 243, 16),
}

local renderFolder = Instance.new("Folder", workspace)

local function createPart(x: number, y: number, z: number, name: string)
	local part = Instance.new("Part")

	part.Size = Vector3.one * 3
	part.Position = Vector3.new(x, y, z) * 3
	part.Name = name
	part.Anchored = true
	part.Color = colors[name]
	part.Parent = renderFolder

	return part
end

local freq = 0.1
local amp = 0.005

local chunks = {}

local function getNbOfNeighbor(x: number, y: number, z: number)
	local position = Vector3.new(x, y, z)

	local n = 0

	for _, normal in Enum.NormalId:GetEnumItems() do
		normal = Vector3.FromNormalId(normal)

		local pos = position + normal

		local bicPos = ChunkUtils.getChunkPositionFromBlockPosition(pos.X, pos.Z)

		chunks[bicPos.X] = chunks[bicPos.X] or {}

		local c = chunks[bicPos.X][bicPos.Y] :: ChunkV2.ChunkInterface

		if c then
			local nx, ny, nz = pos.X - (bicPos.X * 16), pos.Y, pos.Z - (bicPos.Y * 16)

			local block = c:GetBlockDataAtChunkPosition(nx, ny, nz)

			if block.name ~= "air" and block.name ~= "air:generated" then
				n += 1
			end
		end
	end

	return n
end

local function render()
	local waiter = Waiter.new()

	waiter:SetExecutionDivider(3)

	for cx, rows in chunks do
		for cy, c in rows do
			local pointer = 0
			while pointer < size do
				local x, y, z = ChunkUtils.getBlockPositionInChunkFromPointer(pointer)

				local block = c:GetBlockDataAtChunkPosition(x, y, z)

				x, z = x + (cx * 16), z + (cy * 16)

				if (block.name ~= "air" and block.name ~= "air:generated") and getNbOfNeighbor(x, y, z) ~= 6 then
					createPart(x, y, z, block.name)
				end

				waiter:Update()

				pointer += 1
			end
		end
	end
end

local function generate(c: ChunkV2.ChunkInterface)
	local waiter = Waiter.new()

	local pointer = 0

	local cx, cy = c.chunk.x, c.chunk.y

	chunks[cx] = chunks[cx] or {}

	chunks[cx][cy] = c

	waiter:SetExecutionDivider(3)

	while pointer < size do
		local x, y, z = ChunkUtils.getBlockPositionInChunkFromPointer(pointer)

		x, z = x + (cx * 16), z + (cy * 16)

		local noiseThreeD = (math.noise(x * freq, y * freq, z * freq))
		local noiseTwoD = (math.noise(x / 8, z / 8) * 0.025) + 90

		local mapped = noiseThreeD <= 0.2

		local id = 0

		if y == 0 then
			id = 4
		elseif mapped and y < math.floor(noiseTwoD) then
			local rockNoise = math.noise(x / 5, y / 5, z / 5) * 9

			if math.noise(rockNoise) == 0 then
				id = 2
			else
				id = 3
			end
			-- math.random(1, 6)
		elseif mapped and y == math.floor(noiseTwoD) then
			id = 6
		end

		if id ~= 0 then
			c:SetBlockInChunk(x, y, z, { name = blockData:GetPSIDFromVNID(id) })
		else
			c:SetBlockInChunk(x, y, z, { name = airVariants:GetPSIDFromVNID(1) })
		end

		waiter:Update()

		pointer += 1
	end
end

generate(ChunkV2.new(0, 0))

local c = chunks[0][0]

print(c)

print(HttpService:JSONEncode(c):len())

local compressed = c:Compress()

print(buffer.len(compressed))
