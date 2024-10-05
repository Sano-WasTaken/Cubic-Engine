local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtils = require(ReplicatedStorage.Utils.CmdrUtils)

local cmd: CmdrUtils.CMD = {
	Name = "ClearItem",
	Aliases = { "CItem" },
	Description = "Clear your inventory.",
	Group = "Admin",
	Args = {},
}

return cmd
