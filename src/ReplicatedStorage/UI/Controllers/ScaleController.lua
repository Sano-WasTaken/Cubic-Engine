local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Roact = require(ReplicatedStorage.Packages.Roact)

local binding, update = Roact.createBinding(1)

local camera = workspace.CurrentCamera
local DEFAULT_SIZE = 1920

RunService.RenderStepped:Connect(function(_)
	local scale = camera.ViewportSize.X / DEFAULT_SIZE
	update(scale)
end)

return binding
