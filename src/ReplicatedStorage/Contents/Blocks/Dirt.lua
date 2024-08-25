local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local Dirt = {
	Id = BlockEnum.Dirt,
	Textures = "rbxassetid://18724462831",
}

Dirt = BlockContent.Class:extends(Dirt)

return Dirt
