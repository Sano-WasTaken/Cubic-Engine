local RunService = game:GetService("RunService")

local Module = { deltaTime = 0 }

RunService.Heartbeat:Connect(function(deltaTime)
	Module.deltaTime = deltaTime
end)

function Module:GetDeltaTime(): number
	return self.deltaTime
end

return Module
