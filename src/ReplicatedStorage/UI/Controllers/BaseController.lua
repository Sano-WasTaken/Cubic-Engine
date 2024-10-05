local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local BaseController = {
	-- OVERRIDE IT !
	Instance = nil :: Instance?,
}

function BaseController.Init(_: BaseScope)
	error("Must override init method.")
end

function BaseController.Toggle(self: BaseScope)
	local active = self.Instance.Parent ~= nil

	if active then
		self:Invisible()
	else
		self:Visible()
	end
end

function BaseController.Visible(self: BaseScope)
	assert(self.Instance ~= nil, "Must be init !")

	self.Instance.Parent = Players.LocalPlayer.PlayerGui
end

function BaseController.Invisible(self: BaseScope)
	assert(self.Instance ~= nil, "Must be init !")

	self.Instance.Parent = nil
end

export type BaseScope = typeof(BaseController) & Fusion.Scope<typeof(Fusion)>

return function(Controller)
	setmetatable(Controller, { __index = BaseController })

	local scope = Fusion.scoped(Fusion, Controller)

	return scope
end
