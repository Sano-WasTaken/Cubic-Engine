local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

return BlockContent.Class:extends({
	Id = BlockEnum["Coal_Block"],
	Textures = "rbxassetid://96135913340962",
})
