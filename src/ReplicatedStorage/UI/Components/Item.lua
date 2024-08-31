local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local Item = Roact.Component:extend("Item")

local CELL_COLOR = Color3.fromHex("#4D4D54")
local HOVERED_COLOR = Color3.fromHex("#393943")
local SELECTED_COLOR = Color3.fromHex("8f8fa8")

export type ItemProps = {
	Name: string?,
	Amount: number,
	Index: number,
	Events: {
		Clicked: (rbx: ViewportFrame, props: ItemProps) -> (),
		Hovered: (rbx: ViewportFrame, props: ItemProps) -> (),
		Leaved: (rbx: ViewportFrame) -> (),
	},
	Selected: boolean?,
	Position: UDim2?,
	Transparency: number?,
}

function Item:init()
	self.ColorBinding, self.ColorUpdate = Roact.createBinding(CELL_COLOR)
end

function Item:render()
	local props: ItemProps = self.props

	return Roact.createElement("ViewportFrame", {
		[Roact.Ref] = function(viewport: ViewportFrame)
			--print("ref update")
			if viewport == nil then
				return
			end

			if viewport:FindFirstChild("Appearence") then
				viewport:FindFirstChild("Appearence"):Destroy()
				print("destroy")
			end

			if props.Name then
				local model, camera = GetMesh(props.Name)

				model.Name = "Appearence"

				if model == nil then
					return
				end

				model.Parent = viewport
				viewport.CurrentCamera = camera
			end
		end,
		[Roact.Event.MouseEnter] = function(rbx: ViewportFrame)
			props.Events.Hovered(rbx, props)
			self.ColorUpdate(HOVERED_COLOR)
		end,
		[Roact.Event.InputBegan] = function(rbx: ViewportFrame, input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local connection = rbx.InputEnded:Once(function(inputEnded)
				if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
					props.Events.Clicked(rbx, props)
				end
			end)

			rbx.MouseLeave:Once(function()
				connection:Disconnect()
			end)
		end,
		[Roact.Event.MouseLeave] = function(rbx: ViewportFrame)
			props.Events.Leaved(rbx)
			self.ColorUpdate(CELL_COLOR)
		end,
		LayoutOrder = props.Index,
		BackgroundColor3 = self.ColorBinding,
		BorderSizePixel = 0,
		Position = props.Position or UDim2.fromScale(0, 0),
		Size = UDim2.fromOffset(50, 50),
		BackgroundTransparency = props.Transparency or 0,
	}, {
		AmountTextLabel = Roact.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.3, 0.3),
			Position = UDim2.fromScale(0.7, 0.7),
			Text = (props.Amount > 1) and props.Amount or "",
			TextColor3 = Color3.new(1, 1, 1),
			FontSize = Enum.FontSize.Size14,
			Font = Enum.Font.GothamBold,
		}),
		UIStroke = Roact.createElement(
			"UIStroke",
			{ Color = SELECTED_COLOR, Enabled = props.Selected == true, Thickness = 2 }
		),
		UICorner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0, 7.5) }),
	})
end

return Item
