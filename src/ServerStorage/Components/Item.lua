local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local Component = require(ServerStorage.Classes.Component)
local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
local Item = {
	ClassName = "Item",
}

setmetatable(Item, { __index = Component })

export type MetaData = {}
export type Item = typeof(Item) & Component.Component & IItem
export type IItem = {
	ID: number,
	Amount: number?,
	MetaData: MetaData?,
}

function Item:create(id: number)
	assert(ItemEnum[id] ~= nil, "ID not valid !")

	return setmetatable({
		ID = id,
		--Amount = amount or 1,
	}, { __index = Item })
end

function Item:GetItemContent(): ItemDataProvider.ItemContent
	return ItemDataProvider:GetData(self.ID)
end

function Item:GetAmount(): number
	return self.Amount or 1
end

function Item:SetAmount(amount: number)
	local content: ItemDataProvider.ItemContent = self:GetItemContent()

	if content.MaxStackSize >= amount and content.MaxStackSize ~= 1 then
		self.Amount = amount
	end
end

function Item:SetMetaData(metaData: MetaData)
	self.MetaData = metaData
end

function Item:GetMetaData(): MetaData
	return self.MetaData or {}
end

return Item
