-- Template for testing GUI Components
--[[
                READ THIS!
    You should not use this as a default UI its just here for
    testing your backend and front and Misc (like networks and clients features)

]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Framed = require(ReplicatedStorage.UI.Components.Framed)
local FramedTextButton = require(ReplicatedStorage.UI.Components.FramedTextButton)
local ScaleController = require(ReplicatedStorage.UI.Controllers.ScaleController)
local FramedTextLabel = require(ReplicatedStorage.UI.Components.FramedTextLabel)
local ScreenGui = require(ReplicatedStorage.UI.Components.ScreenGui)

local DEFAULT_SIZE = Vector2.new(100, 300)

local function CompareSizes(size: Vector2)
	if DEFAULT_SIZE.X > size.X or DEFAULT_SIZE.Y > size.Y then
		return DEFAULT_SIZE
	else
		return size
	end
end

export type ContainerProps = {
	Size: Vector2,
	Title: string,
	Padding: number?,
	HasCloseButton: boolean,
	Activated: (rbx: TextButton, inputObject: InputObject, clickCount: number) -> nil,
}

local FramedContainer = Roact.Component:extend("FramedContainer")

function FramedContainer:render()
	local props: ContainerProps = self.props

	props.Size = CompareSizes(props.Size)

	local childrens = {}

	local screen, updater, _ =
		ScreenGui(Framed({ Size = props.Size, Title = props.Title, Padding = props.Padding }, childrens))

	updater(true)

	if props.HasCloseButton then
		childrens["CloseButton"] = FramedTextButton({
			Text = "X",
			Size = Vector2.one * 50,
			Position = UDim2.fromScale(1, 0),
			AnchoredPoint = Vector2.new(1, 0),
			Activated = props.Activated,
		})
	end

	do
		childrens["UIScale"] = Roact.createElement("UIScale", { Scale = ScaleController })
		childrens["Title"] = FramedTextLabel({
			Size = props.HasCloseButton and Vector2.new(props.Size.X - 50 - (3 * props.Padding), 50)
				or Vector2.new(props.Size.X - (2 * props.Padding), 0),
			Text = props.Title,
		})
		childrens["UIDragDetector"] = Roact.createElement("UIDragDetector")
		childrens["ContentFrame"] = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(props.Size.X - (2 * props.Padding), props.Size.Y - 50 - (3 * props.Padding)),
			Position = UDim2.fromOffset(0, 50 + props.Padding),
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.Name,
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, props.Padding),
			}),
			Childrens = Roact.createFragment(props[Roact.Children]),
		})
	end

	props.Padding = props.Padding or 5

	return screen
end

return FramedContainer
