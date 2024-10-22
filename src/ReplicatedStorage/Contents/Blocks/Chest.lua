local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

local chest = Block:declareNewBlockClass({
	ClassName = "Chest",
	SavedProperties = { facing = true },
	OtherProperties = { Culled = false },
	InstanceProperties = {
		Transparency = 1,
		Mesh = ReplicatedStorage.Meshes["Chest"],
		NoTexture = true,
	},
})

return chest
