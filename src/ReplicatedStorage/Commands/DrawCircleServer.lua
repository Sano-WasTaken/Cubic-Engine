local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DrawFunctions = require(ReplicatedStorage.Utils.DrawFunctions)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

return function(_, radius: number, position: Vector3, id: number, empty: boolean)
	DrawFunctions.DrawCircle(radius, position.X, position.Z, function(cx, cy)
		if id ~= 0 then
			WorldManager:Insert(Block.new(id):SetPosition(cx, position.Y, cy))
		else
			WorldManager:Delete(cx, position.Y, cy)
		end
	end, empty)

	return "Circle generated !"
end
