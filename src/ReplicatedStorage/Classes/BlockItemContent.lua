local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemContent = require(ReplicatedStorage.Classes.ItemContent)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local BlockItemContent = ItemContent.Class:extends({
	ClassName = "BlockItem",
	--Mesh = Instance.new("Part"),
})

export type BlockItemContent =
	typeof(BlockItemContent)
	& { extends: (self: BlockItemContent, class: {}) -> BlockItemContent }

function BlockItemContent:Use(position: Vector3, normalVec: Vector3)
	return position + normalVec
end

function BlockItemContent:GetClonedMesh(): Part
	local block = self:GetBlock()

	local clone: Part = block:GetMeshClone()

	clone.Anchored = false
	clone.Position = Vector3.zero

	local textures = block:GetTexture()

	if textures == "" then
		return clone
	end

	for _, normalId in Enum.NormalId:GetEnumItems() do
		local texture = Instance.new("Texture")

		texture.Face = normalId
		texture.Texture = typeof(textures) == "table" and textures[normalId.Name] or textures
		texture.StudsPerTileU = 3
		texture.StudsPerTileV = 3

		texture.Parent = clone
	end

	return clone
end

function BlockItemContent:GetBlock()
	return BlockDataProvider:GetData(BlockEnum[ItemEnum[self:GetID()]])
end

return BlockItemContent :: BlockItemContent
