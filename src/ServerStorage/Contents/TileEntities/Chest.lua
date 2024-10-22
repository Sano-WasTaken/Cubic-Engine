local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--local FacingTileEntity = require(ServerStorage.Classes.FacingTileEntity)
local TileEntity = require(ServerStorage.Classes.TileEntity)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local Inventory = require(ServerStorage.Components.Inventory)

local ChestTile = {
	ClassName = "Chest",
	ID = BlockEnum["Chest"],
}

setmetatable(ChestTile, { __index = TileEntity })

--ChestTile:setComponent("Facing", Facing)
ChestTile:setComponent("Inventory", Inventory, 3 * 9)

function ChestTile:GetInventory(): Inventory.InventoryComponent
	return self:GetComponent("Inventory")
end

--[[function ChestTile:GetFacing(): Facing.Facing
	return self:GetComponent("Facing"):GetFacing()
end]]

return ChestTile
