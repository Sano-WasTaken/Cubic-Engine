local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

return BlockContent.Class:extends({
	Id = BlockEnum["Chest"],
	Textures = {
		Top = "rbxassetid://110625559796607",
		Bottom = "rbxassetid://110625559796607",
		Front = "rbxassetid://122678938631292",
		Back = "rbxassetid://110625559796607",
		Right = "rbxassetid://110625559796607",
		Left = "rbxassetid://110625559796607",
	}, -- "rbxassetid://122678938631292"
})
