local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bytenet = require(ReplicatedStorage.Packages.Bytenet)

--[[local packets = {
	GetInventory = Red.Function("GetInventory", function(id: string?): string?
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
}]]

local packets = Bytenet.defineNamespace("Inventory", function()
	return {
		GetInventory = Bytenet.definePacket({
			value = Bytenet.unknown,
		}),

		UpdateInventory = Bytenet.definePacket({
			value = Bytenet.unknown,
		}),

		RequestSwapItem = Bytenet.definePacket({
			value = Bytenet.struct({
				id = Bytenet.uint16,
				indexA = Bytenet.uint16,
				indexB = Bytenet.uint16,
			}),
		}),

		RequestMouseInteraction = Bytenet.definePacket({
			value = Bytenet.struct({
				selectedSlot = Bytenet.uint8,
				origin = Bytenet.vec3,
				direction = Bytenet.vec3,
			}),
		}),

		RequestGiveItem = Bytenet.definePacket({
			value = Bytenet.struct({
				id = Bytenet.uint16,
				amount = Bytenet.uint8,
			}),
		}),

		RequestClear = Bytenet.definePacket({
			value = Bytenet.nothing,
		}),
	}
end)

return packets
