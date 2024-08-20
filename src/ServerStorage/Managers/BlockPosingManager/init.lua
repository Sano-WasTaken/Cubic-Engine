local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local callbacks = {}

local Modules = script:GetChildren() :: { ModuleScript }

local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

local templateContent = {
	id = 0,
	callback = function(_: Vector3, _: Vector3, _: Vector3): (Vector3, Vector3) end,
}

local function verify(content: {})
	return typeof(templateContent) == typeof(content)
end

for _, module in Modules do
	local ok, result: typeof(templateContent) = pcall(require, module)

	if ok and verify(result) then
		callbacks[result.id] = result.callback
	end
end

return function(id: number, position: Vector3, direction: Vector3, normal: Vector3)
	local blockType = BlockDataProvider:GetData(id).BlockType

	local callback = callbacks[blockType] or callbacks[0]

	local newPosition, orientation = callback(position, direction, normal)

	local block = Block.new(id)
		:SetPosition(newPosition.X, newPosition.Y, newPosition.Z)
		:SetOrientation(orientation.X, orientation.Y, orientation.Z)

	WorldManager:Insert(block)
end
