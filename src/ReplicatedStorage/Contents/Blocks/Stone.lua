local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Stone",
	InstanceProperties = {
		Textures = "rbxassetid://18640418536",
	},
})
