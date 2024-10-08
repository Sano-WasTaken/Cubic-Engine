local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Text = require(ReplicatedStorage.UI.Components.Text)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)
local BaseController = require(script.Parent.BaseController)

local children = Fusion.Children

local Controller = {}

Controller.CreateText = Text

function Controller.Init(self: Scope)
	self.ItemValue = self:Value(nil)

	local mouse = UserInputService:GetMouseLocation()

	self.Position = self:Value(Vector2.new(mouse.X, mouse.Y))

	local viewport

	self.Instance = self:New("ScreenGui")({
		Name = "DraggingFrame",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 50,
		[children] = {
			self:Computed(function(use)
				local item = use(self.ItemValue)

				if viewport then
					viewport:Destroy()
				end

				if item == nil or item.ID == nil then
					return
				end

				local part, camera = GetMesh(item.ID)

				viewport = self:New("ViewportFrame")({
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(30, 30),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = self:Computed(function(use2)
						local position = use2(self.Position)

						return UDim2.fromOffset(position.X, position.Y)
					end),
					CurrentCamera = camera,
					[children] = {
						self:Scale(3),
						part,
						self:CreateText({
							Text = tostring(item.Amount or 1),
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromOffset(30, 30),
							TextScale = 7.5 / 1.5,
						}),
					},
				})

				return viewport
			end),
		},
	})
end

function Controller.Set(self: Scope, item: { ID: number, Amount: number? }?)
	if item then
		self:Visible()
	else
		self:Invisible()
	end

	self.ItemValue:set(item)
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

RunService.RenderStepped:Connect(function()
	local mouse = UserInputService:GetMouseLocation()

	if scope.peek(scope.ItemValue) == nil then
		return
	end

	scope.Position:set(Vector2.new(mouse.X, mouse.Y))
end)

return scope
