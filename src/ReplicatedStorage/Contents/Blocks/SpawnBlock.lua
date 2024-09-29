local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local SpawnBlock = {
	Id = BlockEnum.SpawnBlock,
	Textures = "rbxassetid://18724299526",
	Unbreakable = true,
}

SpawnBlock = BlockContent.Class:extends(SpawnBlock)

return SpawnBlock
