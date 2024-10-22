local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "SandStone",
	InstanceProperties = {
		Textures = "rbxassetid://113133991479587",
	},
})
