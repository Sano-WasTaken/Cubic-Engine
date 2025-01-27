local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToolContent = require(ReplicatedStorage.Classes.ToolContent)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local TestPickaxe = ToolContent:extends({
	Id = ItemEnum["Test_Pickaxe"],
	Speed = 1,
}) :: typeof(ToolContent)

return TestPickaxe
