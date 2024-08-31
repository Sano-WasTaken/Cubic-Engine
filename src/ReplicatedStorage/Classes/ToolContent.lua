local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemContent = require(ReplicatedStorage.Classes.ItemContent)

local ToolContent = ItemContent.Class:extends({
	ClassName = "Tool",
	MaxStackSize = 1,
	Mesh = ReplicatedStorage.Meshes["Pickaxe/1"],
	Speed = 2,
})

export type ToolContent = typeof(ToolContent)

function ToolContent:Use(position: Vector3, _: Vector3)
	return { position }
end

return ToolContent :: typeof(ToolContent)
