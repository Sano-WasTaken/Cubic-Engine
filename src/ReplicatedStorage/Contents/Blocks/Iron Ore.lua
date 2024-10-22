local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Iron_Ore",
	InstanceProperties = {
		Textures = "rbxassetid://127906439071043",
	},
})
