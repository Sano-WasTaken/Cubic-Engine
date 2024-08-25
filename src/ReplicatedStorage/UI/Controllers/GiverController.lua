local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local GiveInventory = require(ReplicatedStorage.UI.Components.GiveInventory)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)

local RequestGiveItem = InventoryNetwork.RequestGiveItem:Client()
local RequestClearInventory = InventoryNetwork.RequestClearInventory:Client()

local player = Players.LocalPlayer

local Controller = {
	Tree = nil :: Roact.Tree,
}

function Controller:Give(id: number)
	RequestGiveItem:Fire(id, 64)
end

function Controller:Clear()
	RequestClearInventory:Fire()
end

function Controller:Mount()
	if self.Tree then
		return
	end

	self.Tree = Roact.mount(
		Roact.createElement("ScreenGui", { Enabled = true }, {
			GiveInventory = GiveInventory.CreateGiver({
				Give = function(_, id)
					self:Give(id)
				end,
				Clear = function(_)
					self:Clear()
				end,
			}, 0.75),
		}),
		player:WaitForChild("PlayerGui"),
		"Giver Inventory"
	)
end

function Controller:Unmount()
	if self.Tree == nil then
		return
	end

	Roact.unmount(self.Tree)

	self.Tree = nil
end

return Controller
