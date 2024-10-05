local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local PlayerInventoryGetter = require(ServerStorage.Managers.PlayerInventoryGetter)

return function(context)
	local inventory = PlayerInventoryGetter.getInventory(context.Executor)

	if inventory then
		inventory:Clear()

		InventoryNetwork.SendInventory.sendTo(inventory:GetItems(), context.Executor)

		return "Inventory cleared !"
	end

	return "error."
end
