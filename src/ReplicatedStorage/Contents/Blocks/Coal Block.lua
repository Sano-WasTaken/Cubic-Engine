local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Coal_Block",
	InstanceProperties = {
		Textures = "rbxassetid://96135913340962",
	},
})
