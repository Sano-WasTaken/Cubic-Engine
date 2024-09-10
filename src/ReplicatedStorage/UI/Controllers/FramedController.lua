local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local FramedContainer = require(ReplicatedStorage.UI.Components.FramedContainer)
local FramedTextButton = require(ReplicatedStorage.UI.Components.FramedTextButton)
local Framed = require(ReplicatedStorage.UI.Components.Framed)
local FramedTextLabel = require(ReplicatedStorage.UI.Components.FramedTextLabel)
local FramedScrollingframe = require(ReplicatedStorage.UI.Components.FramedScrollingframe)

local Controller = {}

local function new(title: string)
	return setmetatable({
		Tree = nil :: Roact.Tree?,
		Title = title,
		Size = Vector2.new(400, 500),
		Padding = 5,
		HasCloseButton = true,
		Childrens = {} :: { [string | number]: Roact.Element },
	}, {
		__index = Controller,
	})
end

function Controller:Update()
	if self.Tree == nil then
		return
	end

	local props = self:_getProps()

	self.Tree = Roact.update(self.Tree, Roact.createElement(FramedContainer.FramedContainer, props, self.Childrens))

	return self
end

function Controller:SetSize(size: Vector2)
	self.Size = size

	return self
end

function Controller:GetFullContentSize()
	return Vector2.new(self.Size.X - (2 * self.Padding), self.Size.Y - 50 - (3 * self.Padding))
end

function Controller:ToggleCloseButton(state: boolean)
	if state ~= nil then
		self.HasCloseButton = state
	else
		self.HasCloseButton = not self.HasCloseButton
	end

	self:Update()

	return self
end

function Controller:_getProps()
	local props: FramedContainer.ContainerProps = {
		HasCloseButton = self.HasCloseButton,
		Padding = self.Padding,
		Size = self.Size,
		Title = self.Title,
		Activated = function()
			self:Unmount()
		end,
	}

	return props
end

function Controller:SetChildren(name: string, element: Roact.Element)
	self.Childrens[name] = element

	self:Update()

	return self
end

function Controller:Unmount()
	if self.Tree == nil then
		return
	end

	Roact.unmount(self.Tree)

	self.Tree = nil

	return self
end

function Controller:Mount()
	if self.Tree ~= nil then
		return
	end

	local props = self:_getProps()

	self.Tree = Roact.mount(
		Roact.createElement(FramedContainer, props, self.Childrens),
		Players.LocalPlayer:WaitForChild("PlayerGui"),
		self.Title
	)

	return self
end

return {
	new = new,
	FramedTextButton = FramedTextButton,
	Framed = Framed,
	FramedTextLabel = FramedTextLabel,
	FramedScrollingframe = FramedScrollingframe,
}
