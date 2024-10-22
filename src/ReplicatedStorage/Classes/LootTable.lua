local LootTable = {}

export type LootItem = { id: number, min: number?, max: number?, chance: number? }
export type LootTable = {
	Items: { LootItem },
}

local function new(lootTable: LootTable?)
	return setmetatable(lootTable or { Items = {} }, { __index = LootTable })
end

function LootTable:SetItem(item: LootItem)
	table.insert(self.Items, item)

	return self
end

function LootTable:GetSumOfChance()
	local sum = 0

	if #self.Items == 0 then
		return
	end

	for _, item: LootItem in self.Items do
		if item.chance then
			sum += item.chance
		end
	end

	if sum == 0 then
		return
	end

	return sum
end

function LootTable:CalculateItems()
	local items = {}
	local random = Random.new()

	local sumOfChance: number = self:GetSumOfChance()

	local n = random:NextInteger(1, sumOfChance or 0)
	random:Shuffle(self.Items)

	for _, item: LootItem in self.Items do
		if sumOfChance then
			if n > item.chance then
				n -= item.chance
			else
				table.insert(items, {
					ID = item.id,
					Amount = random:NextInteger(item.min or 1, item.max or 1),
				})
			end
		else
			table.insert(items, {
				ID = item.id,
				Amount = random:NextInteger(item.min or 1, item.max or 1),
			})
		end
	end

	return items
end

return { new = new }
