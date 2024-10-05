local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local BaseController = require(ReplicatedStorage.UI.Controllers.BaseController)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local children = Fusion.Children
local event = Fusion.OnEvent

local Controller = {
	Slots = {},
}

function Controller.createSlots(self: Scope)
	local slots = {}

	for i = 1, 9 do
		local item: { ID: number, Amount: number }? = self.Inventory[i]

		local slotValue = self:Value(item)

		self.Slots[i] = slotValue

		slots[i] = self:Computed(function(use1, _)
			use1(slotValue)

			item = self.Inventory[i + 3 * 9] or self.Inventory[tostring(i + 3 * 9)]

			local part, camera

			if item then
				part, camera = GetMesh(item.ID)
			end

			return self:New("ImageButton")({
				Size = UDim2.fromOffset(32, 32),
				LayoutOrder = i,
				ResampleMode = Enum.ResamplerMode.Pixelated,
				--Image = "rbxassetid://88929582556128",
				--Image = i == 8 and "rbxassetid://135600450644016" or "rbxassetid://88929582556128",
				Image = self:Computed(function(use2)
					return (use2(self.SelectedSlot) == i) and "rbxassetid://135600450644016"
						or "rbxassetid://88929582556128"
				end),
				BackgroundTransparency = 1,
				[children] = {
					self:New("ViewportFrame")({
						Transparency = 1,
						Size = UDim2.fromOffset(30, 30),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						CurrentCamera = camera,
						[children] = { part },
					}),
				},
				[event("Activated")] = function()
					self:SetSelectedSlot(i)
				end,
			})
		end)
	end

	return slots
end

function Controller.GetSelectedSlot(self: Scope): number
	assert(self.Instance ~= nil, "must init the UI before getting Selected Slot !")

	return self.peek(self.SelectedSlot)
end

function Controller.SetSelectedSlot(self: Scope, slot: number)
	assert(self.Instance ~= nil, "must init the UI before setting Selected Slot !")

	self.SelectedSlot:set(slot)
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

function Controller.Update(self: Scope, inventory: {})
	assert(self.Instance ~= nil, "must init the UI before toggling")
	local oldInv = self.Inventory

	self.Inventory = inventory

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

	--Hotbar.Inventory:set(inventory)
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
