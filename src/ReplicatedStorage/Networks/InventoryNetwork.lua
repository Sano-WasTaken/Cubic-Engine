local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bytenet = require(ReplicatedStorage.Packages.Bytenet)

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
