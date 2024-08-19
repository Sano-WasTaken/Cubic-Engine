local Queue = {}

local function new<T>(): Queue<T>
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

type Queue<T> = {
	Insert: (self: Queue<T>, item: T) -> (),
	Retrieve: (self: Queue<T>) -> T?,
}

return {
	new = new,
}
