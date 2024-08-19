local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Item = require(ReplicatedStorage.Classes.Item)
local ItemComponent = require(ReplicatedStorage.UI.Components.Item)
local Inventory = require(ReplicatedStorage.UI.Components.Inventory)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)

local RequestSwapItem = InventoryNetwork.RequestSwapItem:Client()

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local InventoryController = {
	Tree = nil :: Roact.Tree,
	Inventory = {},
	Element = nil :: Roact.Element,
	HoveredSlot = 0,
	DraggedSlot = 0,
	Dragger = nil :: Roact.Tree,
}

function InventoryController:CreateDragger(item: Item.Item)
	local positionValue, positionUpdate = Roact.createBinding(UDim2.fromOffset(mouse.X, mouse.Y))

	local props: ItemComponent.ItemProps = {
		Amount = item.Amount,
		Index = 1,
		Name = item.Name,
		Events = {
			Clicked = function() end,
			Hovered = function() end,
			Leaved = function() end,
		},
		Position = positionValue,
		Transparency = 1,
	}

	return Roact.createElement(ItemComponent, props), positionUpdate
end

function InventoryController:Init(inventory: { Item.Item })
	self:Update(inventory)

	self:mountTree()
end

function InventoryController:getEvents()
	local events = {
		Clicked = function(...)
			self:Activated(...)
		end,
		Hovered = function(...)
			self:Hovered(...)
		end,
		Leaved = function(...)
			self:Leaved(...)
		end,
	}

	return events
end

function InventoryController:Drag(index: number)
	self.DraggedSlot = index

	RunService:UnbindFromRenderStep("UpdateDragger")

	if index == 0 and self.Dragger then
		Roact.unmount(self.Dragger)

		self.Dragger = nil
	end

	if index ~= 0 then
		local item = self.Inventory[index]

		--print(item)

		if item == nil then
			return
		end

		local element, updater = self:CreateDragger(item)

		self.Dragger = Roact.mount(element, player:WaitForChild("PlayerGui"):FindFirstChild("Inventory"), "Dragger")

		self:updateTree()

		RunService:BindToRenderStep("UpdateDragger", 1, function()
			updater(UDim2.fromOffset(mouse.X, mouse.Y))
		end)
	end
end

function InventoryController:Activated(_: ViewportFrame, props: ItemComponent.ItemProps)
	local itemName = props.Name
	local index = props.Index

	if self.DraggedSlot ~= index and self.DraggedSlot == 0 then
		-- drag l'item si il existe
		if itemName then
			self:Drag(index)
		end
	elseif self.DraggedSlot == index then
		--print("on laisse l'item la ou il était")
		self:Drag(0)
	end

	if self.DraggedSlot ~= index and self.DraggedSlot ~= 0 then
		RequestSwapItem:Fire(nil, self.DraggedSlot, self.HoveredSlot)
		self:Drag(0)
	end
end

function InventoryController:Hovered(_: ViewportFrame, props: ItemComponent.ItemProps)
	--print(props.Index)

	self.HoveredSlot = props.Index
end

function InventoryController:Leaved(_: ViewportFrame)
	--print("leave")

	self.HoveredSlot = 0
end

function InventoryController:updateElements()
	local inventoryProps: Inventory.InventoryProps = {
		Columns = 9,
		Rows = 3,
		Scale = 1,
		Position = UDim2.new(0.5, 0, 0, 206 / 2),
		Items = self.Inventory,
		Offset = 0,
		Event = self:getEvents(),
	}

	local hotbarProps: Inventory.InventoryProps = {
		Columns = 9,
		Rows = 1,
		Scale = 1,
		Position = UDim2.new(0.5, 0, 0, 300 - 70 / 2),
		Items = self.Inventory,
		Offset = 3 * 9,
		Event = self:getEvents(),
	}

	self.Element = Roact.createElement("ScreenGui", { Enabled = true }, {
		MainFrame = Roact.createElement("Frame", {
			Size = UDim2.fromOffset(614, 300),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
		}, {
			Inventory = Roact.createElement(Inventory, inventoryProps),
			Hotbar = Roact.createElement(Inventory, hotbarProps),
		}),
	})
end

function Reset()
	InventoryController:Drag(0)

	InventoryController.DraggedSlot = 0
	InventoryController.HoveredSlot = 0
end

function InventoryController:Unmount()
	if self.Tree == nil then
		return
	end

	Reset()

	Roact.unmount(self.Tree)
	self.Tree = nil
end

function InventoryController:mountTree()
	self:updateElements()

	self.Tree = Roact.mount(self.Element, player:WaitForChild("PlayerGui"), "Inventory")
end

function InventoryController:Update(inventory: { Item.Item })
	for i = 1, 4 * 9 do
		local index = inventory[tostring(i)]

		if index then
			self.Inventory[i] = index
		else
			self.Inventory[i] = nil
		end
	end

	if self.Tree ~= nil then
		self:updateTree()
	end
end

function InventoryController:updateTree()
	self:updateElements()

	self.Tree = Roact.update(self.Tree, self.Element)
end

return InventoryController
