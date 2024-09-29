local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--local Inventory = require(ServerStorage.Classes)
--local Item = require(ServerStorage.Classes.Item)
local Item = require(ServerStorage.Components.Item)
local PlayerInventory = require(ServerStorage.Components.PlayerInventory)
local DataProviderManager = require(ServerStorage.Managers.DatabaseManager)
local PlayerInventoryManager = require(ServerStorage.Managers.PlayerInventoryManager)
--local InventoryManager = require(ServerStorage.Managers.InventoryManager)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)

local UpdateInventory = InventoryNetwork.UpdateInventory:Server()
local RequestSwapItem = InventoryNetwork.RequestSwapItem:Server()
local RequestEquipItem = InventoryNetwork.RequestEquipItem:Server()
local RequestGiveItem = InventoryNetwork.RequestGiveItem:Server()
local RequestClearInventory = InventoryNetwork.RequestClearInventory:Server()

local function getInventory(player: Player)
	local container = DataProviderManager:GetPlayerData(tostring(player.UserId)).Inventory

	local inventory = PlayerInventory:create()

	inventory:SetInventory(container)

	return inventory
end

Players.PlayerAdded:Connect(function(player: Player)
	local inventory = getInventory(player)

	PlayerInventoryManager:Append(player, inventory)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerInventoryManager:Delete(player)
end)

InventoryNetwork.GetInventory:SetCallback(function(player, _: string?)
	local inventory = getInventory(player)

	return inventory:GetInventory()
end)

RequestSwapItem:On(function(player: Player, _: string?, indexA: number, indexB: number)
	getInventory(player):SwapItems(player, indexA, indexB)
end)

RequestEquipItem:On(function(player: Player, index: number)
	getInventory(player):SetSelectedSlot(player, index)
end)

RequestGiveItem:On(function(player: Player, id: number, amount: number)
	local inventory = getInventory(player)

	local item = Item:create(id)

	item:SetAmount(amount)

	--inventory:
end)

RequestClearInventory:On(function(player: Player)
	getInventory(player):Clear()
end)
