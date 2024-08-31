local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local Stone = {
	Id = BlockEnum.SandStone,
	Textures = "rbxassetid://104604743278485",
	--Unbreakable = true,
}

Stone = BlockContent.Class:extends(Stone)

return Stone
