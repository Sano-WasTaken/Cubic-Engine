local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local Signal = require(ReplicatedStorage.Classes.Signal)
local Item = require(ServerStorage.Classes.Item)

local Inventory = {}

local function getOffset(index: number)
	return 2 + (index - 1) * Item.bufferSize
end

local function new(rows: number?, columns: number?, buf: buffer?)
	rows = buf and buffer.readi8(buf, 0) or rows
	columns = buf and buffer.readi8(buf, 1) or columns

	local self = setmetatable({
		buffer = buf or buffer.create(2 + rows * columns * Item.bufferSize),
		rows = rows,
		UpdateSignal = Signal.new(),
		columns = columns,
		maxAmount = rows * columns,
	}, {
		__index = Inventory,
	})

	if buf == nil then
		buffer.writei8(self.buffer, 0, rows)
		buffer.writei8(self.buffer, 1, columns)
	end

	return self
end

export type Inventory = typeof(new())

function Inventory:Update()
	self.UpdateSignal:Fire()
end

function Inventory:GetEmptyIndex()
	local index = 0

	for i = 1, self.maxAmount do
		local item = self:GetItem(i)

		if item == nil then
			index = i
			break
		end
	end

	return index
end

function Inventory:AddItem(item: Item.Item): number
	print(item:GetID())

	local index = 0

	for i = 1, self.maxAmount do
		local sItem = self:GetItem(i)

		if
			sItem
			and sItem:GetID() == item:GetID()
			and item:HasSameMetadata(sItem)
			and sItem:GetAmount() ~= sItem:GetItemData().MaxStackSize
		then
			local totalAmount = item:GetAmount() + sItem:GetAmount()

			local amount = math.clamp(totalAmount, 1, 64)
			local sAmount = math.clamp(totalAmount - item:GetItemData().MaxStackSize, 0, 64)

			print(amount, sAmount)

			sItem:SetAmount(amount)

			self:SetItemAtIndex(i, sItem)

			if sAmount ~= 0 then
				index = self:GetEmptyIndex()

				if index ~= 0 then
					item:SetAmount(sAmount)
					self:SetItemAtIndex(index, item)
				end
			end
			break
		end

		if sItem == nil then
			index = i
			self:SetItemAtIndex(index, item)
			break
		end
	end

	print(index)
	self:Update()

	return index
end

-- do not Fire update
function Inventory:SetItemAtIndex(index: number, item: Item.Item)
	local offset = getOffset(index)

	item = item and item.buffer.buffer or buffer.create(Item.bufferSize)

	buffer.copy(self.buffer, offset, item, 0, Item.bufferSize)
end

function Inventory:GetAllItems(): { [number]: Item.Item }
	local items = {}

	for i = 1, self.maxAmount do
		local item = self:GetItem(i) :: Item.Item

		if item then
			items[i] = item
		end
	end

	return items
end

function Inventory:DeleteItem(index: number)
	local buf = buffer.create(Item.bufferSize)

	local offset = getOffset(index)

	buffer.copy(self.buffer, offset, buf, 0)

	self:Update()
end

-- do not create other items
function Inventory:IncrementItemAtIndex(index: number, number: number)
	local item = self:GetItem(index)

	if item == nil then
		return
	end

	local amount = item:GetAmount()
	local itemData = item:GetItemData()

	print(amount + number, (amount + number) <= itemData.MaxStackSize, 0 < (amount + number))

	if (amount + number) <= itemData.MaxStackSize and 0 < (amount + number) then
		item:SetAmount(amount + number)

		self:SetItemAtIndex(index, item)
	elseif (amount + number) == 0 then
		self:DeleteItem(index)
	end

	self:Update()
end

function Inventory:GetItem(index: number): Item.Item?
	local buf = buffer.create(Item.bufferSize)

	local offset = getOffset(index)

	buffer.copy(buf, 0, self.buffer, offset, Item.bufferSize)

	local item = Item.new(nil, buf)

	if item:GetID() == 0 then
		return
	end

	return item
end

function Inventory:GetFormattedItems()
	local items = {}

	for i, item in self:GetAllItems() do
		local itemFormat = {
			Amount = item:GetAmount(),
			Name = BlockEnum[item:GetID()],
		}

		items[tostring(i)] = itemFormat
	end

	return items
end

function Inventory:SwapItems(indexA: number, indexB: number)
	local itemA = self:GetItem(indexA)
	local itemB = self:GetItem(indexB)

	self:SetItemAtIndex(indexA, itemB)
	self:SetItemAtIndex(indexB, itemA)

	self:Update()
end

function Inventory:GetDimenssions(): (number, number)
	return self.rows, self.columns
end

function Inventory:Clear()
	for i = 1, self.maxAmount do
		self:DeleteItem(i)
	end

	self:Update()
end

return {
	new = new,
}
