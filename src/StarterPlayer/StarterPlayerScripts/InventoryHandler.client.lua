local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local InventoryController = require(ReplicatedStorage.UI.Controllers.InventoryController)
local HotbarController = require(ReplicatedStorage.UI.Controllers.HotbarController)
local GiverController = require(ReplicatedStorage.UI.Controllers.GiverController)

local UpdateInventory = InventoryNetwork.UpdateInventory:Client()

UpdateInventory:On(function(inventory)
	InventoryController:Update(inventory)
	HotbarController:Update(inventory)
end)

local toggled = true

local function Toggle(active: boolean?)
	local _, items = InventoryNetwork.GetInventory:Call():Await()
	toggled = (active ~= nil) and active or not toggled

	print(items)

	if toggled then
		HotbarController:Unmount()
		InventoryController:Init(items)
	else
		HotbarController:Init(items)
		InventoryController:Unmount()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.E and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
		if GiverController.Tree ~= nil then
			GiverController:Unmount()
		else
			GiverController:Mount()
		end

		return
	end

	if input.KeyCode == Enum.KeyCode.E and not gameProcessedEvent then
		Toggle()
	end
end)

Toggle(false)
