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

export type Connection<T> = Connection.Connection<T>

export type Signal<T> = {
	Connect: (self: Signal<T>, callback: (...T) -> ()) -> Connection<T>,
	Fire: (self: Signal<T>, ...T) -> (),
	Once: (self: Signal<T>, callback: (...T) -> ()) -> Connection<T>,
	Wait: (self: Signal<T>) -> T,
}

function Signal.Connect<T>(self: Signal<T>, callback: (any...) -> ()): Connection<T>
	local connection = Connection.new(self, callback)

	table.insert(self._connections, connection)

	return connection
end

function Signal.Wait<T>(self: Signal<T>): T
	local thread = coroutine.running()

	local results

	local connection: Connection<T>
	connection = Connection.new(self, function(...)
		results = ...
		coroutine.resume(thread)
		connection:Disconnect()
	end)

	table.insert(self._connections, connection)

	coroutine.yield(results)

	return results
end

function Signal.Once<T>(self: Signal<T>, callback: (any...) -> ()): Connection<T>
	local connection: Connection<T>
	connection = Connection.new(self, function(...)
		connection:Disconnect()
		callback(...)
	end)

	table.insert(self._connections, connection)

	return Connection
end

function Signal.Fire<T>(self: Signal<T>, ...: any...)
	for _, connection in self._connections do
		connection:_run(...)
	end
end

return {
	new = new,
}
