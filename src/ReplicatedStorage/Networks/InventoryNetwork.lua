local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)
local EnumItem = require(ReplicatedStorage.Enums.ItemEnum)

return {
	GetInventory = Red.Function("GetInventory", function(id: string?)
		return id
	end, function(inventory: { any })
		return inventory
	end),

	UpdateInventory = Red.Event("UpdateInventory", function(inventory: { any })
		return inventory
	end),

	RequestSwapItem = Red.Event("RequestSwapItem", function(id: string?, indexA: number, indexB: number)
		return id, indexA, indexB
	end),

	RequestEquipItem = Red.Event("RequestEquipItem", function(index: number) -- under 0 and 9 | 0 is for Unequip
		--assert(index <= 9 and 0 >= index, "index is out of range.")

		return index
	end),

	RequestGiveItem = Red.Event("RequestGiveItem", function(id: number, amount: number)
		assert(EnumItem[id], "id not found")

		return id, amount
	end),

	RequestClearInventory = Red.Event("RequestClearInventory", function()
		return
	end),
}
