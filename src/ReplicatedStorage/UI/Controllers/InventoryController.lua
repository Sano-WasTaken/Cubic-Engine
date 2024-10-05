local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local event = Fusion.OnEvent
local BaseController = require(ReplicatedStorage.UI.Controllers.BaseController)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)
local Controller = {
	Inventory = {},
	Slots = {},
}

function Controller.Update(self: Scope, inventory: {})
	assert(self.Instance ~= nil, "must init the UI before toggling")
	local oldInv = self.Inventory

	for i, item in inventory do
		local slot = self.Slots[i]

		if slot then
			slot:set(item)
		end
	end

	for i, _ in oldInv do
		if inventory[i] == nil then
			local slot = self.Slots[i]

			if slot then
				slot:set(nil)
			end
		end
	end
end

local function createSlot(scope: Scope, slotValue, index)
	return scope:Computed(function(use, _)
		use(slotValue)

		local item = scope.Inventory[index]

		local part, camera

		if item then
			part, camera = GetMesh(item.ID)
		end

		return scope:New("ImageButton")({
			Size = UDim2.fromOffset(32, 32),
			LayoutOrder = index,
			ResampleMode = Enum.ResamplerMode.Pixelated,
			Image = "rbxassetid://123167957040866",
			BackgroundTransparency = 1,
			[children] = {
				scope:New("ViewportFrame")({
					Transparency = 1,
					Size = UDim2.fromOffset(30, 30),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					CurrentCamera = camera,
					[children] = {
						part,
					},
				}),
			},
			[event("Activated")] = function()
				--Inventory:SetSelectedSlot(index)
			end,
		})
	end)
end

function Controller.createInventorySlots(self: Scope)
	local slots = {}

	--local items = scope.peek(Inventory.Inventory)

	for i = 1, 9 * 3 do
		local item: { ID: number, Amount: number }? = self.Inventory[i]

		local slotValue = self:Value(item)

		self.Slots[i] = slotValue

		slots[i] = createSlot(self, slotValue, i)
	end

	return slots
end

function Controller.createHotbarSlots(self: Scope)
	local slots = {}

	--local items = scope.peek(Inventory.Inventory)

	for i = 9 * 3 + 1, 9 * 4 do
		local item: { ID: number, Amount: number }? = self.Inventory[i]

		local slotValue = self:Value(item)

		self.Slots[i] = slotValue

		slots[i] = createSlot(self, slotValue, i)
	end

	return slots
end

function Controller.Init(self: Scope)
	assert(self.Instance == nil, "Do not init twice !")

	self.Instance = self:New("ScreenGui")({
		ResetOnSpawn = false,
		Name = "Inventory",
		[children] = {
			self:New("Frame")({
				Name = "Container",
				Size = UDim2.fromOffset(320, 161),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				Transparency = 1,
				[children] = {
					self:Scale(3),
					self:New("ImageLabel")({
						Name = "Inventory",
						Size = UDim2.fromOffset(320, 113),
						Image = "rbxassetid://92331130126620",
						ResampleMode = Enum.ResamplerMode.Pixelated,
						BackgroundTransparency = 1,
						[children] = {
							self:New("UIGridLayout")({
								CellSize = UDim2.fromOffset(32, 32),
								SortOrder = Enum.SortOrder.LayoutOrder,
								CellPadding = UDim2.fromOffset(3, 3),
							}),
							self:New("UIPadding")({
								PaddingBottom = UDim.new(0, 7),
								PaddingTop = UDim.new(0, 4),
								PaddingLeft = UDim.new(0, 4),
								PaddingRight = UDim.new(0, 4),
							}),
							self:createInventorySlots(),
						},
					}),
					self:New("ImageLabel")({
						Name = "Hotbar",
						Size = UDim2.fromOffset(320, 43),
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Image = "rbxassetid://112942053039694",
						ResampleMode = Enum.ResamplerMode.Pixelated,
						BackgroundTransparency = 1,
						[children] = {
							self:New("UIGridLayout")({
								CellSize = UDim2.fromOffset(32, 32),
								SortOrder = Enum.SortOrder.LayoutOrder,
								CellPadding = UDim2.fromOffset(3, 3),
							}),
							self:New("UIPadding")({
								PaddingBottom = UDim.new(0, 7),
								PaddingTop = UDim.new(0, 4),
								PaddingLeft = UDim.new(0, 4),
								PaddingRight = UDim.new(0, 4),
							}),
							self:createHotbarSlots(),
						},
					}),
					--Inventory:createSlots(),
				},
			}),
		},
	})
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
