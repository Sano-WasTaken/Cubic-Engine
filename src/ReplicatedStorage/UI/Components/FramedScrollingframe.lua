local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

return function(props: {
	Size: UDim2,
})
	return Roact.createElement("ScrollingFrame", {
		Size = props.Size,
		BackgroundColor3 = Color3.fromHex("151515"),
		BackgroundTransparency = 0.7,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,
			Color = Color3.fromHex("FFFFFF"),
		}),
	})
end
