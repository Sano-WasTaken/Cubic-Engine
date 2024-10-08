local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Item = require(ServerStorage.Components.Item)
local PlayerInventoryGetter = require(ServerStorage.Managers.PlayerInventoryGetter)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)

local getInventory = PlayerInventoryGetter.getInventory
local removeInventory = PlayerInventoryGetter.removeInventory

InventoryNetwork.RequestInventory.invoke(function(_: nil, player: Player?): { { Amount: number?, ID: number? } }
	local inventory = getInventory(player):GetItems()

	return inventory
end)

InventoryNetwork.Clear.listen(function(_: nil, player: Player)
	getInventory(player):Clear()

	InventoryNetwork.SendInventory.sendToClient(player, {})
end)

InventoryNetwork.GiveItem.listen(function(data: { amount: number, id: number }, player: Player)
	local inventory = getInventory(player)

	inventory:InsertItem(Item:createItem(data.id, data.amount))

	InventoryNetwork.SendInventory.sendToClient(player, inventory:GetItems())
end)

InventoryNetwork.SwapItem.listen(function(data, player: Player)
	local inventory = getInventory(player)

	local itemA = inventory:GetItemAtIndex(data.indexA)
	local itemB = inventory:GetItemAtIndex(data.indexB)

	inventory:SetItemAtIndex(itemA, data.indexB)
	inventory:SetItemAtIndex(itemB, data.indexA)

	InventoryNetwork.SendInventory.sendToClient(player, inventory:GetItems())
end)

Players.PlayerAdded:Connect(getInventory)
Players.PlayerRemoving:Connect(removeInventory)
