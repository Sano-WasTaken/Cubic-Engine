local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(props: {
	Size: Vector2,
	Text: string,
	Position: UDim2?,
	AnchoredPoint: Vector2?,
})
	return Roact.createElement("TextLabel", {
		BackgroundColor3 = Color3.fromHex("151515"),
		AnchorPoint = props.AnchoredPoint,
		Position = props.Position,
		BackgroundTransparency = 0.7,
		TextColor3 = Color3.fromHex("FFFFFF"),
		Font = Enum.Font.Gotham,
		FontSize = Enum.FontSize.Size32,
		Text = props.Text,
		Size = UDim2.fromOffset(props.Size.X, props.Size.Y),
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 1,
			Color = Color3.fromHex("FFFFFF"),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
end
