local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Stone_Stairs",
	SavedProperties = {
		facing = true,
		invert = true,
	},
	OtherProperties = {
		Culled = false,
	},
	InstanceProperties = {
		Mesh = ReplicatedStorage.Meshes["Stairs"],
		Textures = "rbxassetid://18640418536",
	},
})
