local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Inventory = require(ServerStorage.Classes.Inventory)
local Item = require(ServerStorage.Classes.Item)
local DataProviderManager = require(ServerStorage.Managers.DataProviderManager)
local InventoryManager = require(ServerStorage.Managers.InventoryManager)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)

local UpdateInventory = InventoryNetwork.UpdateInventory:Server()
local RequestSwapItem = InventoryNetwork.RequestSwapItem:Server()
local RequestEquipItem = InventoryNetwork.RequestEquipItem:Server()
local RequestGiveItem = InventoryNetwork.RequestGiveItem:Server()
local RequestClearInventory = InventoryNetwork.RequestClearInventory:Server()

Players.PlayerAdded:Connect(function(player: Player)
	local playerData = DataProviderManager:GetPlayerData(player.UserId)

	local buf = playerData.Inventory

	local inventory = Inventory.new(4, 9, buf)

	playerData.Inventory = inventory.buffer

	InventoryManager.setInventory(player, inventory)

	player.CharacterAdded:Connect(function(_: Model)
		InventoryManager.setHandledSlot(player, 0)
	end)

	inventory.UpdateSignal:Connect(function()
		UpdateInventory:Fire(player, inventory:GetFormattedItems())
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	DataProviderManager:SavePlayerData(player.UserId)

	InventoryManager.deleteInventory(player)
end)

InventoryNetwork.GetInventory:SetCallback(function(player, _: string?)
	local inventory = InventoryManager.getInventory(player)

	return inventory:GetFormattedItems()
end)

RequestSwapItem:On(function(player: Player, _: string?, indexA: number, indexB: number)
	local inventory = InventoryManager.getInventory(player)

	inventory:SwapItems(indexA, indexB)
end)

RequestEquipItem:On(function(player: Player, index: number)
	InventoryManager.setHandledSlot(player, index)
end)

RequestGiveItem:On(function(player: Player, id: number, amount: number)
	local inventory = InventoryManager.getInventory(player)

	local item = Item.new(id):SetAmount(amount or 1)

	inventory:AddItem(item)
end)

RequestClearInventory:On(function(player: Player)
	local inventory = InventoryManager.getInventory(player)

	inventory:Clear()
end)
