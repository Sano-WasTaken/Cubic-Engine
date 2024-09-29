local ServerStorage = game:GetService("ServerStorage")
local Component = require(ServerStorage.Classes.Component)
local Item = require(ServerStorage.Components.Item)
local Inventory = {
	ClassName = "Inventory",
}

setmetatable(Inventory, { __index = Component })

function Inventory:create(size: number)
	return setmetatable({
		Size = size,
		Container = {} :: { [string]: Item.IItem },
	}, { __index = Inventory })
end

function Inventory:GetSize(): number
	return self.Size
end

function Inventory:SetItemAtPosition(item: Item.Item, position: number)
	if self:GetItemAtPosition(position) ~= nil then
		self.Container[tostring(position)] = item
	end
end

function Inventory:GetItemAtPosition(position: number): Item.IItem?
	return self.Container[tostring(position)]
end

return Inventory
