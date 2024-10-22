local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

return BlockContent.Class:extends({
	Id = BlockEnum.Stone_Stairs,
	Culled = false,
	Faced = true,
	Inverted = true,
	Mesh = ReplicatedStorage.Meshes["Stairs"],
	Textures = "rbxassetid://18640418536",
})
