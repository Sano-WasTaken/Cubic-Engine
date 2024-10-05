local ServerStorage = game:GetService("ServerStorage")
local Inventory = require(ServerStorage.Components.Inventory)
local DatabaseManager = require(script.Parent.DatabaseManager)
local PlayersInventory: { [Player]: Inventory.InventoryComponent } = {}

local function getInventory(player: Player): Inventory.InventoryComponent
	if PlayersInventory[player] == nil then
		local data = DatabaseManager:GetPlayerData(tostring(player.UserId)).Inventory
		PlayersInventory[player] = Inventory:create(data)
	end

	return PlayersInventory[player]
end

local function removeInventory(player: Player)
	DatabaseManager:SavePlayerData(tostring(player.UserId), true)

	PlayersInventory[player] = nil
end

return {
	getInventory = getInventory,
	removeInventory = removeInventory,
}
