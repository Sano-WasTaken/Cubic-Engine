local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local GoldOre = {
	Id = BlockEnum["Gold_Ore"],
	Textures = "rbxassetid://123701517700194",
	--Unbreakable = true,
}

GoldOre = BlockContent.Class:extends(GoldOre)

return GoldOre
