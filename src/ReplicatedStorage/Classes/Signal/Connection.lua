--!native

local Connection = {}

local function new(parent, callback: (...any) -> ()): Connection
	return setmetatable(
		{
			_parent = parent,
			_callback = callback,
		},
		{
			__index = Connection
		}
	)
end

export type Connection<T> = {
	Disconnect: (self: Connection) -> ()
}

function Connection._run(self: Connection, ...: any...)
	coroutine.wrap(self._callback)(...)
end

function Connection.Disconnect(self: Connection)
	local index = table.find(self._parent._connections, self)
	table.remove(self._parent._connections, index)
end

return {
	new = new
}
