local RunService = game:GetService("RunService")
local Waiter = {}

local function new()
	return setmetatable({
		StartTime = os.clock(),
		Divider = 1,
		ExecutionTime = 0.1,
		MaxDuration = 0,
	}, { __index = Waiter })
end

export type Waiter = typeof(Waiter) & {
	StartTime: number,
	Divider: number,
	ExecutionTime: number,
	MaxDuration: number,
}

function Waiter.Start(self: Waiter)
	self.StartTime = os.clock()
end

function Waiter.SetExecutionTime(self: Waiter, execution: number)
	self.ExecutionTime = execution
end

function Waiter.SetExecutionDivider(self: Waiter, divider: number)
	self.Divider = divider
end

function Waiter.Update(self: Waiter)
	if os.clock() - self.StartTime >= self.MaxDuration then
		local delta = RunService.Heartbeat:Wait()

		self.MaxDuration = math.clamp(delta / self.Divider, 0, self.ExecutionTime)

		self:Start()
	end
end

return {
	new = new,
}
