local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local BaseController = require(ReplicatedStorage.UI.Controllers.BaseController)

local Controller = {
	Istance = nil :: BillboardGui?,
}

function Controller.Init(self: Scope)
	self.ProgressValue = self:Value(1)

	self.Instance = self:New("BillboardGui")({
		StudsOffset = Vector3.new(0, 0, 0),
		AlwaysOnTop = true,
		Size = UDim2.fromScale(3, 0.5),
		[children] = {
			self:New("Frame")({
				Size = self:Computed(function(use)
					local scale = use(self.ProgressValue)

					return UDim2.fromScale(scale, 1)
				end),
				BackgroundColor3 = Color3.fromRGB(13, 190, 13),
			}),
		},
	})
end

function Controller.Adornee(self: Scope, adornee: Instance?)
	if adornee then
		self:Visible()
	else
		self:Invisible()
	end

	self.Instance.Adornee = adornee
end

function Controller.Set(self: Scope, scale: number)
	self.ProgressValue:set(scale)
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
