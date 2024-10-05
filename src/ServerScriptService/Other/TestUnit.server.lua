local HttpService = game:GetService("HttpService")
local buf = buffer.create(100000)

for i = 0, 100000 - 1, 4 do
	buffer.writeu32(buf, i, math.random())
end

print(HttpService:JSONEncode(buf))

-- Chest and Inventory
--[[
local ServerStorage = game:GetService("ServerStorage")
local Item = require(ServerStorage.Components.Item)
local Chest = require(ServerStorage.Contents.TileEntities.Chest)

local chest: typeof(Chest) = Chest:create()

local inventory = chest:GetInventory()

inventory:SetItemAtIndex(Item:createItem(1, 32), 8)

inventory:InsertItem(Item:createItem(1, 64))
inventory:InsertItem(Item:createItem(1, 16))
inventory:InsertItem(Item:createItem(3, 48))
inventory:InsertItem(Item:createItem(1, 32))
inventory:InsertItem(Item:createItem(2, 56))

chest:SetPosition(15, 18, 1)

inventory:Print()

--inventory:Clear()

--inventory:Print() -- empty !

print(chest:GetFacing(), inventory:GetContainerData(), chest:GetPosition(), chest)]]
