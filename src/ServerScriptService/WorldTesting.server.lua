local ServerStorage = game:GetService("ServerStorage")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local DataProviderManager = require(ServerStorage.Managers.DataProviderManager)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)
--local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)

print("loading success !")

local player = Players.PlayerAdded:Wait()

WorldManager:SetOwner(player)

WorldManager:Init(DataProviderManager.getData(tostring(player.UserId), "Chunks"))

--WorldManager.insert(Block.new(2):SetPosition(86, 4, 52))
--print(WorldManager.getBlock(0, 4, 0):GetID())
--print(WorldManager.getChunks())
WorldManager.ChunksGenerated:Wait()

for _, _player in Players:GetPlayers() do
	_player:LoadCharacter()
end

--print(WorldManager.getBlock(0, 0, 0):GetID())

--.delete(0, 1, 0)
--WorldManager.delete(0, 2, 0)
--WorldManager.delete(0, 3, 0)

--WorldManager.insert(Block.new(4):SetPosition(0, 1, 0))
--WorldManager.insert(Block.new(1):SetPosition(0, 2, 0))
--WorldManager.insert(Block.new(3):SetPosition(0, 4, 0))

--[[for x = 1, 16 do
	for y = 1, 128 do
		for z = 1, 16 do
			if WorldManager.getBlock(x, y, z):GetID() ~= 0 then continue end

			local noise = math.noise(x/1.1, y/1.1, z/1.1) * 10
			
			if math.floor(noise) == 0 then
				WorldManager.insert(Block.new(1):SetPosition(x+20, y, z))
			end
			
		end
		task.wait()
	end
end]]

WorldManager:Delete(0, 7, 0)
WorldManager:Insert(Block.new(4):SetPosition(0, 7, 0))

--[[
local offset = Vector3.new(10, 0, math.floor(#BlockDataProvider/2))
for i = 1, #BlockDataProvider do
	local block = Block.new(i)
	local position = offset - Vector3.new(0, 0, i)
	
	block:SetPosition(position.X, position.Y, position.Z)
	WorldManager.delete(position.X, position.Y, position.Z)
	WorldManager.insert(block)
end]]

--[[
for x = -100, 100 do
	for y = 0, 8 do
		for z = -100, 100 do
			if WorldManager.getBlock(x, y, z):GetID() ~= 0 then continue end
			
			local block
			
			if y == 8 then
				block = Block.new(3)
			else
				block = Block.new(4)
			end
			
			WorldManager.insert(block:SetPosition(x, y, z))
		end
		task.wait()
	end
end]]

--print("terrain generated!")
