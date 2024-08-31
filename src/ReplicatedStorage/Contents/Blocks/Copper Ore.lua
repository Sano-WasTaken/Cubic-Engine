local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local CopperOre = {
	Id = BlockEnum["Copper_Ore"],
	Textures = "rbxassetid://91781035501209",
	--Unbreakable = true,
}

CopperOre = BlockContent.Class:extends(CopperOre)

return CopperOre
