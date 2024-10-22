local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Gold_Ore",
	InstanceProperties = { Textures = "rbxassetid://123701517700194" },
})
