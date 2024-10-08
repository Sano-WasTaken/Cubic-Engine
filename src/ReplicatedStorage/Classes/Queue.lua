local Queue = {}

local function new<T>(): Queue<T>
	return setmetatable({ container = {} }, {
		__index = Queue,
	}) :: any
end

function Queue:Insert<T>(item: T)
	table.insert(self.container, item)
end

function Queue.IsEmpty<T>(self: Queue<T>)
	return #self.container == 0
end

function Queue.Retrieve<T>(self: Queue<T>): T?
	return table.remove(self.container, 1)
end

function Queue.Remove<T>(self: Queue<T>, index: number)
	table.remove(self.container, index)
end

function Queue:Clear()
	table.clear(self.container)
end

export type Queue<T> = typeof(Queue) & {
	container: { T },
}

return {
	new = new,
}
