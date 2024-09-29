local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtils = require(ReplicatedStorage.Utils.CmdrUtils)

local cmd: CmdrUtils.CMD = {
	Name = "DrawCircle",
	Aliases = { "DC" },
	Description = "Draw a circle with provided properties.",
	Group = "Admin",
	Args = {
		{
			Type = "number",
			Name = "radius",
			Description = "The provided radius.",
			Default = 10,
		},
		{
			Type = "vector3",
			Name = "Position",
			Description = "The provided position.",
			Default = 0,
		},
		{
			Type = "number",
			Name = "Block",
			Description = "The id for the block",
			Default = 0,
		},
		{
			Type = "boolean",
			Name = "Empty",
			Description = "Emptify the circle interior.",
			Default = false,
		},
	},
}

return cmd
