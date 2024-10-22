local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Waiter = require(ReplicatedStorage.Classes.Waiter)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local DrawFunctions = require(ReplicatedStorage.Utils.DrawFunctions)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)

return function(_, radius: number, position: Vector3, name: string, empty: boolean)
	local waiter = Waiter.new()

	--waiter:SetExecutionDivider(2)

	local id = BlockEnum[name]
	print(position)
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
