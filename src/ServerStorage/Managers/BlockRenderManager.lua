--!native

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local WorldManager = require(ServerStorage.Managers.WorldManager)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)
local CustomStats = require(ReplicatedStorage.Utils.CustomStats)

--// Block folder
local renderFolder = Instance.new("Folder")
renderFolder.Name = "RenderFolder"
renderFolder.Parent = workspace

--// Constants
local BLOCK_SIZE = 3
local map = {} :: { { { Part } } }

local faces = {
	[Vector3.new(0, 1, 0)] = Enum.NormalId.Top,
	[Vector3.new(0, -1, 0)] = Enum.NormalId.Bottom,
	[Vector3.new(0, 0, -1)] = Enum.NormalId.Front,
	[Vector3.new(0, 0, 1)] = Enum.NormalId.Back,
	[Vector3.new(1, 0, 0)] = Enum.NormalId.Right,
	[Vector3.new(-1, 0, 0)] = Enum.NormalId.Left,
} :: { [Vector3]: Enum.NormalId }

--// The cloned Part
local model = Instance.new("Part")
model.Anchored = true
model.Size = Vector3.one * BLOCK_SIZE
model.Material = Enum.Material.SmoothPlastic

--// Functions micro optimisation
local cfnew = CFrame.new
local inew = Instance.new
local cfanew = CFrame.Angles

--// Functions
local function createBlock(id: number): Part
	local blockData = BlockDataProvider:GetData(id)

	if blockData == nil then
		return
	end

	local customProps = blockData.CustomProperties

	local part = (customProps and customProps.Mesh ~= nil) and customProps.Mesh:Clone() or model:Clone()

	if customProps then
		-- if customProps.Size then end --TODO: calculous for the size
		part.Material = customProps.Material or Enum.Material.Plastic
		part.Color = customProps.Color3 or Color3.new(1, 1, 1)
		part.Transparency = customProps.Transparency or part.Transparency
	end

	return part
end

local function createTexture(id: number, face: Enum.NormalId?): Texture?
	local texture = inew("Texture")
	local blockData = BlockDataProvider:GetData(id)

	if blockData.Textures == nil then
		return
	end

	texture.Texture = (type(blockData.Textures) == "string") and blockData.Textures or blockData.Textures[face.Name]

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
end

local function setBlock(x: number, y: number, z: number, part: Part)
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
	local rx, ry, rz = block:GetOrientation()
	local id = block:GetID()
	if id == 0 then
		return
	end

	local part = createBlock(id)

	part.CFrame = cfnew(Vector3.new(x, y, z) * 3) * cfanew(rx, ry, rz)
	part.Parent = renderFolder

	setBlock(x, y, z, part)

	for _, normalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = WorldManager.getNeighbor(x, y, z, direction)

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
	end
end

local function deleteBlock(block: WorldManager.Block)
	local x, y, z = block:GetPosition()

	destroyBlock(x, y, z)

	for _, normalId in Enum.NormalId:GetEnumItems() do
		local direction = Vector3.FromNormalId(normalId)

		local neighbor = WorldManager.getNeighbor(x, y, z, direction)

		if neighbor then
			local nx, ny, nz = neighbor:GetPosition()
			local id = neighbor:GetID()
			local oppositeFace = faces[-direction]

			local npart = findBlock(nx, ny, nz)

			local texture = npart:FindFirstChild(oppositeFace.Name) or createTexture(id, oppositeFace)

			if texture then
				texture.Parent = npart
			end
		end
	end
end

function updateStat()
	CustomStats:UpdateStat("BlockRendered", #renderFolder:GetChildren())
end

renderFolder.ChildAdded:Connect(updateStat)
renderFolder.ChildRemoved:Connect(updateStat)

return {
	appendBlock = appendBlock,
	deleteBlock = deleteBlock,
	findBlock = findBlock,
}
