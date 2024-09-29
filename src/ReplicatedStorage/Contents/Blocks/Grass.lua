local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local Grass = {
	Id = BlockEnum.Grass,
	Textures = {
		Top = "rbxassetid://18945124745",
		Bottom = "rbxassetid://18945125137",
		Front = "rbxassetid://18945124943",
		Back = "rbxassetid://18945124943",
		Right = "rbxassetid://18945124943",
		Left = "rbxassetid://18945124943",
	},
}

Grass = BlockContent.Class:extends(Grass)

return Grass
