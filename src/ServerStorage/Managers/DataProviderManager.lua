local DataStoreService = game:GetService("DataStoreService")

local function waitForBudget(requestType: Enum.DataStoreRequestType)
	repeat
		task.wait()
	until DataStoreService:GetRequestBudgetForRequestType(requestType) > 150
end

local scopes = {
	PlayerInventory = true,
	Chunks = true,
}

local function getDataStore(scope: string): DataStore
	if scopes[scope] then
		return DataStoreService:GetDataStore("Data_Player_V3", scope)
	end
end

local function getData<T>(key: string, scope: string): T
	waitForBudget(Enum.DataStoreRequestType.GetAsync)

	local dataStore = getDataStore(scope)

	local ok, result = pcall(dataStore.GetAsync, dataStore, `Player_{key}`)

	if ok and result ~= nil then
		return result
	end

	warn(result)

	return nil
end

local function saveData<T>(key: string, scope: string, data: T)
	waitForBudget(Enum.DataStoreRequestType.SetIncrementAsync)

	local dataStore = getDataStore(scope)

	local ok, result = pcall(dataStore.SetAsync, dataStore, `Player_{key}`, data)

	if not ok then
		warn(result)
	end
end

return {
	getData = getData,
	saveData = saveData,
}
