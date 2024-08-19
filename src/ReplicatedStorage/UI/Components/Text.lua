local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

export type TextProps = {
	Size: UDim2,
	AnchorPoint: Vector2,
	BackgroundTransparency: number,
}

return function(props: TextProps)
	local value, update = Roact.createBinding({
		Text = "nil",
	})

	return Roact.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		Text = value:map(function(v)
			return v.Text
		end),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}),
		update
end
