local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

export type FrameProps = {
	Size: Vector2,
	Title: string,
	Padding: number,
}

return function(props: FrameProps, children: { [string | number]: Roact.Element })
	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(props.Size.X, props.Size.Y),
		BackgroundColor3 = Color3.fromHex("151515"),
		BackgroundTransparency = 0.7,
	}, {
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 1,
			Color = Color3.fromHex("FFFFFF"),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		}),
		UIPadding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, props.Padding),
			PaddingLeft = UDim.new(0, props.Padding),
			PaddingRight = UDim.new(0, props.Padding),
			PaddingTop = UDim.new(0, props.Padding),
		}),
		Childrens = Roact.createFragment(children),
	})
end
