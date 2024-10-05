local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseController = require(script.Parent.BaseController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local IconButton = require(ReplicatedStorage.UI.Components.IconButton)

type IconParams = {
	IconId: string,
	Activated: ((input: InputObject, clickCount: number) -> nil)?,
}

local Controller = {
	Instance = nil :: Instance?,
	Icons = {} :: { IconParams },
}

Controller.IconButton = IconButton

function Controller.CreateIcons(self: Scope): { Instance }
	local buttons = {}

	for i, icon in self.Icons do
		local element = self:IconButton({
			Order = i,
			IconId = icon.IconId,
			Activated = icon.Activated,
		})

		buttons[i] = element
	end

	return buttons
end

function Controller.AddButtonIcon(
	self: Scope,
	iconId: string,
	callback: ((input: InputObject, clickCount: number) -> nil)?
): Scope
	table.insert(self.Icons, {
		IconId = iconId,
		Activated = callback,
	})

	return self
end

function Controller.Init(self: Scope)
	assert(self.Instance == nil, "Do not init twice !")

	local icons = self:CreateIcons()

	self.Instance = self:New("ScreenGui")({
		Name = "Icons",
		ResetOnSpawn = false,
		[children] = {
			self:New("Frame")({
				Size = UDim2.fromOffset(32, #icons * 32 + (#icons - 1) * 5),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 5, 0.5, 0),
				Transparency = 1,
				[children] = {
					self:New("UIListLayout")({
						Padding = UDim.new(0, 5),
						FillDirection = Enum.FillDirection.Vertical,
					}),
					self:Scale(3),
					icons,
				},
			}),
		},
	})
end

local scope = BaseController(Controller)

type Scope = typeof(scope)

return scope
