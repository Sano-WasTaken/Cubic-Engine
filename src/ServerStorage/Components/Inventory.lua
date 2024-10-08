local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local Item = require(script.Parent.Item)
local Component = require(ServerStorage.Classes.Component)

local InventoryComponent = {}

setmetatable(InventoryComponent, { __index = Component })

function InventoryComponent:new(size: number): InventoryData
	return {
		Size = size or 1,
		Items = table.create(size, {}),
	}
end

function InventoryComponent:SetSize(size: number)
	self.Container.Size = size
end

function InventoryComponent:GetSize(): number
	return self.Container.Size
end

function InventoryComponent:SetItemAtIndex(item: Item.Item?, index: number)
	local items: {} = self.Container.Items

	if item then
		items[index] = item:GetContainerData()
	else
		items[index] = {}
	end
end

function InventoryComponent:GetItemAtIndex(index: number): Item.Item?
	local items: {} = self.Container.Items

	local item = items[index]

	if item and item.ID ~= nil then
		return Item:create(item) :: Item.Item
	end

	return nil
end

-- give an interger of the first empty slot.
function InventoryComponent:GetFirstEmptySlot(): number
	local slot = 0

	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index)

		if item == nil then
			slot = index
			break
		end
	end

	return slot
end

function InventoryComponent:GetFirstSlotWithItemID(id: number): number
	local slot = 0

	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index) :: Item.Item?

		if item and item:GetID() == id and item:GetAmount() ~= item:GetContent().MaxStackSize then
			slot = index
			break
		end
	end

	return slot
end

function InventoryComponent:InsertItem(item: Item.Item)
	local FSWIDS: number = self:GetFirstSlotWithItemID(item:GetID())
	local FES: number = self:GetFirstEmptySlot() -- can be unused

	-- if the inventory do not have any find slot with the id
	local fitem: Item.Item? = self:GetItemAtIndex(FSWIDS)

	if fitem then
		local nitem = fitem:MergeItem(item)

		if FES ~= 0 and nitem ~= nil and nitem ~= false then
			self:SetItemAtIndex(item, FES)
		end
	else
		if FES ~= 0 then
			self:SetItemAtIndex(item, FES)
		end
	end
end

function InventoryComponent:Clear()
	self.Container.Items = table.create(self:GetSize(), {})
end

function InventoryComponent:IsEmpty(): boolean
	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index) :: Item.Item?

		if item then
			return false
		end
	end

	return true
end

function InventoryComponent:IsFull(): boolean
	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index) :: Item.Item?

		if item == nil then
			return false
		end
	end

	return true
end

function InventoryComponent:GetAmountOfItem(): number
	local sumOfAmount = 0

	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index) :: Item.Item?

		if item then
			sumOfAmount += item:GetAmount()
		end
	end

	return sumOfAmount
end

function InventoryComponent:GetAmountOfSlotUsed(): number
	local sumOfSlot = 0

	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index) :: Item.Item?

		if item then
			sumOfSlot += item:GetAmount() / item:GetContent().MaxStackSize
		end
	end

	return sumOfSlot
end

function InventoryComponent:Print()
	print("Total amount of items:", self:GetAmountOfItem())

	for index = 1, self:GetSize() do
		local item = self:GetItemAtIndex(index) :: Item.Item?

		if item then
			print(`Slot #{index}`)
			print(`Name: {ItemEnum[item:GetID()]}`)
			print(`Amount: {item:GetAmount()}`)
		end
	end

	if self:IsEmpty() then
		print("Inventory is empty !")
	end

	if self:IsFull() then
		print("Inventory is full !")
	end
end

function InventoryComponent:GetItems()
	local container: InventoryData = self:GetContainerData()

	return container.Items
end

function InventoryComponent:GetPercentagePerSlot()
	return self:GetAmountOfSlotUsed() / self:GetSize()
end

export type InventoryData = {
	Size: number,
	Items: { any },
}
export type InventoryComponent = typeof(InventoryComponent) & InventoryData

return InventoryComponent
