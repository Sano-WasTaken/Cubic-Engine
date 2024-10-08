local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local Item = require(ServerStorage.Components.Item)
local PlayerInventoryGetter = require(ServerStorage.Managers.PlayerInventoryGetter)

return function(context, id: number, amount: number)
	if ItemEnum[id] ~= nil then
		local item = Item:createItem(id, amount)

		local inventory = PlayerInventoryGetter.getInventory(context.Executor)

		inventory:InsertItem(item)

		InventoryNetwork.SendInventory.sendToClient(context.Executor, inventory:GetItems())

		return "Give success."
	end

	return "Invalid id."
end
