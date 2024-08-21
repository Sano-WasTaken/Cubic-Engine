local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)
local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local ToolEnum = require(ReplicatedStorage.Enums.ToolEnum)

local defaultBuffer = BufferManager.new()

defaultBuffer:SetDataInBuffer("ID", 2, "u"):SetDataInBuffer("AMOUNT", 1, "u"):SetDataInBuffer("METADATA", 250, "str")

local Item = {}

local function new(id: number?, buf: buffer?)
	local self = setmetatable({
		buffer = defaultBuffer:CloneObject(buf),
	}, {
		__index = Item,
	})

	if id then
		self.buffer:WriteData("ID", id)
	end

	if buf == nil then
		self:SetMetadata({})
	end

	return self
end

export type Item = typeof(new())

function Item:SetAmount(amount: number)
	self.buffer:WriteData("AMOUNT", amount)

	return self
end

function Item:HasSameMetadata(otherItem: Item): boolean
	local metadata = self:GetMetadata()
	local otherMetadata = otherItem:GetMetadata()

	local function iterate(t1, t2)
		for index, value in t1 do
			if type(value) == type(t2[index]) and type(value) == "table" then
				if not iterate(value, t2[index]) then
					return false
				end
			elseif t2[index] ~= value then
				return false
			end
		end

		return true
	end

	return iterate(metadata, otherMetadata)
end

function Item:IsValid()
	return self:GetID() ~= 0
end

function Item:GetAmount(): number
	return self.buffer:ReadData("AMOUNT")
end

function Item:GetID(): number
	return self.buffer:ReadData("ID")
end

function Item:SplitItem(splitFactor: number): { Item }
	local itemData = self:GetItemData()

	if itemData.MaxStackSize == 1 then
		return
	end

	local items = {}

	local amount = self:GetAmount()
	local id = self:GetID()
	local metadata = self:GetMetadata()

	for _ = 1, splitFactor do
		local item = new(id):SetAmount(amount // splitFactor):SetMetadata(metadata)
		table.insert(items, item)
	end

	if amount % splitFactor > 0 then
		local item = new(id):SetAmount(amount % splitFactor):SetMetadata(metadata)
		table.insert(items, item)
	end

	return items
end

function Item:SetMetadata(metadata: { [string]: any })
	local data = HttpService:JSONEncode(metadata)

	assert(string.len(data) <= 250, "metadata are too heavy for the buffer size")

	self.buffer:WriteData("METADATA", data)

	return self
end

function Item:GetMetadata(): { [string]: any }
	local meta = self.buffer:ReadData("METADATA")

	local ok, result = pcall(HttpService.JSONDecode, HttpService, meta)

	if not ok then
		return {}
	end

	return result
end

-- give a confirmation that the item is a block and gives you the block id
function Item:IsABlock(): (boolean, number?)
	local itemData = self:GetItemData()

	if itemData and itemData.BlockData then
		local blockId = BlockEnum[ItemEnum[self:GetID()]]

		return true, blockId
	else
		return false
	end
end

function Item:IsATool()
	local toolId = ToolEnum[ItemEnum[self:GetID()]]

	return toolId ~= nil, toolId
end

function Item:GetItemData()
	local itemData = ItemDataProvider:GetData(self:GetID())

	return itemData
end

return {
	new = new,
	bufferSize = defaultBuffer:GetSize(),
}
