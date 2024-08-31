local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local CoalOre = {
	Id = BlockEnum["Coal_Ore"],
	Textures = "rbxassetid://81133281928704",
	--Unbreakable = true,
}

CoalOre = BlockContent.Class:extends(CoalOre)

return CoalOre
