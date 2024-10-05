local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local Characters = require(script.Characters)

local IMAGE_ID = "rbxassetid://103746231516014"
local CHARACTER_SIZE = UDim2.fromOffset(7, 11)
local SPACE_SIZE = 2
local ROW_SIZE = 6

type props = {
	Text: Fusion.UsedAs<string>?,
	Position: Fusion.UsedAs<UDim2>?,
	TextScale: Fusion.UsedAs<number>?,
	Rotation: Fusion.UsedAs<number>?,
	AnchorPoint: Fusion.UsedAs<Vector2>?,
}

local function createText(scope: Fusion.Scope<typeof(Fusion)>, props: props)
	local textUI = scope:New("Frame")({
		Transparency = 1,
		Size = scope:Computed(function(use)
			local textUsed = use(props.Text or ""):upper()
			return UDim2.fromOffset(
				textUsed:len() * CHARACTER_SIZE.X.Offset + (textUsed:len() - 1) * 2,
				CHARACTER_SIZE.Y.Offset
			)
		end),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint,
		Rotation = props.Rotation,
		[children] = {
			scope:Computed(function(use)
				local textUsed = use(props.Text or ""):upper()

				local charactersUI = {}
				local index = 0

				for char in textUsed:gmatch(".") do
					local i = table.find(Characters, char)

					local x = (i - 1) % ROW_SIZE
					local y = (i - 1) // ROW_SIZE

					if i == nil or char == " " then
						index += 1
						continue
					end

					table.insert(
						charactersUI,
						scope:New("ImageLabel")({
							Image = IMAGE_ID,
							ResampleMode = Enum.ResamplerMode.Pixelated,
							LayoutOrder = index,
							BackgroundTransparency = 1,
							ScaleType = Enum.ScaleType.Fit,
							ImageRectOffset = Vector2.new(
								x * (CHARACTER_SIZE.X.Offset + SPACE_SIZE),
								y * CHARACTER_SIZE.Y.Offset
							),
							ImageRectSize = Vector2.new(CHARACTER_SIZE.X.Offset, CHARACTER_SIZE.Y.Offset),
							Size = CHARACTER_SIZE,
							Position = UDim2.fromOffset(index * (CHARACTER_SIZE.X.Offset + SPACE_SIZE), 0),
						})
					)

					index += 1
				end

				return charactersUI
			end),
			scope:New("UIScale")({
				Scale = props.TextScale,
			}),
		},
	})

	return textUI
end

return createText
