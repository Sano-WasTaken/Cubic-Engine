local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScaleController = require(script.Parent.ScaleController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local BaseController = {
	-- OVERRIDE IT !
	Instance = nil :: Instance?,
	Init = nil :: ((self: BaseScope) -> nil)?,
}

--[[
function BaseController.Init(_: BaseScope)
	error("Must override init method.")


end]]

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
	Controller.Scale = ScaleController

	local scope = Fusion.scoped(Fusion, Controller, BaseController)

	return scope
end
