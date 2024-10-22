local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemContent = require(ReplicatedStorage.Classes.ItemContent)

local ToolContent = ItemContent.Class:extends({
	ClassName = "Tool",
	MaxStackSize = 1,
	Mesh = ReplicatedStorage.Meshes["Pickaxe/1"],
	Speed = 2,
	Range = 7,
})

export type ToolContent = typeof(ToolContent)

function ToolContent.GetClonedMesh(self: ToolContent): BasePart
	local mesh = self.Mesh:Clone()

	for _, part in mesh:GetChildren() do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end

	return mesh
end

function ToolContent:GetRange(): number
	return self.Range
end

function ToolContent:Use(position: Vector3, _: Vector3)
	return { position }
end

return ToolContent :: typeof(ToolContent)
