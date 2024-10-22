local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtils = require(ReplicatedStorage.Utils.CmdrUtils)

local cmd: CmdrUtils.CMD = {
	Name = "DrawCircle",
	Aliases = { "DC" },
	Description = "Draw a circle with provided properties.",
	Group = "AdminPlus",
	Args = {
		{
			Type = "number",
			Name = "radius",
			Description = "The provided radius.",
		},
		{
			Type = "vector3",
			Name = "Position",
			Description = "The provided position.",
		},
		{
			Type = "blocks",
			Name = "Block",
			Description = "The id for the block",
			--Default = 0,
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
