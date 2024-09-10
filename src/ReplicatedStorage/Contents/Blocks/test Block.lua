local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local class: BlockContent.CanvasBlock = {
	Id = BlockEnum["Oak_Log"],
	Textures = {
		Top = "rbxassetid://94405399115678",
		Back = "rbxassetid://103530721217139",
		Bottom = "rbxassetid://94405399115678",
		Front = "rbxassetid://103530721217139",
		Right = "rbxassetid://103530721217139",
		Left = "rbxassetid://103530721217139",
	},
}

return BlockContent.Class:extends(class)
