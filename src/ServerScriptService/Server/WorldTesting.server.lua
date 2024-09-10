local ServerStorage = game:GetService("ServerStorage")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DataProviderManager = require(ServerStorage.Managers.DataProviderManager)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)
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
	_player:LoadCharacter()
end

print("player loads")

WorldManager:Delete(0, 7, 0)
WorldManager:Insert(Block.new(4):SetPosition(0, 7, 0))
