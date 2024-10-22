local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

return BlockContent.Class:extends({
	Id = BlockEnum.Glass,
	Textures = "",
	Transparency = 0.7,
	Color = Color3.fromRGB(209, 233, 255),
	Material = Enum.Material.Glass,
	Culled = false,
})
