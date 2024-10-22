local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Coal_Ore",
	InstanceProperties = {
		Textures = "rbxassetid://81133281928704",
	},
})
