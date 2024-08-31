local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local ItemComponent = require(ReplicatedStorage.UI.Components.Item)
local Inventory = require(ReplicatedStorage.UI.Components.Inventory)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local ScaleController = require(ReplicatedStorage.UI.Controllers.ScaleController)

local RequestEquipItem = InventoryNetwork.RequestEquipItem:Client()

local player = Players.LocalPlayer

local HotbarController = {
	Tree = nil :: Roact.Tree?,
	Inventory = {},
	UserInputService = nil :: RBXScriptConnection?,
	Element = nil :: Roact.Element?,
	SelectedSlot = 0,
}

local keys = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
}

function HotbarController:Init(inventory: { any })
	self:Update(inventory)

	self.UserInputService = UserInputService.InputBegan:Connect(function(input, _)
		local index = table.find(keys, input.KeyCode)

		if index then
			local item = self.Inventory[index]

			self:equip(item and index or 0)
		end
	end)

	self:mountTree()
end

function HotbarController:equip(index: number)
	index = (self.SelectedSlot ~= index) and index or 0

	RequestEquipItem:Fire(index)
	self.SelectedSlot = index
	if self.Tree ~= nil then
		self:updateTree()
	end
end

function HotbarController:Unmount()
	if self.Tree == nil then
		return
	end

	if self.UserInputService then
		self.UserInputService:Disconnect()
		self.UserInputService = nil
	end

	Roact.unmount(self.Tree)
	self.Tree = nil
end

function HotbarController:mountTree()
	self:updateElements()

	self.Tree = Roact.mount(self.Element, player:WaitForChild("PlayerGui"))
end

function HotbarController:getEvents()
	local events = {
		Clicked = function(_: ViewportFrame, props: ItemComponent.ItemProps)
			if props.Name then
				self:equip(props.Index)
			end
		end,
		Hovered = function() end,
		Leaved = function() end,
	}

	return events
end

function HotbarController:updateElements()
	local hotbarProps: Inventory.InventoryProps = {
		Columns = 9,
		Rows = 1,
		Scale = ScaleController:map(function(scale)
			return 1.5 * scale
		end),
		SelectedSlot = self.SelectedSlot,
		Position = UDim2.fromScale(0.5, 1),
		Items = self.Inventory,
		AnchorPoint = Vector2.new(0.5, 1),
		Offset = 0,
		Event = self:getEvents(),
	}

	self.Element = Roact.createElement(
		"ScreenGui",
		{ Enabled = true },
		{ Hotbar = Roact.createElement(Inventory, hotbarProps) }
	)
end

function HotbarController:Update(inventory: { any })
	for i = 1, 9 do
		local item = inventory[tostring(i + 3 * 9)]

		if item then
			self.Inventory[i] = item
		else
			if self.SelectedSlot == i then
				self:equip(0)
			end
			self.Inventory[i] = nil
		end
	end

	if self.Tree ~= nil then
		self:updateTree()
	end
end

function HotbarController:updateTree()
	self:updateElements()

	self.Tree = Roact.update(self.Tree, self.Element)
end

return HotbarController
