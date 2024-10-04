local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Waiter = require(ReplicatedStorage.Classes.Waiter)
local DrawFunctions = require(ReplicatedStorage.Utils.DrawFunctions)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

return function(_, radius: number, position: Vector3, id: number, empty: boolean)
	local waiter = Waiter.new()

	waiter:SetExecutionTime(4)

	waiter:Start()

	DrawFunctions.DrawSphere(radius, position, function(x, y, z)
		waiter:Update()

		if id ~= 0 then
			WorldManager:Insert(Block.new(id):SetPosition(x, y, z))
		else
			WorldManager:Delete(x, y, z)
		end
	end, empty)

	return "Sphere generated !"
end
