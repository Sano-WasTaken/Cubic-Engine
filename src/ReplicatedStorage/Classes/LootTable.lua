local LootTable = {}

export type Item = { id: number, min: number, max: number, chance: number? }
export type LootTable = {
	Items: { Item },
}

local function new(lootTable: LootTable?)
	return setmetatable(lootTable or { Items = {} }, { __index = LootTable })
end

function LootTable:SetItem(item: Item)
	table.insert(self.Items, item)
end

function LootTable:GetSumOfChance()
	local sum = 0

	if #self.Items == 0 then
		return
	end

	for _, item: Item in self.Items do
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

	for _, item: Item in self.Items do
		if sumOfChance then
			if n > item.chance then
				n -= item.chance
			else
				table.insert(items, {
					id = item.id,
					amount = random:NextInteger(item.min, item.max),
				})
			end
		else
			table.insert(items, {
				id = item.id,
				amount = random:NextInteger(item.min, item.max),
			})
		end
	end

	return items
end

return { new = new }
