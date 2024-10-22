local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
local Component = require(ServerStorage.Classes.Component)

local ItemComponent = {}

setmetatable(ItemComponent, { __index = Component })

export type Item = typeof(ItemComponent) & {
	ID: number,
	Amount: number?,
}

function ItemComponent:new(id: number?)
	return {
		ID = id or 1,
		--Amount = 1, -- useless.
	}
end

function ItemComponent:createItem(id: number, amount: number?)
	local item = ItemComponent:create(ItemComponent:new(id))

	if amount then
		item:SetAmount(amount)
	end

	return item
end

function ItemComponent:MergeItem(item: Item): Item? | false
	if self:GetID() == item:GetID() then
		local content = item:GetContent()

		local totalAmount = self:GetAmount() + item:GetAmount()
		local sAmount = math.min(totalAmount, content.MaxStackSize)
		local amount = totalAmount - sAmount

		self:SetAmount(sAmount)
		item:SetAmount(amount)

		if amount ~= 0 then
			print(self, item)
			return item
		end

		return nil
	end

	return item
end

function ItemComponent:SetID(id: number)
	self.Container.ID = id
end

function ItemComponent:GetID(): number
	return self.Container.ID
end

function ItemComponent:GetAmount(): number
	return self.Container.Amount or 1
end

function ItemComponent:SetAmount(amount: number): Item
	local content: ItemDataProvider.ItemContent = self:GetContent()

	if content.MaxStackSize >= amount then
		self.Container.Amount = amount
	end

	if self.Container.Amount < 0 then
		table.clear(self.Container)
	end

	return self
end

function ItemComponent:GetContent(): ItemDataProvider.ItemContent
	return ItemDataProvider:GetData(self:GetID())
end

return ItemComponent
