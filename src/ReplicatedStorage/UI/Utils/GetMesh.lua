local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local function CreateTextures(textures: any, parent: Instance)
	for _, normalId in Enum.NormalId:GetEnumItems() do
		local texture = Instance.new("Texture")

		texture.Parent = parent
		texture.StudsPerTileU = 3
		texture.StudsPerTileV = 3
		texture.Face = normalId
		texture.Texture = textures[normalId.Name] or textures
	end
end

local function GetMesh(name: string): (BasePart, Camera)
	local data = ItemDataProvider:GetData(BlockEnum[name])

	if data == nil then
		return --Instance.new("Part")
	end

	local blockData = data.BlockData

	local model = data.Mesh:Clone()
	local camera = Instance.new("Camera")

	model.Size = model:IsA("Part") and Vector3.one * 3 or model.Size
	model.Name = "Appearence"
	model.Position = Vector3.zero

	if blockData then
		if blockData.Textures then
			CreateTextures(blockData.Textures, model)
		end

		if blockData.CustomProperties then
			local customProps = blockData.CustomProperties

			model.Material = customProps.Material
			model.Color = customProps.Color3
		end
	end

	camera.CFrame = CFrame.lookAt(Vector3.new(1, 0.35, 1) * 3.5, Vector3.new(0, -0.1, 0))

	return model, camera
end

return GetMesh
