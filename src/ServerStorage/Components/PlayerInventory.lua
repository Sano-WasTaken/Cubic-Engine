local ServerStorage = game:GetService("ServerStorage")
local Inventory = require(ServerStorage.Components.Inventory)

local PlayerInventory = {
	ClassName = "PlayerInventory",
}

setmetatable(PlayerInventory, { __index = Inventory })

function PlayerInventory:create()
	return setmetatable({
		SelectedSlot = 0,
		Size = 4 * 9,
		Container = {},
	}, { __index = Inventory })
end

function PlayerInventory:SetSelectedSlot(slot: number)
	self.SelectedSlot = slot
end

function PlayerInventory:GetSelectedSlot(): number
	return self.SelectedSlot
end

return PlayerInventory
