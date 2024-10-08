local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local DraggingFrameController = require(script.Parent.DraggingFrameController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Slot = require(ReplicatedStorage.UI.Components.Slot)
local Text = require(ReplicatedStorage.UI.Components.Text)
local children = Fusion.Children
local BaseController = require(ReplicatedStorage.UI.Controllers.BaseController)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local Controller = {
	Inventory = {} :: { [string]: any }, -- Space array
	Slots = {}, -- array
	DraggedSlot = 0,
}

Controller.CreateSlot = Slot
Controller.CreateText = Text

local function areTheSame(t1: { any }, t2: { any }): boolean
	for i, k in t1 do
		if k ~= t2[i] then
			return false
		end
	end

	return true
end

function Controller.Update(self: Scope, inventory: { [string]: any })
	assert(self.Instance ~= nil, "must init the UI before toggling")
	local oldInv = self.Inventory

	self.Inventory = inventory

	for i, item in inventory do
		if oldInv[i] ~= nil and areTheSame(item, oldInv[i]) then
			continue
		end

		local slot = self.Slots[i]

		if slot then
			slot:set(item)
		end
	end

	for i, _ in oldInv do
		if areTheSame(inventory[i], {}) then
			local slot = self.Slots[i]

			if slot then
				slot:set(nil)
			end
		end
	end

	print(self.Inventory)
end

local function createSlot(self: Scope, slotValue, index: number)
	local currentId: number?
	local viewport: ViewportFrame?

	return self:CreateSlot({
		Image = "rbxassetid://123167957040866",
		LayoutOrder = index,
		Childrens = {
			self:Computed(function(use)
				local item = use(slotValue)
				local draggedSlot = use(self.DraggedSlot)

				if draggedSlot == index then
					return
				end

				local isSameID: boolean = item and currentId == item.ID

				if not isSameID and item then
					currentId = item.ID

					local part, camera = GetMesh(item.ID)

					if viewport then
						viewport:Destroy()
					end

					viewport = self:New("ViewportFrame")({
						Transparency = 0,
						BackgroundColor3 = Color3.fromHex("404041"),
						Size = UDim2.fromOffset(30, 30),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						CurrentCamera = camera,
						[children] = { part },
					})
				end

				return item and viewport or nil
			end),
			self:Computed(function(use)
				local item = use(slotValue)

				local draggedSlot = use(self.DraggedSlot)

				if draggedSlot == index then
					return
				end

				return (item and item.ID ~= nil)
						and self:CreateText({
							Text = tostring(item.Amount or 1),
							AnchorPoint = Vector2.new(1, 1),
							Position = UDim2.fromOffset(30, 30),
							TextScale = 7.5 / 1.5,
						})
					or nil
			end),
		},
		Activated = function()
			local item = self.peek(slotValue)
			local draggedSlot = self.peek(self.DraggedSlot)

			if draggedSlot == 0 and item ~= nil and item.ID ~= nil then
				DraggingFrameController:Set(item)
				self.DraggedSlot:set(index)
			else
				DraggingFrameController:Set(nil)

				local itemB = self.Inventory[draggedSlot]
				local slotB = self.Slots[draggedSlot]

				slotB:set(item)
				slotValue:set(itemB)

				InventoryNetwork.SwapItem.sendToServer({ chestID = nil, indexA = index, indexB = draggedSlot })

				self.DraggedSlot:set(0)
			end
		end,
	})
end

function Controller.createInventorySlots(self: Scope)
	local slots = {}

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

	self.DraggedSlot = self:Value(0)

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
				},
			}),
		},
	})
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
