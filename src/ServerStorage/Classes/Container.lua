local ServerStorage = game:GetService("ServerStorage")
local Item = require(ServerStorage.Classes.Item)

local Container = {}

local function new(slotAmount: number)
	local slots = {}

	for i = 1, slotAmount do
		slots[tostring(i)] = {
			item = nil,
		}
	end

	return setmetatable({ Slots = slots }, { __index = Container })
end

function Container:SetItemInSlot(slot: number, item: Item.Item)
	self.Slots[tostring(slot)].item = item
end

function Container:GetItemInSlot(slot: number): Item.Item?
	return self.Slots[tostring(slot)].item
end

return { new = new }
