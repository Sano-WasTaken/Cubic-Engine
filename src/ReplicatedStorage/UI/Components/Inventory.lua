local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ScaleController = require(ReplicatedStorage.UI.Controllers.ScaleController)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Inventory = {
	Scope = Fusion.scoped(Fusion),
	UI = nil :: Instance?,
	Slots = {},
	Inventory = {},
}

local function createSlot(scope, slotValue, index)
	return scope:Computed(function(use, _)
		use(slotValue)

		local item = Inventory.Inventory[index]

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
			[Children] = {
				scope:New("ViewportFrame")({
					Transparency = 1,
					Size = UDim2.fromOffset(30, 30),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					CurrentCamera = camera,
					[Children] = {
						part,
					},
				}),
			},
			[OnEvent("Activated")] = function()
				--Inventory:SetSelectedSlot(index)
			end,
		})
	end)
end

function Inventory:createInventorySlots()
	local scope = Inventory.Scope
	local slots = {}

	--local items = scope.peek(Inventory.Inventory)

	for i = 1, 9 * 3 do
		local item: { ID: number, Amount: number }? = Inventory.Inventory[i]

		local slotValue = scope:Value(item)

		Inventory.Slots[i] = slotValue

		slots[i] = createSlot(scope, slotValue, i)
	end

	return slots
end

function Inventory:createHotbarSlots()
	local scope = Inventory.Scope
	local slots = {}

	--local items = scope.peek(Inventory.Inventory)

	for i = 9 * 3 + 1, 9 * 4 do
		local item: { ID: number, Amount: number }? = Inventory.Inventory[i]

		local slotValue = scope:Value(item)

		Inventory.Slots[i] = slotValue

		slots[i] = createSlot(scope, slotValue, i)
	end

	return slots
end

function Inventory:Init(inventory: {})
	assert(Inventory.UI == nil, "do not call this twice.")
	local scope = Inventory.Scope

	Inventory.Inventory = inventory

	Inventory.UI = scope:New("ScreenGui")({
		ResetOnSpawn = false,
		Name = "Inventory",
		[Children] = {
			scope:New("Frame")({
				Name = "Container",
				Size = UDim2.fromOffset(320, 161),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.55),
				Transparency = 1,
				[Children] = {
					ScaleController(scope, 3),
					scope:New("ImageLabel")({
						Name = "Inventory",
						Size = UDim2.fromOffset(320, 113),
						Image = "rbxassetid://92331130126620",
						ResampleMode = Enum.ResamplerMode.Pixelated,
						BackgroundTransparency = 1,
						[Children] = {
							scope:New("UIGridLayout")({
								CellSize = UDim2.fromOffset(32, 32),
								SortOrder = Enum.SortOrder.LayoutOrder,
								CellPadding = UDim2.fromOffset(3, 3),
							}),
							scope:New("UIPadding")({
								PaddingBottom = UDim.new(0, 7),
								PaddingTop = UDim.new(0, 4),
								PaddingLeft = UDim.new(0, 4),
								PaddingRight = UDim.new(0, 4),
							}),
							Inventory:createInventorySlots(),
						},
					}),

					scope:New("ImageLabel")({
						Name = "Hotbar",
						Size = UDim2.fromOffset(320, 43),
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Image = "rbxassetid://112942053039694",
						ResampleMode = Enum.ResamplerMode.Pixelated,
						BackgroundTransparency = 1,
						[Children] = {
							scope:New("UIGridLayout")({
								CellSize = UDim2.fromOffset(32, 32),
								SortOrder = Enum.SortOrder.LayoutOrder,
								CellPadding = UDim2.fromOffset(3, 3),
							}),
							scope:New("UIPadding")({
								PaddingBottom = UDim.new(0, 7),
								PaddingTop = UDim.new(0, 4),
								PaddingLeft = UDim.new(0, 4),
								PaddingRight = UDim.new(0, 4),
							}),
							Inventory:createHotbarSlots(),
						},
					}),
					--Inventory:createSlots(),
				},
			}),
		},
	})
end

function Inventory:Update(inventory: {})
	assert(Inventory.UI ~= nil, "must init the UI before toggling")
	local oldInv = Inventory.Inventory

	Inventory.Inventory = inventory

	for i, item in inventory do
		local slot = Inventory.Slots[i]

		if slot then
			slot:set(item)
		end
	end

	for i, _ in oldInv do
		if inventory[i] == nil then
			local slot = Inventory.Slots[i]

			if slot then
				slot:set(nil)
			end
		end
	end

	--Inventory.Inventory:set(inventory)
end

function Inventory:Visible()
	assert(Inventory.UI ~= nil, "must init the UI before toggling")

	Inventory.UI.Parent = Players.LocalPlayer.PlayerGui
end

function Inventory:Invisible()
	assert(Inventory.UI ~= nil, "must init the UI before toggling")

	Inventory.UI.Parent = nil
end

return Inventory
