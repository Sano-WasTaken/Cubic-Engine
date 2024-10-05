local ServerStorage = game:GetService("ServerStorage")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local DataProviderManager = require(ServerStorage.Managers.DatabaseManager)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)
local Item = require(ServerStorage.Components.Item)
local Chest = require(ServerStorage.Contents.TileEntities.Chest)
--local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)

local player = Players.PlayerAdded:Wait()

WorldManager:SetOwner(player)

local islandData = DataProviderManager:GetIslandData(player.UserId)

WorldManager:Init(islandData)
print("initialized")

local _ = WorldManager.IsGenerated or WorldManager.ChunksGenerated:Wait()

print("loading success !")

Players.CharacterAutoLoads = true
for _, _player in Players:GetPlayers() do
	_player.CharacterAdded:Connect(function(character: Model)
		character:PivotTo(CFrame.new(0, 9 * 3, 0))
	end)

	_player:LoadCharacter()
end

--WorldManager:Delete(0, 2, 0)
--[[WorldManager:Insert(Block.new(BlockEnum.Chest):SetPosition(0, 2, 0))
local block = WorldManager:GetBlock(0, 2, 0)

if block then
	task.spawn(function()
		while true do
			task.wait(1)
			local entityf: typeof(Chest) = block:GetEntity()

			local inv = entityf:GetInventory()

			inv:InsertItem(Item:createItem(1, 64))
			inv:InsertItem(Item:createItem(1, 64))
			inv:InsertItem(Item:createItem(1, 64))
			inv:InsertItem(Item:createItem(1, 64))

			if inv:IsFull() then
				inv:Clear()
			end

			print(inv:GetAmountOfItem(), `{math.floor(inv:GetPercentagePerSlot() * 100)}%`)

			print(entityf:GetFacing(), entityf:GetPosition())
		end
	end)
end]]

print("player loads")

WorldManager:Delete(0, 7, 0)
WorldManager:Insert(Block.new(4):SetPosition(0, 7, 0))

--WorldManager:Insert(Block.new(BlockEnum.Chest):SetPosition(0, 2, 0))
