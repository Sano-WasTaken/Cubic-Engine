local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Waiter = require(ReplicatedStorage.Classes.Waiter)
local DrawFunctions = require(ReplicatedStorage.Utils.DrawFunctions)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

return function(_, radius: number, position: Vector3, id: number, empty: boolean)
	local waiter = Waiter.new()
	DrawFunctions.DrawCircle(radius, position.X, position.Z, function(cx, cy)
		waiter:Update()

		if id ~= 0 then
			WorldManager:Insert(Block.new(id):SetPosition(cx, position.Y, cy))
		else
			WorldManager:Delete(cx, position.Y, cy)
		end
	end, empty)

	return "Circle generated !"
end
