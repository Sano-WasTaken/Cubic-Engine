local ServerStorage = game:GetService("ServerStorage")

local Item = require(ServerStorage.Classes.Item)
local Inventory = require(ServerStorage.Classes.Inventory)

local inv = Inventory.new(3, 9)

local it1 = Item.new(1)
	:SetAmount(32)
	:SetMetadata({
		durability = 250,
		anchantment = {
			"efficiency",
			"silk touch"
		}
	})

local it2 = Item.new(1)
	:SetAmount(33)
	:SetMetadata({
		durability = 250,
		anchantment = {
			"efficiency",
			"silk touch"
		}
	})

local it3 = Item.new(1)
	:SetAmount(64)
	:SetMetadata({
		durability = 4656,
		anchantment = {
			"silk touch"
		}
	})

inv:AddItem(it2)
local index = inv:AddItem(it1)
inv:SetItemAtIndex(3*9, it3)

for i, item in it1:SplitItem(5) do
	print(item:GetAmount())
	inv:SetItemAtIndex(i+index, item)
end

for i, it in inv:GetAllItems() do
	print(i, it:GetAmount(), it:GetID(), it:GetMetadata())
end

