local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local Stone = {
	Id = BlockEnum.Stone,
	Textures = "rbxassetid://18640418536",
}

Stone = BlockContent.Class:extends(Stone)

return Stone
