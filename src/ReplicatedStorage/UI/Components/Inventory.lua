local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Item = require(ReplicatedStorage.UI.Components.Item)

local ItemClass = require(ReplicatedStorage.Classes.Item)

local Inventory = Roact.Component:extend("Inventory")

local PADDING = 5
local PADDING_CELL = 8
local CELL_SIZE = 60
local BACKGROUND_COLOR = Color3.fromHex("#333340")

export type InventoryProps = {
	Rows: number,
	Columns: number,
	Scale: number,
	Position: UDim2,
	Items: { ItemClass.Item },
	Offset: number,
	AnchorPoint: Vector2?,
	Event: {
		Clicked: (rbx: ViewportFrame, props: Item.ItemProps) -> (),
		Hovered: (rbx: ViewportFrame, props: Item.ItemProps) -> (),
		Leaved: (rbx: ViewportFrame) -> (),
	},
}

function Inventory:init() end

function Inventory:render()
	local props: InventoryProps = self.props

	local items = {}

	for i = 1 + props.Offset, props.Columns * props.Rows + props.Offset do
		local item = props.Items[i] or {}

		local itemProps: Item.ItemProps = {
			Amount = item.Amount or 0,
			Events = props.Event,
			Name = item.Name,
			Index = i,
		}

		local element = Roact.createElement(Item, itemProps)

		table.insert(items, element)
	end

	local fragment = Roact.createFragment(items)

	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(
			2 * PADDING + (props.Columns - 1) * PADDING_CELL + props.Columns * CELL_SIZE,
			2 * PADDING + (props.Rows - 1) * PADDING_CELL + props.Rows * CELL_SIZE
		),
		Position = props.Position,
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		BackgroundColor3 = BACKGROUND_COLOR,
		BorderSizePixel = 0,
	}, {
		UIScale = Roact.createElement("UIScale", {
			Scale = props.Scale,
		}),
		UIGridLayout = Roact.createElement("UIGridLayout", {
			CellSize = UDim2.fromOffset(CELL_SIZE, CELL_SIZE),
			CellPadding = UDim2.fromOffset(PADDING_CELL, PADDING_CELL),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		UIPadding = Roact.createElement("UIPadding", {
			PaddingBottom = UDim.new(0, PADDING),
			PaddingLeft = UDim.new(0, PADDING),
			PaddingRight = UDim.new(0, PADDING),
			PaddingTop = UDim.new(0, PADDING),
		}),
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 10) }),
		Fragment = fragment,
	})
end

return Inventory
