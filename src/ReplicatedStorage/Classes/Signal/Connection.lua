--!native

local Connection = {}

local function new<T>(parent, callback: (...any) -> ()): Connection<T>
	return setmetatable({
		_parent = parent,
		_callback = callback,
	}, {
		__index = Connection,
	})
end

export type Connection<T> = {
	Disconnect: (self: Connection<T>) -> (),
}

function Connection._run<T>(self: Connection<T>, ...: any...)
	coroutine.wrap(self._callback)(...)
end

function Connection.Disconnect<T>(self: Connection<T>)
	local index = table.find(self._parent._connections, self)
	table.remove(self._parent._connections, index)
end

return {
	new = new,
}
