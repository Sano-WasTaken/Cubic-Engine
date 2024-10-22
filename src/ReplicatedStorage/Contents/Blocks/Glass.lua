local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Block = require(ReplicatedStorage.Classes.Block)

return Block:declareNewBlockClass({
	ClassName = "Glass",
	OtherProperties = {
		Culled = false,
	},
	InstanceProperties = {
		Textures = "rbxassetid://18640418536",
		Transparency = 0.7,
		Color = Color3.fromRGB(209, 233, 255),
		NoTexture = true,
		Material = Enum.Material.Glass,
	},
})
