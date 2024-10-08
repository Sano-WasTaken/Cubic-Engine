local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local BaseController = require(ReplicatedStorage.UI.Controllers.BaseController)

local Controller = {}

function Controller.Init(self: Scope)
	self.ChunkValue = self:Value({
		cx = 0,
		cy = 0,
	})

	self.Instance = self:New("ScreenGui")({
		ResetOnSpawn = false,
		[children] = {
			self:New("Frame")({
				Size = UDim2.new(0.3, 0, 1, 0),
				BackgroundTransparency = 1,
				[children] = {
					self:New("TextLabel")({
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(0.5, 0.05),
						TextScaled = true,
						Text = self:Computed(function(use)
							local coords = use(self.ChunkValue)

							return "Chunk: " .. coords.cx .. " | " .. coords.cy
						end),
					}),
				},
			}),
		},
	})
end

function Controller.Set(self: Scope, cx: number, cy: number)
	self.ChunkValue:set({
		cx = cx,
		cy = cy,
	})
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
