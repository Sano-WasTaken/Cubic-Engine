local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DrawFunctions = require(ReplicatedStorage.Utils.DrawFunctions)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

return function(_, radius: number, position: Vector3, id: number, empty: boolean)
	DrawFunctions.DrawSphere(radius, position, function(x, y, z)
		if id ~= 0 then
			WorldManager:Insert(Block.new(id):SetPosition(x, y, z))
		else
			WorldManager:Delete(x, y, z)
		end
	end, empty)

	return "Sphere generated !"
end
