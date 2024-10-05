local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local camera = workspace.CurrentCamera

local DEFAULT_SIZE = Vector2.new(1920, 1080)

local UIs = {}

RunService.RenderStepped:Connect(function(_: number)
	local viewportSize = camera.ViewportSize
	local vectorizedScale = viewportSize / DEFAULT_SIZE

	for _, updater in UIs do
		updater:set(vectorizedScale.X > vectorizedScale.Y and vectorizedScale.Y or vectorizedScale.X)
	end
end)

return function(scope: Fusion.Scope<typeof(Fusion)>, value: number)
	local scale = scope:Value(1)

	table.insert(UIs, scale)

	return scope:New("UIScale")({
		scale = scope:Computed(function(use)
			return use(scale) * value
		end),
	})
end
