local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DraggingFrameController = require(script.Parent.DraggingFrameController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Slot = require(ReplicatedStorage.UI.Components.Slot)
local Text = require(ReplicatedStorage.UI.Components.Text)
local BaseController = require(ReplicatedStorage.UI.Controllers.BaseController)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local children = Fusion.Children

local Controller = {
	Slots = {},
	Inventory = {},
	SelectedSlotChanged = Signal.new() :: Signal.Signal<number>,
}

DraggingFrameController:Init()

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

function Controller.createSlots(self: Scope)
	local slots = {}

	for i = 1, 9 do
		local item: { ID: number, Amount: number }? = self.Inventory[tostring(i + 3 * 9)]

		local currentId: number?
		local viewport: ViewportFrame?

		local slotValue = self:Value(item)

		self.Slots[i + 3 * 9] = slotValue

		slots[i] = self:CreateSlot({
			Image = self:Computed(function(use2)
				return (use2(self.SelectedSlot) == i) and "rbxassetid://83778210351566" or "rbxassetid://95455592822381"
			end),
			LayoutOrder = i,
			Childrens = {
				self:Computed(function(use)
					item = use(slotValue)

					local isSameID: boolean = item and currentId == item.ID

					if not isSameID and item then
						currentId = item.ID

						local part, camera = GetMesh(item.ID)

						if viewport then
							viewport:Destroy()
						end

						viewport = self:New("ViewportFrame")({
							Transparency = 0.9,
							BackgroundColor3 = Color3.fromHex("575757"),
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
					item = use(slotValue)

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
				local slot = (self:GetSelectedSlot() == i) and 0 or i
				self:SetSelectedSlot(slot)
			end,
		})
	end

	return slots
end

function Controller.GetSelectedSlot(self: Scope): number
	assert(self.Instance ~= nil, "must init the UI before getting Selected Slot !")

	return self.peek(self.SelectedSlot)
end

function Controller.SetSelectedSlot(self: Scope, slot: number)
	assert(self.Instance ~= nil, "must init the UI before setting Selected Slot !")

	if self:GetSelectedSlot() ~= slot then
		self.SelectedSlot:set(slot)

		self.SelectedSlotChanged:Fire(slot)
	end
end

function Controller.GetItemIdInSelectedSlot(self: Scope): number?
	assert(self.Instance ~= nil, "must init the UI before setting Selected Slot !")

	local selectedSlot = self:GetSelectedSlot()

	local slotvalue = self.Slots[selectedSlot + 3 * 9]

	local item = self.peek(slotvalue)

	return item and item.ID or nil
end

function Controller.Init(self: Scope, inventory: {})
	assert(self.Instance == nil, "do not call this twice.")

	self.SelectedSlot = self:Value(0)
	self.Inventory = inventory

	self.Instance = self:New("ScreenGui")({
		ResetOnSpawn = false,
		Name = "Hotbar",
		[children] = {
			self:New("Frame")({
				Name = "Container",
				Size = UDim2.fromOffset(9 * 32 + 8 * 3, 32),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -15),
				Transparency = 1,
				[children] = {
					self:Scale(3),
					self:New("UIListLayout")({
						Padding = UDim.new(0, 3),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					self:createSlots(),
				},
			}),
		},
	})
end

function Controller.Update(self: Scope, inventory: { [string]: any })
	assert(self.Instance ~= nil, "must init the UI before toggling")
	local oldInv = self.Inventory

	self.Inventory = inventory

	for i, item in inventory do
		if oldInv[i] ~= nil and areTheSame(item, oldInv[i]) then
			continue
		end

		local slot = self.Slots[tonumber(i)]

		if slot then
			slot:set(item)
		end
	end

	for i, _ in oldInv do
		if areTheSame(inventory[i], {}) then
			local slot = self.Slots[tonumber(i)]

			if slot then
				slot:set(nil)
			end
		end
	end
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
