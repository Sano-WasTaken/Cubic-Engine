local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local IronOre = {
	Id = BlockEnum["Iron_Ore"],
	Textures = "rbxassetid://127906439071043",
	--Unbreakable = true,
}

IronOre = BlockContent.Class:extends(IronOre)

return IronOre
