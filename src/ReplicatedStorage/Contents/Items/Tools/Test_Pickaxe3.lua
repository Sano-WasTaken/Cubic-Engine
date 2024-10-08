local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolContent = require(ReplicatedStorage.Classes.ToolContent)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local tool = ToolContent:extends({
	Id = ItemEnum["Crystal_Pickaxe"],
	Mesh = ReplicatedStorage.Meshes["Pickaxe/2"],
	Speed = 0.25,
})

return tool
