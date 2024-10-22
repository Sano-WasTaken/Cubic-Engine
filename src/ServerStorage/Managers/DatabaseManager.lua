local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local Inventory = require(ServerStorage.Components.Inventory)
--local MemoryStoreService = game:GetService("MemoryStoreService")

--local Players = game:GetService("Players")
local DATABASE_NAME = "Player_Database_PlayTesterV4"

local function waitForBudget(requestType: Enum.DataStoreRequestType)
	repeat
		task.wait()
	until DataStoreService:GetRequestBudgetForRequestType(requestType) > 150
end

--[[
List of scopes !

"Island", "PlayerData"

]]

export type chunk = {
	cx: number,
	cy: number,
	chunk: buffer,
	tileEntities: { any },
}
export type Island = { Chunks: { chunk } }
export type PlayerData = {
	Inventory: Inventory.InventoryData,
	Coins: number,
}

local Scopes = {
	PlayerData = "PlayerData",
	Island = "Island",
}

local Manager = {
	Sessions = {},
}

function Manager:GetDataStoreFromScope(scope: string): DataStore
	return DataStoreService:GetDataStore(DATABASE_NAME, scope)
end

function Manager:ReconcileSession(name: string, template: {})
	local session = self:GetSession(name)

	for k, v in template do
		if session[k] == nil then
			session[k] = v
		end
	end

	for k, _ in session do
		if template[k] == nil then
			session[k] = nil
		end
	end
end

function Manager:CreateSession(name: string, data: any)
	self.Sessions[name] = data
end

function Manager:DeleteSession(name: string)
	self.Sessions[name] = nil
end

function Manager:GetSession(name: string): any
	return self.Sessions[name]
end

function Manager:SaveData(database: DataStore, key: string, data: any)
	waitForBudget(Enum.DataStoreRequestType.SetIncrementAsync)

	local ok, result = pcall(database.SetAsync, database, key, data)

	if not ok then
		warn(result)
	else
		warn("Saving succeed!")
	end
end

function Manager:GetData(database: DataStore, key: string): any
	waitForBudget(Enum.DataStoreRequestType.GetAsync)

	local ok, result = pcall(database.GetAsync, database, key)

	if not ok then
		return nil
	else
		return result
	end
end

function Manager:GetIslandData(userId: number): Island
	local database = self:GetDataStoreFromScope(Scopes.Island)

	return self:GetData(database, tostring(userId)) or {
		Chunks = {},
	}
end

function Manager:SaveIslandData(userId: number, island: Island)
	local database = self:GetDataStoreFromScope(Scopes.Island)

	self:SaveData(database, tostring(userId), island)
end

function Manager:GetPlayerData(userId: string): PlayerData
	local database = self:GetDataStoreFromScope(Scopes.PlayerData)

	local session = self:GetSession(tostring(userId))

	local data

	local template = {
		Inventory = Inventory:new(4 * 9),
		Coins = 0,
	}

	if session then
		self:ReconcileSession(tostring(userId), template)

		return session
	else
		data = self:GetData(database, tostring(userId)) or template

		self:CreateSession(tostring(userId), data)
	end

	return data
end

function Manager:SavePlayerData(userId: string, deleteSession: boolean?)
	local database = self:GetDataStoreFromScope(Scopes.PlayerData)

	local session = self:GetSession(tostring(userId))

	if session == nil then
		error("no data in this session")
	end

	self:SaveData(database, tostring(userId), session)

	if deleteSession then
		self:DeleteSession(tostring(userId))
	end
end

return Manager
