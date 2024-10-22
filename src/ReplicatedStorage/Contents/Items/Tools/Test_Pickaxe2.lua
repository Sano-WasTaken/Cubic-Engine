local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolContent = require(ReplicatedStorage.Classes.ToolContent)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local TestPickaxe = ToolContent:extends({
	Id = ItemEnum["God_Pickaxe"],
	Speed = 0,
	Mesh = ReplicatedStorage.Meshes["TestPickaxe"],
}) :: typeof(ToolContent)

return TestPickaxe
