local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--local Inventory = require(ServerStorage.Classes.Inventory)
local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
error("please wait inventory are under contruction")

local PlayerInventoryManager = {
	InventoryMap = {} :: { [Player]: typeof(PlayerInventory) },
}

function PlayerInventoryManager:SwapItems(slotA: number, slotB: number) end

return PlayerInventoryManager
