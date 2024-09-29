local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Hotbar = require(ReplicatedStorage.UI.Components.Hotbar)
local Inventory = require(ReplicatedStorage.UI.Components.Inventory)

--local scale = ScaleController(scope, 2.5)

--local size = 3 * 9

local toggled = true

local keybinds = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

Hotbar:Init({})
Inventory:Init({})

Hotbar:Visible()

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	local slot = keybinds[input.KeyCode]

	if slot and not gameProcessed then
		slot = (slot == Hotbar:GetSelectedSlot()) and 0 or slot
		Hotbar:SetSelectedSlot(slot)
	end

	if input.KeyCode == Enum.KeyCode.E then
		if toggled then
			Inventory:Visible()
			Hotbar:Invisible()
		else
			Hotbar:Visible()
			Inventory:Invisible()
		end
		toggled = not toggled
	end
end)
