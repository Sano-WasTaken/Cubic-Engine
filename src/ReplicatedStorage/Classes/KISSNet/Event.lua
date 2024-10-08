local RunService = game:GetService("RunService")

local eventFolder: Folder = script.Parent.Events

-- TODO: Add Unreliable Event support.
local function createEvent(name: string, _: boolean?): RemoteEvent
	local remote = eventFolder:FindFirstChild(name) or Instance.new("RemoteEvent")

	remote.Name = name

	remote.Parent = eventFolder

	return remote
end

local function getRemote(name: string): RemoteEvent?
	local remote

	if RunService:IsServer() then
		remote = createEvent(name)

		return remote
	end

	local start = os.clock()

	repeat
		remote = eventFolder:FindFirstChild(name)

		if remote == nil then
			task.wait()
		end

	until remote ~= nil or os.clock() - start >= 1

	if os.clock() - start >= 1 then
		warn("Attempt to find the remote failed:", name)
	end

	return remote
end

return {
	getRemote = getRemote,
}
