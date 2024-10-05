local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HotbarController = require(ReplicatedStorage.UI.Controllers.HotbarController)
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

HotbarController:Init({})
InventoryController:Init({})

HotbarController:Visible()

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	local slot = keybinds[input.KeyCode]

	if slot then
		slot = (slot == HotbarController:GetSelectedSlot()) and 0 or slot
		HotbarController:SetSelectedSlot(slot)
	end

	if input.KeyCode == Enum.KeyCode.E then
		if toggled then
			InventoryController:Visible()
			HotbarController:Invisible()
		else
			HotbarController:Visible()
			InventoryController:Invisible()
		end
		toggled = not toggled
	end
end)
