local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Copper_Ore",
	InstanceProperties = {
		Textures = "rbxassetid://91781035501209",
	},
})
