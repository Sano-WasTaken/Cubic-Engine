local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local BlockType = {
	Listable = true,

	Autocomplete = function()
		return BlockEnum
	end,

	Validate = function(block)
		return (block ~= nil and BlockEnum[block] ~= nil), "No blocks with that name found."
	end,
}

return BlockType
