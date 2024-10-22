local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local listOfName = getmetatable(BlockEnum).__index

return function(register)
	local BlockType = {
		DisplayName = "blocks",

		Transform = function(text: string)
			local find = register.Cmdr.Util.MakeFuzzyFinder(listOfName)

			local findBlock = find(text)

			return findBlock
		end,

		Autocomplete = function(blocks)
			return blocks
		end,

		Validate = function(blocks)
			return #blocks > 0, "No blocks with that name found."
		end,

		Parse = function(blocks)
			return blocks[1]
		end,
	}
	--register.Cmdr.Util.MakeListableType()
	register:RegisterType("blocks", BlockType)
end
