local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local listOfName = getmetatable(ItemEnum).__index

return function(register)
	local ItemType = {
		--Listable = true,
		DisplayName = "items",

		Transform = function(text: string)
			local find = register.Cmdr.Util.MakeFuzzyFinder(listOfName)

			local findItem = find(text)

			return findItem
		end,

		Autocomplete = function(items)
			return items
		end,

		Validate = function(items)
			return #items > 0, "No blocks with that name found."
		end,

		Parse = function(items)
			return items[1]
		end,
	}
	--register.Cmdr.Util.MakeListableType()
	register:RegisterType("items", ItemType)
end
