--!native
--!nonstrict

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local Block = require(ServerStorage.Classes.Block)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)

--// Block folder
local renderFolder = Instance.new("Folder")
renderFolder.Name = "RenderFolder"
renderFolder.Parent = workspace

--// Constants
local BLOCK_SIZE = 3

local map = {} :: { { { Part } } }

--[[local faces = {
	[Vector3.new(0, 1, 0)] = Enum.NormalId.Top,
	[Vector3.new(0, -1, 0)] = Enum.NormalId.Bottom,
	[Vector3.new(0, 0, -1)] = Enum.NormalId.Front,
	[Vector3.new(0, 0, 1)] = Enum.NormalId.Back,
	[Vector3.new(1, 0, 0)] = Enum.NormalId.Right,
	[Vector3.new(-1, 0, 0)] = Enum.NormalId.Left,
} :: { [Vector3]: Enum.NormalId }]]

--// Functions micro optimisation
local cfnew = CFrame.new
local inew = Instance.new
local cfanew = CFrame.Angles

--// Functions
local function getPartOrientation(facing: Block.Facing, inverted: boolean): CFrame
	local x, y, z = 0, 0, 0

	if facing == "EAST" then
		y = math.pi / 2
	elseif facing == "SOUTH" then
		y = math.pi
	elseif facing == "WEST" then
		y = (3 * math.pi) / 2
	end

	if inverted then
		if y % math.pi == 0 then
			z = math.pi
		else
			x = math.pi
		end
	end

	return cfanew(x, y, z)
end

local function createBlock(id: number): Part?
	local blockData = BlockDataProvider:GetData(id)

	if blockData == nil then
		print(id, blockData)
	end

	if blockData == nil then
		return
	end

	local part = blockData:GetMeshClone()

	--part.Transparency = blockData.Transparency
	--part.Material = blockData.Material or Enum.Material.Plastic
	--part.Color = blockData.Color or Color3.new(1, 1, 1)

	return part
end

local function createTexture(id: number, face: Enum.NormalId): Texture?
	local texture = inew("Texture")
	local blockData = BlockDataProvider:GetData(id)

	if blockData.Textures == nil or blockData.Textures == "" then
		return
	end

	texture.Texture = (type(blockData.Textures) == "string") and blockData.Textures
		or (blockData.Textures :: {})[face.Name]

	texture.Face = face
	texture.StudsPerTileU = BLOCK_SIZE
	texture.StudsPerTileV = BLOCK_SIZE
	texture.ZIndex = -1

	texture.Name = face.Name

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

local function isNeighborsCulled(neighbors): boolean
	for _, normalId: Enum.NormalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor: Block.IBlock? = neighbors[direction]

		if neighbor then
			local content = neighbor:GetContent()

			if content == nil then
				return false
			end

			local isCulled = content:IsCulled()

			if not isCulled then
				return false
			end
		end
	end

	return true
end

local function appendBlock(block: WorldManager.Block)
	local x, y, z = block:GetPosition()
	local id = block:GetID()
	local content = block:GetContent()

	if id == 0 or content == nil then
		return
	end

	local isCulled = content:IsCulled()

	local angle = getPartOrientation(block:GetFacing(), block:GetInverted())

	local neighbors = WorldManager:GetNeighbors(x, y, z)

	if neighbors.Size == 6 and isCulled then
		for _, normalId: Enum.NormalId in Enum.NormalId:GetEnumItems() do
			local direction = Vector3.FromNormalId(normalId)

			local neighbor = neighbors[direction]

			if neighbor then
				local ncontent = neighbor:GetContent()
				local nx, ny, nz = neighbor:GetPosition()

				local nn = WorldManager:GetNeighbors(nx, ny, nz)

				if nn.Size == 6 and ncontent:IsCulled() and isCulled and isNeighborsCulled(neighbors) then
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

		local texture = createTexture(id, normalId)

		if texture then
			texture.Parent = part
		end

		local neighbor = neighbors[direction]

		if neighbor then
			local nx, ny, nz = neighbor:GetPosition()

			local nn = WorldManager:GetNeighbors(nx, ny, nz)

			local npart = findBlock(nx, ny, nz)

			local ncontent = neighbor:GetContent()

			if
				npart
				and nn.Size == 6
				and isCulled
				and ncontent ~= nil
				and ncontent:IsCulled()
				and isNeighborsCulled(nn)
			then
				print(isCulled, ncontent:IsCulled(), isNeighborsCulled(neighbors))
				destroyBlock(nx, ny, nz)
			end
		end
	end
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

			local npart = findBlock(nx, ny, nz) or createBlock(neighbor:GetID())

			if npart and npart.Parent == nil then
				npart.CFrame = cfnew(Vector3.new(nx, ny, nz) * 3) * getPartOrientation(neighbor:GetFacing())
				npart.Parent = renderFolder
				setBlock(nx, ny, nz, npart)
			end

			if npart then
				for _, nface in Enum.NormalId:GetEnumItems() do
					local texture = npart:FindFirstChild(nface.Name) or createTexture(id, nface)

					if texture then
						texture.Parent = npart
					end
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
	isNeighborsCulled = isNeighborsCulled,
}
