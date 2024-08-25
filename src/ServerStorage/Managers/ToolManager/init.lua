local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local callbacks = {}

local Modules = script:GetChildren() :: { ModuleScript }

local ToolDataProvider = require(ReplicatedStorage.Providers.ToolDataProvider)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Item = require(ServerStorage.Classes.Item)

local templateContent = {
	id = { 0 },
	callback = function(_: Vector3, _: Vector3): { Vector3 } | Vector3 end,
}

local function verify(content: {})
	return typeof(templateContent) == typeof(content)
end

for _, module in Modules do
	local ok, result: typeof(templateContent) = pcall(require, module)

	if ok and verify(result) then
		for _, id in result.id do
			callbacks[id] = result.callback
		end
	end
end

return function(id: number, position: Vector3, normal: Vector3)
	local blockType = ToolDataProvider:GetData(id).BlockType

	local callback = callbacks[blockType] or callbacks[0]

	position = callback(position, normal)

	local positions: { Vector3 } = typeof(position) == "Vector3" and { position } or position

	local targets: { Item.Item } = {}

	for _, p in positions do
		local lootId = WorldManager:GetBlock(p.X, p.Y, p.Z):GetLoot()

		if lootId then
			local item = Item.new(lootId):SetAmount(1)
			table.insert(targets, item)
		end
		WorldManager:Delete(p.X, p.Y, p.Z)
	end

	return targets
end
