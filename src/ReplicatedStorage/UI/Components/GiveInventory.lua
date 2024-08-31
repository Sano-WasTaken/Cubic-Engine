local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local Roact = require(ReplicatedStorage.Packages.Roact)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local COLUMNS = 4
local PADDING = 15

type ItemProps = {
	ID: number,
	NAME: string,
	CLICK_EVENT: (rbx: ViewportFrame, index: number) -> (),
}

function createItem(props: ItemProps): Roact.Element
	return Roact.createElement("ViewportFrame", {
		LayoutOrder = props.ID,
		BackgroundColor3 = Color3.new(1, 1, 1),
		[Roact.Ref] = function(viewport: ViewportFrame)
			if viewport == nil then
				return
			end

			if viewport:FindFirstChild("Appearence") then
				viewport:FindFirstChild("Appearence"):Destroy()
			end

			if props.NAME then
				local model, camera = GetMesh(props.NAME)

				if model == nil then
					return
				end

				model.Parent = viewport
				viewport.CurrentCamera = camera
			end
		end,
		[Roact.Event.InputBegan] = function(rbx: ViewportFrame, input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local connection = rbx.InputEnded:Once(function()
				props.CLICK_EVENT(rbx, props.ID)
			end)

			rbx.MouseLeave:Once(function()
				connection:Disconnect()
			end)
		end,
	}, {
		NameLabel = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(0.8, 0.2),
			BackgroundTransparency = 1,
			Text = props.NAME:gsub("%_", " "),
		}),
	})
end

type Events = {
	Give: (rbx: ViewportFrame, index: number) -> (),
	Clear: (rbx: ViewportFrame) -> (),
}

local function createGiver(events: Events, scale: number) -- +1 bruh
	local CellSize = (500 - (COLUMNS - 1 + 2) * PADDING) / COLUMNS

	local items = {}

	for index, itemName in ItemEnum do
		local item = createItem({ ID = index, NAME = itemName, CLICK_EVENT = events.Give })

		items[itemName] = item
	end

	return Roact.createElement("Frame", { Size = UDim2.fromOffset(500, 800) }, {
		UIDragDetector = Roact.createElement(
			"UIDragDetector",
			{ BoundingBehavior = Enum.UIDragDetectorBoundingBehavior.EntireObject }
		),
		InnerLabelText = Roact.createElement("TextLabel", {
			Text = "Giver - Inventory",
			Size = UDim2.fromOffset(400, 50),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 10),
			TextScaled = true,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBlack,
			BackgroundColor3 = Color3.new(1, 1, 1),
		}),
		ScrollingFrame = Roact.createElement("ScrollingFrame", {
			Size = UDim2.fromOffset(500, 650),
			Position = UDim2.fromOffset(0, 70),
			ScrollBarThickness = 0,
			BorderSizePixel = 0,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, PADDING),
				PaddingTop = UDim.new(0, PADDING),
				PaddingLeft = UDim.new(0, PADDING),
				PaddingRight = UDim.new(0, PADDING),
			}),
			UIGridLayout = Roact.createElement("UIGridLayout", {
				CellPadding = UDim2.fromOffset(PADDING, PADDING),
				CellSize = UDim2.fromOffset(CellSize, CellSize),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Fragment = Roact.createFragment(items),
		}),
		ClearButton = Roact.createElement("TextButton", {
			Text = "Clear",
			[Roact.Event.MouseButton1Click] = events.Clear,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -10),
			Size = UDim2.fromOffset(200, 50),
		}),
		UIScale = Roact.createElement("UIScale", { Scale = scale }),
	})
end

return {
	CreateGiver = createGiver,
}
