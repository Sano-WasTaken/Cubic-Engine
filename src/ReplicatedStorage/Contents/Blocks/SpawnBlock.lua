local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Spawn_Block",
	InstanceProperties = { Textures = "rbxassetid://18724299526" },
	OtherProperties = {
		Unbreakable = true,
	},
})
