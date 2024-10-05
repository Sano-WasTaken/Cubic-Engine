local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtils = require(ReplicatedStorage.Utils.CmdrUtils)

local cmd: CmdrUtils.CMD = {
	Name = "GetServerInfo",
	Aliases = { "GSI" },
	Description = "Get the server stats.",
	Group = "Admin",
	Args = {},
}

return cmd
