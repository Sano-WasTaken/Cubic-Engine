local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Hotbar = require(ReplicatedStorage.UI.Components.Hotbar)
local InventoryController = require(ReplicatedStorage.UI.Controllers.InventoryController)

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
InventoryController:Init({})

Hotbar:Visible()

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	local slot = keybinds[input.KeyCode]

	if slot then
		slot = (slot == Hotbar:GetSelectedSlot()) and 0 or slot
		Hotbar:SetSelectedSlot(slot)
	end

	if input.KeyCode == Enum.KeyCode.E then
		if toggled then
			InventoryController:Visible()
			Hotbar:Invisible()
		else
			Hotbar:Visible()
			InventoryController:Invisible()
		end
		toggled = not toggled
	end
end)
