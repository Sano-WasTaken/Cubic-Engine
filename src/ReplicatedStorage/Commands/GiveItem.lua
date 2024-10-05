local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtils = require(ReplicatedStorage.Utils.CmdrUtils)

local cmd: CmdrUtils.CMD = {
	Name = "GiveItem",
	Aliases = { "GItem" },
	Description = "Give item to yourself.",
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "id",
			Description = "The provided item id.",
		},
		{
			Type = "number",
			Name = "amount",
			Description = "The provided position.",
			Default = 64,
		},
	},
}

return cmd
