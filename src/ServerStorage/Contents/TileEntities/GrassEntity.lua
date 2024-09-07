local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TileEntity = require(ServerStorage.Classes.TileEntity)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local GrassEntity = TileEntity:extends({
	ClassName = "Grass",
	Id = BlockEnum.Grass,
	ExecutionContext = "default",
})

local function new(content: {})
	return setmetatable({
		Content = content,
	}, { __index = GrassEntity })
end

function GrassEntity:ResetProgress()
	self.Progress = 0
	self.SpreadTime = math.random() * 20
end

function GrassEntity:Spread()
	print("spread grass")
end

-- Overridden
function GrassEntity:Init()
	print("init grass")
	self:ResetProgress()
end

-- Overridden
function GrassEntity:Tick(dt: number)
	if self.Progress <= self.SpreadTime then
		self.Progress += dt
	else
		self:Spread()
		self:ResetProgress()
	end
end

return {
	new = new,
	Class = GrassEntity,
}
