local ServerStorage = game:GetService("ServerStorage")

local Inventory = require(ServerStorage.Classes.Inventory)

type Interface = { Inventory: Inventory.Inventory, HandledSlot: number }

local InventoryMap = {} :: { [Player]: Interface }

local function getInventory(player: Player): Inventory.Inventory
	local interface = InventoryMap[player]

	repeat
		interface = InventoryMap[player]
		if interface == nil then
			task.wait()
		end
	until interface ~= nil

	return interface.Inventory
end

local function setInventory(player: Player, inventory: Inventory.Inventory)
	InventoryMap[player] = {
		Inventory = inventory,
		HandledSlot = 0,
	}
end

local function setHandledSlot(player: Player, index: number)
	InventoryMap[player].HandledSlot = index
end

local function getHandledSlot(player: Player)
	return InventoryMap[player].HandledSlot
end

local function getHandledItem(player: Player)
	local inventory = getInventory(player)
	local index = getHandledSlot(player)

	if index == 0 then
		return
	end

	local item = inventory:GetItem(3 * 9 + index)

	if item:GetID() == 0 then
		setHandledSlot(player, 0)

		return
	end

	return item
end

local function deleteInventory(player: Player)
	InventoryMap[player] = nil
end

return {
	getInventory = getInventory,
	setInventory = setInventory,
	deleteInventory = deleteInventory,
	setHandledSlot = setHandledSlot,
	getHandledSlot = getHandledSlot,
	getHandledItem = getHandledItem,
}
