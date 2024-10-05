local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Item = require(ServerStorage.Components.Item)
local PlayerInventoryGetter = require(ServerStorage.Managers.PlayerInventoryGetter)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)

local getInventory = PlayerInventoryGetter.getInventory
local removeInventory = PlayerInventoryGetter.removeInventory

InventoryNetwork.RequestInventory.listen(function(_: nil, player: Player)
	local inventory = getInventory(player):GetItems()

	InventoryNetwork.SendInventory.sendTo(inventory, player)
end)

InventoryNetwork.RequestClear.listen(function(_: nil, player: Player)
	getInventory(player):Clear()

	InventoryNetwork.SendInventory.sendTo({}, player)
end)

InventoryNetwork.RequestGiveItem.listen(function(data: { amount: number, id: number }, player: Player)
	local inventory = getInventory(player)

	inventory:InsertItem(Item:createItem(data.id, data.amount))

	InventoryNetwork.SendInventory.sendTo(inventory:GetItems(), player)
end)

InventoryNetwork.RequestSwapItem.listen(function(data: { id: number?, indexA: number, indexB: number }, player: Player)
	warn("later.", data, player)
end)

Players.PlayerAdded:Connect(getInventory)
Players.PlayerRemoving:Connect(removeInventory)

--[[local UpdateInventory = InventoryNetwork.UpdateInventory:Server()
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
end)]]
