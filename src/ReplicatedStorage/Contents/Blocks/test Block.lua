local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local class: BlockContent.CanvasBlock = {
	Id = BlockEnum["Test_Block"],
	Textures = "",
	Color = Color3.fromRGB(255, 77, 0),
	Material = Enum.Material.Neon,
}

return BlockContent.Class:extends(class)
