local function new<T>(enumerator: T & {}): T
	--local inverse = {}

	local inverse = {}

	for name, id in enumerator :: {} do
		inverse[id] = name
	end

	return setmetatable(enumerator :: {}, {
		__index = inverse,
	}) :: any
end

return {
	new = new,
}
