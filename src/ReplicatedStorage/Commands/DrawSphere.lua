local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtils = require(ReplicatedStorage.Utils.CmdrUtils)

local cmd: CmdrUtils.CMD = {
	Name = "DrawSphere",
	Aliases = { "DSP" },
	Description = "Draw a Sphere with provided properties.",
	Group = "AdminPlus",
	Args = {
		{
			Type = "number",
			Name = "radius",
			Description = "The provided radius.",
			Default = 10,
		},
		{
			Type = "vector3",
			Name = "offset",
			Description = "The provided position.",
			Default = Vector3.zero,
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
			Description = "Emptify the Sphere interior.",
			Default = false,
		},
	},
}

return cmd
