--!native
--!nonstrict

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local FacingTileEntity = require(ServerStorage.Classes.FacingTileEntity)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)
--local CustomStats = require(ReplicatedStorage.Utils.CustomStats)

--// Block folder
local renderFolder = Instance.new("Folder")
renderFolder.Name = "RenderFolder"
renderFolder.Parent = workspace

--// Constants
local BLOCK_SIZE = 3
--local TEXTURE_PADDING = (BLOCK_SIZE / 128)

local map = {} :: { { { Part } } }

local faces = {
	[Vector3.new(0, 1, 0)] = Enum.NormalId.Top,
	[Vector3.new(0, -1, 0)] = Enum.NormalId.Bottom,
	[Vector3.new(0, 0, -1)] = Enum.NormalId.Front,
	[Vector3.new(0, 0, 1)] = Enum.NormalId.Back,
	[Vector3.new(1, 0, 0)] = Enum.NormalId.Right,
	[Vector3.new(-1, 0, 0)] = Enum.NormalId.Left,
} :: { [Vector3]: Enum.NormalId }

--// Functions micro optimisation
local cfnew = CFrame.new
local inew = Instance.new
local cfanew = CFrame.Angles

--// Functions
local function getPartOrientation(facing: FacingTileEntity.Facing): CFrame
	local CF: CFrame?

	if facing == "NORTH" then
		CF = cfanew(0, 0, 0)
	elseif facing == "EAST" then
		CF = cfanew(0, math.pi / 2, 0)
	elseif facing == "SOUTH" then
		CF = cfanew(0, math.pi, 0)
	elseif facing == "WEST" then
		CF = cfanew(0, (3 * math.pi) / 2, 0)
	end

	return (CF or cfanew(0, 0, 0))
end

local function createBlock(id: number): Part?
	local blockData = BlockDataProvider:GetData(id)

	print(id, blockData)

	if blockData == nil then
		return
	end

	local part = blockData:GetMeshClone()

	part.Material = blockData.Material or Enum.Material.Plastic
	part.Color = blockData.Color or Color3.new(1, 1, 1)

	return part
end

local epsilon = 0.00001

local function createTexture(id: number, oldface: Enum.NormalId, facing: FacingTileEntity.Facing): Texture?
	local texture = inew("Texture")
	local blockData = BlockDataProvider:GetData(id)

	if blockData.Textures == nil or blockData.Textures == "" then
		return
	end

	local faceVector = getPartOrientation(facing):VectorToWorldSpace(Vector3.FromNormalId(oldface))

	faceVector = (faceVector + Vector3.one * epsilon):Floor()

	local face = faces[faceVector]

	print(face, oldface, faceVector, facing)

	--
	texture.Texture = (type(blockData.Textures) == "string") and blockData.Textures
		or (blockData.Textures :: {})[face.Name]

	texture.Face = face
	texture.StudsPerTileU = BLOCK_SIZE
	texture.StudsPerTileV = BLOCK_SIZE
	texture.ZIndex = -1

	texture.Name = oldface.Name

	return texture
end

local function findBlock(x: number, y: number, z: number): Part?
	if map[x] and map[x][y] and map[x][y][z] then
		return map[x][y][z]
	end

	return nil
end

local function setBlock(x: number, y: number, z: number, part: Part?)
	map[x] = map[x] or {}
	map[x][y] = map[x][y] or {}

	map[x][y][z] = part
end

local function destroyBlock(x: number, y: number, z: number)
	local part = findBlock(x, y, z)

	if part then
		part:Destroy()
		setBlock(x, y, z, nil)
		return true
	end

	return false
end

local function appendBlock(block: WorldManager.Block)
	local x, y, z = block:GetPosition()
	--local rx, ry, rz = block:GetOrientation()
	local id = block:GetID()

	if id == 0 then
		return
	end

	local angle = getPartOrientation(block:GetFacing())

	local neighbors = WorldManager:GetNeighbors(x, y, z)

	-- Block cull
	if neighbors.Size == 6 then
		--destroyNeighborsBlocks(x, y, z)
		for _, normalId: Enum.NormalId in Enum.NormalId:GetEnumItems() do
			local direction = Vector3.FromNormalId(normalId)

			local neighbor = neighbors[direction]

			if neighbor then
				local nx, ny, nz = neighbor:GetPosition()

				local nn = WorldManager:GetNeighbors(nx, ny, nz).Size

				if nn == 6 then
					destroyBlock(nx, ny, nz)
				end
			end
		end

		return
	end

	local part = createBlock(id)

	part.CFrame = cfnew(Vector3.new(x, y, z) * 3) * angle
	part.Parent = renderFolder

	setBlock(x, y, z, part)

	for _, normalId: Enum.NormalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = neighbors[direction]

		if neighbor then
			local nx, ny, nz = neighbor:GetPosition()

			local nn = WorldManager:GetNeighbors(nx, ny, nz).Size

			local npart = findBlock(nx, ny, nz)

			if npart then
				if nn ~= 6 then
					local texture = npart:FindFirstChild(faces[-direction].Name)

					if texture then
						texture:Destroy()
					end
				else
					destroyBlock(nx, ny, nz)
				end
			end
		end

		if neighbor == nil then
			local texture = createTexture(id, normalId, block:GetFacing())

			if texture then
				texture.Parent = part
			end
		end
	end

	--[[for _, normalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = WorldManager:GetNeighbor(x, y, z, direction)

		if neighbor then
			local nx, ny, nz = neighbor:GetPosition()

			local npart = findBlock(nx, ny, nz)

			if npart then
				local texture = npart:FindFirstChild(faces[-direction].Name)

				if texture then
					texture:Destroy()
				end
			end
		end

		if neighbor == nil then
			local texture = createTexture(id, normalId)

			if texture then
				texture.Parent = part
			end
		end
	end]]
end

local function deleteBlock(block: WorldManager.Block)
	local x, y, z = block:GetPosition()

	destroyBlock(x, y, z)

	for _, normalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = WorldManager:GetNeighbor(x, y, z, direction)

		if neighbor then
			local nx, ny, nz = neighbor:GetPosition()
			local id = neighbor:GetID()
			local oppositeFace = faces[-direction]

			local npart = findBlock(nx, ny, nz) or createBlock(neighbor:GetID())

			if npart.Parent == nil then
				npart.CFrame = cfnew(Vector3.new(nx, ny, nz) * 3) -- * cfanew(rx, ry, rz)
				npart.Parent = renderFolder
				setBlock(nx, ny, nz, npart)
			end

			if npart then
				local texture = npart:FindFirstChild(oppositeFace.Name)
					or createTexture(id, oppositeFace, neighbor:GetFacing())

				if texture then
					texture.Parent = npart
				end
			end
		end
	end
end

return {
	appendBlock = appendBlock,
	deleteBlock = deleteBlock,
	findBlock = findBlock,
	setBlock = setBlock,
	destroyBlock = destroyBlock,
	createBlock = createBlock,
	createTexture = createTexture,
	getPartOrientation = getPartOrientation,
}
