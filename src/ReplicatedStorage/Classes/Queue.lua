local Queue = {}

local function new()
	return setmetatable({ container = {} }, {
		__index = Queue,
	})
end

function Queue:Insert(item: any)
	table.insert(self.container, item)
end

function Queue:Retrieve(): any
	local item = self.container[1]

	self.container[1] = nil

	local moveT = {}

	table.move(self.container, 2, table.maxn(self.container), 1, moveT)

	self.container = moveT

	return item
end

return {
	new = new,
}
