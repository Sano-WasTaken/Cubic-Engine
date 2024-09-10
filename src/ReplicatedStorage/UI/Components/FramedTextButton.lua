local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(props: {
	Size: Vector2,
	Text: string,
	Position: UDim2?,
	AnchoredPoint: Vector2?,
	Activated: (rbx: TextButton, inputObject: InputObject, clickCount: number) -> nil,
})
	return Roact.createElement("TextButton", {
		BackgroundColor3 = Color3.fromHex("151515"),
		AnchorPoint = props.AnchoredPoint,
		Position = props.Position,
		BackgroundTransparency = 0.7,
		Text = props.Text,
		Size = UDim2.fromOffset(props.Size.X, props.Size.Y),
		TextColor3 = Color3.fromHex("FFFFFF"),
		Font = Enum.Font.Gotham,
		FontSize = Enum.FontSize.Size32,
		[Roact.Event.Activated] = props.Activated,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 1,
			Color = Color3.fromHex("FFFFFF"),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
	})
end
