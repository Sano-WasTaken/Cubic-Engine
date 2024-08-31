local function new(enumerator: {})
	local inverse = {}

	for i, v in enumerator do
		inverse[v] = i
	end

	local self = setmetatable(enumerator, {
		__index = inverse,
	})

	return self
end

return {
	new = new,
}
