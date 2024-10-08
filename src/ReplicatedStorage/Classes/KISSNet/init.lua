local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Event = require(script.Event)
local Function = require(script.Function)

type Event<T> = {
	listen: (callback: (data: T, player: Player?) -> nil) -> Signal.Connection,
	sendToServer: (data: T) -> nil,
	sendToClient: (player: Player, data: T) -> nil,
	sendToAll: (data: T) -> nil,
	sendToList: (playerList: { Player }, data: T) -> nil,
}

type Function<T, K> = {
	invoke: (callback: (data: T, player: Player?) -> K) -> nil,
	requestToServer: (data: T) -> K,
	requestToClient: (player: Player, data: T) -> K,
}

--[[
Create an remote Event that allow you to pass values.
]]
local function defineEvent<T>(_: () -> T): Event<T>
	return function(namespace: string, packet: string)
		local remote = Event.getRemote(namespace)

		local listener: Signal.Signal<T, Player?> = Signal.new()

		if RunService:IsServer() then
			remote.OnServerEvent:Connect(function(player: Player, data: T, name: string)
				if name == packet then
					listener:Fire(data, player)
				end
			end)
		else
			remote.OnClientEvent:Connect(function(data: T, name: string)
				if name == packet then
					listener:Fire(data)
				end
			end)
		end

		return {
			listen = function(callback: (data: T, player: Player?) -> nil): Signal.Connection
				return listener:Connect(function(...)
					callback(...)
				end)
			end,

			sendToServer = function(data: T)
				assert(RunService:IsClient())

				remote:FireServer(data, packet)
			end,

			sendToClient = function(player: Player, data: T)
				assert(RunService:IsServer())

				remote:FireClient(player, data, packet)
			end,

			sendToAll = function(data: T)
				assert(RunService:IsServer())

				remote:FireAllClients(data, packet)
			end,

			sendToList = function(playerList: { Player }, data: T)
				assert(RunService:IsServer())

				for _, player in playerList do
					remote:FireClient(player, data, packet)
				end
			end,
		}
	end :: any
end

local function defineFunction<T, K>(_: () -> T, _: () -> K): Function<T, K>
	return function(namespace: string, packet: string)
		local remote = Function.getRemote(namespace)

		return {
			invoke = function(callback: (data: T, player: Player?) -> K)
				if RunService:IsServer() then
					remote.OnServerInvoke = function(player: Player, data: T, name: string)
						if name == packet then
							return callback(data, player) :: K
						end
					end
				else
					remote.OnClientInvoke = function(data: T, name: string)
						if name == packet then
							return callback(data) :: K
						end
					end
				end
			end,

			requestToServer = function(data: T): K
				assert(RunService:IsClient())

				return remote:InvokeServer(data, packet)
			end,

			requestToClient = function(player: Player, data: T): K
				assert(RunService:IsServer())

				return remote:InvokeClient(player, data, packet)
			end,
		}
	end :: any
end

local function defineNamespace<T>(namespace: string, packets: T & {}): T & {}
	local calledPackets = {} :: T & {}

	for name, packet in packets :: {} do
		calledPackets[name] = packet(namespace, name)
	end

	return calledPackets
end

return {
	--	Definitions.
	defineNamespace = defineNamespace,
	defineEvent = defineEvent,
	defineFunction = defineFunction,

	--	Types.
	string = "" :: string,
	number = 0 :: number,
	optional = function<T>(type: T): T?
		return type
	end,
	array = function<T>(type: T): { T }
		return { type }
	end,
	dict = function<T>(t: T): T
		return t
	end,
	map = function<T, K>(key: T, value: K): { [T]: K }
		return { [key] = value }
	end,
	instance = Instance.new,
	buffer = buffer.create(0) :: buffer,
	cframe = CFrame.identity :: CFrame,
	vector3 = Vector3.zero :: Vector3,
	vector2 = Vector2.zero :: Vector2,
	any = nil :: any,
	unknown = nil :: unknown,
	nothing = nil :: nil,
}
