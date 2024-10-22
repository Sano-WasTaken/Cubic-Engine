local Variant = {}

export type Variant = typeof(Variant) & {
	id: number,
	sid: string,
}

local function newVariant(sid: string)
	return setmetatable({ id = nil, sid = sid }, { __index = Variant })
end

return newVariant
