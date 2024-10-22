local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "SandStone",
	InstanceProperties = {
		Textures = {
			Top = "rbxassetid://18945124745",
			Bottom = "rbxassetid://18945125137",
			Front = "rbxassetid://18945124943",
			Back = "rbxassetid://18945124943",
			Right = "rbxassetid://18945124943",
			Left = "rbxassetid://18945124943",
		},
	},
})
