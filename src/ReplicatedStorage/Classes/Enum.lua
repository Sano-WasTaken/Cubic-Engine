local function new(enumerator: { string })
	--local inverse = {}
	return setmetatable(enumerator, {
		__index = function(_: {}, k: any)
			return table.find(enumerator, k)
		end,
	})
end

return {
	new = new,
}
