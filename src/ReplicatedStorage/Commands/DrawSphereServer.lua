local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Waiter = require(ReplicatedStorage.Classes.Waiter)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local DrawFunctions = require(ReplicatedStorage.Utils.DrawFunctions)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

return function(_, radius: number, position: Vector3, name: string, empty: boolean)
	local waiter = Waiter.new()

	local bulkImporter = WorldManager:BulkInsert()

	waiter:Start()

	local id = BlockEnum[name]

	DrawFunctions.DrawSphere(radius, position, function(x, y, z)
		waiter:Update()

		if id ~= 0 then
			bulkImporter:Insert(Block.new(id):SetPosition(x, y, z))

			--WorldManager:Insert(Block.new(id):SetPosition(x, y, z))
		else
			WorldManager:Delete(x, y, z)
		end
	end, empty)

	bulkImporter:Stop()

	return "Sphere generated !"
end
