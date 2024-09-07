local function new(enumerator: { string })
	local inverse = {}

	for i, v in enumerator do
		inverse[v] = i
	end
	enumerator = setmetatable(enumerator, {
		__index = inverse,
	})

	return enumerator
end

return {
	new = new,
}
