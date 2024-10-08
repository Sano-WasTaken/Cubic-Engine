local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KISSNet = require(ReplicatedStorage.Classes.KISSNet)

local packets = KISSNet.defineNamespace("Inventory", {
	RequestInventory = KISSNet.defineFunction(function()
		return KISSNet.nothing
	end, function()
		return KISSNet.array(KISSNet.dict({
			ID = KISSNet.optional(KISSNet.number),
			Amount = KISSNet.optional(KISSNet.number),
		}))
	end),

	SelectSlot = KISSNet.defineEvent(function()
		return KISSNet.number
	end),

	SendInventory = KISSNet.defineEvent(function()
		return KISSNet.array(KISSNet.dict({
			ID = KISSNet.optional(KISSNet.number),
			Amount = KISSNet.optional(KISSNet.number),
		}))
	end),

	SwapItem = KISSNet.defineEvent(function()
		return KISSNet.dict({
			chestID = KISSNet.optional(KISSNet.number),
			indexA = KISSNet.number,
			indexB = KISSNet.number,
		})
	end),

	MouseInteraction = KISSNet.defineEvent(function()
		return KISSNet.dict({
			selectedSlot = KISSNet.number,
			origin = KISSNet.vector3,
			direction = KISSNet.vector3,
		})
	end),

	GiveItem = KISSNet.defineEvent(function()
		return KISSNet.dict({
			ID = KISSNet.number,
			Amount = KISSNet.number,
		})
	end),

	Clear = KISSNet.defineEvent(function()
		return KISSNet.nothing
	end),
})

return packets
