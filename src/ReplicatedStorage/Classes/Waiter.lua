local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Waiter = {}

local function new()
	return setmetatable({
		StartTime = os.clock(),
		Divider = 1,
		ExecutionTime = 0.1,
		MaxDuration = 0,
		Updated = Signal.new(),
	}, { __index = Waiter })
end

export type Waiter = typeof(Waiter) & {
	StartTime: number,
	Divider: number,
	ExecutionTime: number,
	MaxDuration: number,
	Updated: Signal.Signal<nil>,
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

		self.Updated:Fire()
	end
end

return {
	new = new,
}
