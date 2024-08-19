--!native

local Connection = require(script.Connection)

local Signal = {}

local function new<T>(): Signal<T>
	return setmetatable({
		_connections = {},
	}, {
		__index = Signal,
	})
end

export type Connection = Connection.Connection

export type Signal<T> = {
	Connect: (self: Signal, callback: (...T) -> ()) -> Connection<T>,
	Fire: (self: Signal, ...T) -> (),
	Once: (self: Signal, callback: (...T) -> ()) -> Connection<T>,
}

function Signal.Connect(self: Signal, callback: (any...) -> ()): Connection
	local connection = Connection.new(self, callback)

	table.insert(self._connections, connection)

	return connection
end

function Signal.Once(self: Signal, callback: (any...) -> ()): Connection
	local connection: Connection
	connection = Connection.new(self, function(...)
		connection:Disconnect()
		callback(...)
	end)

	table.insert(self._connections, connection)

	return Connection
end

function Signal.Fire(self: Signal, ...: any...)
	for _, connection in self._connections do
		connection:_run(...)
	end
end

return {
	new = new,
}
