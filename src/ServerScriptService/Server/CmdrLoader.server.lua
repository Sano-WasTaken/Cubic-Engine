local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Cmdr = require(ReplicatedStorage.Packages.Cmdr)

Cmdr:RegisterDefaultCommands()
Cmdr:RegisterCommandsIn(ReplicatedStorage.Commands)

Cmdr.Registry:RegisterHook("BeforeRun", function(context)
	if
		(
			context.Group == "Admin"
			and Players:GetPlayerByUserId(context.Executor.UserId):GetRankInGroup(game.CreatorId) == 1
		)
		or (
			context.Group == "AdminPlus"
			and Players:GetPlayerByUserId(context.Executor.UserId):GetRankInGroup(game.CreatorId) ~= 255
		)
	then
		return "You don't have the permission to execute this command."
	end
end)

Cmdr.Registry:RegisterHook("AfterRun", function(context)
	warn(context.Response)
	return context.Response
end)
