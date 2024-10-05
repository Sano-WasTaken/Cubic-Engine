local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ScaleController = require(ReplicatedStorage.UI.Controllers.ScaleController)
local GetMesh = require(ReplicatedStorage.UI.Utils.GetMesh)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Hotbar = {
	Scope = Fusion:scoped(),
	UI = nil :: Instance?,
	SelectedSlot = nil :: Fusion.ScopedObject?,
	Slots = {},
	Inventory = {},
}

function Hotbar:createSlots()
	local scope = Hotbar.Scope
	local slots = {}

	--local items = scope.peek(Hotbar.Inventory)

	for i = 1, 9 do
		local item: { ID: number, Amount: number }? = Hotbar.Inventory[i]

		local slotValue = scope:Value(item)

		Hotbar.Slots[i] = slotValue

		slots[i] = scope:Computed(function(use1, _)
			use1(slotValue)

			item = Hotbar.Inventory[i + 3 * 9] or Hotbar.Inventory[tostring(i + 3 * 9)]

			local part, camera

			if item then
				part, camera = GetMesh(item.ID)
			end

			return scope:New("ImageButton")({
				Size = UDim2.fromOffset(32, 32),
				LayoutOrder = i,
				ResampleMode = Enum.ResamplerMode.Pixelated,
				--Image = "rbxassetid://88929582556128",
				--Image = i == 8 and "rbxassetid://135600450644016" or "rbxassetid://88929582556128",
				Image = scope:Computed(function(use2)
					return (use2(Hotbar.SelectedSlot) == i) and "rbxassetid://135600450644016"
						or "rbxassetid://88929582556128"
				end),
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
					Hotbar:SetSelectedSlot(i)
				end,
			})
		end)

		--[[ = ]]
	end

	return slots
end

function Hotbar:GetSelectedSlot(): number
	return Hotbar.Scope.peek(Hotbar.SelectedSlot)
end

function Hotbar:SetSelectedSlot(slot: number)
	--assert(Hotbar.UI ~= nil, "must init the UI before toggling")

	Hotbar.SelectedSlot:set(slot)
end

function Hotbar:Init(inventory: {})
	assert(Hotbar.UI == nil, "do not call this twice.")
	local scope = Hotbar.Scope

	Hotbar.SelectedSlot = scope:Value(0)
	Hotbar.Inventory = inventory

	Hotbar.UI = scope:New("ScreenGui")({
		ResetOnSpawn = false,
		Name = "Hotbar",
		[Children] = {
			scope:New("Frame")({
				Name = "Container",
				Size = UDim2.fromOffset(9 * 32 + 8 * 3, 32),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -15),
				Transparency = 1,
				[Children] = {
					ScaleController(scope, 3),
					scope:New("UIListLayout")({
						Padding = UDim.new(0, 3),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					Hotbar:createSlots(),
				},
			}),
		},
	})
end

function Hotbar:Update(inventory: {})
	assert(Hotbar.UI ~= nil, "must init the UI before toggling")
	local oldInv = Hotbar.Inventory

	Hotbar.Inventory = inventory

	for i, item in inventory do
		local slot = Hotbar.Slots[i]

		if slot then
			slot:set(item)
		end
	end

	for i, _ in oldInv do
		if inventory[i] == nil then
			local slot = Hotbar.Slots[i]

			if slot then
				slot:set(nil)
			end
		end
	end

	--Hotbar.Inventory:set(inventory)
end

function Hotbar:Visible()
	assert(Hotbar.UI ~= nil, "must init the UI before toggling")

	Hotbar.UI.Parent = Players.LocalPlayer.PlayerGui
end

function Hotbar:Invisible()
	assert(Hotbar.UI ~= nil, "must init the UI before toggling")

	Hotbar.UI.Parent = nil
end

return Hotbar
