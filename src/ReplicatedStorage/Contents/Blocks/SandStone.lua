local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "SandStone",
	InstanceProperties = {
		Textures = "rbxassetid://104604743278485",
	},
})
