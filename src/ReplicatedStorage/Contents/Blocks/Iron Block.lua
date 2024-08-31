local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

return BlockContent.Class:extends({
	Id = BlockEnum["Iron_Block"],
	Textures = "rbxassetid://113133991479587",
})
