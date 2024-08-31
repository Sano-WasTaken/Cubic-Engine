local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Raycast = require(ReplicatedStorage.Utils.MouseRaycast)
local MouseNetwork = require(ReplicatedStorage.Networks.MouseNetwork)
local InventoryManager = require(ServerStorage.Managers.InventoryManager)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Item = require(ServerStorage.Classes.Item)
local Block = require(ServerStorage.Classes.Block)

local MouseRay = MouseNetwork.MouseRay:Server()

local function verifyDistance(raycastResult: RaycastResult, player: Player): boolean
	return (raycastResult.Position - player.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 30
end

--TODO: demain tu refactoring tout ça pd
MouseRay:On(function(player: Player, ray: Ray)
	local raycastResult = Raycast.Raycast(ray, 500, player.Character:GetChildren())

	if raycastResult and raycastResult.Instance and verifyDistance(raycastResult, player) then
		local handledItem = InventoryManager.getHandledItem(player)
		local position: Vector3 = (raycastResult.Instance.Position / 3)
		local block = WorldManager:GetBlock(position.X, position.Y, position.Z)

		if handledItem then
			-- TODO: find a way to do it better (A Item Manager or Block Manager | optional)
			local handledSlot = InventoryManager.getHandledSlot(player) + 3 * 9
			local inventory = InventoryManager.getInventory(player)

			if not handledItem:IsUsable() then
				return
			end

			if handledItem:IsA("BlockItem") then
				--local correctPos = position + raycastResult.Normal

				local correctPos: Vector3 = handledItem:Use(position, raycastResult.Normal)

				WorldManager:Insert(
					Block.new(handledItem:GetBlock():GetID()):SetPosition(correctPos.X, correctPos.Y, correctPos.Z)
				)

				inventory:IncrementItemAtIndex(handledSlot, -1)
			elseif handledItem:IsA("Tool") then
				local positions: { Vector3 } = handledItem:Use(position, raycastResult.Normal)

				local items = {}

				if inventory:IsFullFilter(block:GetLoot()) and inventory:IsFull() then
					return
				end

				for _, blockPosition in positions do
					local block = WorldManager:GetBlock(blockPosition.X, blockPosition.Y, blockPosition.Z)

					WorldManager:Delete(blockPosition.X, blockPosition.Y, blockPosition.Z)

					local item = Item.new(block:GetLoot()):SetAmount(1)

					table.insert(items, item)
				end

				for _, item in items do
					inventory:AddItem(item)
				end
			else
				print("not a block", "not a tool")
			end
		end
	end
end)

--[[
pose:On(function(player: Player, ray: Ray)
	local raycastResult = Raycast.Raycast(ray, 500, player.Character:GetChildren())
	
	if raycastResult and raycastResult.Instance and verifyDistance(raycastResult, player) then
		local position = (raycastResult.Instance.Position / 3) + raycastResult.Normal
		
		if Raycast.GetOverlap(position * 3) then
			WorldManager.insert(Block.new(1):SetPosition(position.X, position.Y, position.Z))
		end
		
	end
end)

breakk:On(function(player: Player, ray: Ray)
	local raycastResult = Raycast.Raycast(ray, 500, player.Character:GetChildren())

	if raycastResult and raycastResult.Instance and verifyDistance(raycastResult, player) then
		local position = (raycastResult.Instance.Position / 3)
		local id = WorldManager.getBlock(position.X, position.Y, position.Z):GetID()

		if BlockDataProvider:GetData(id).Unbreakable then
			return
		end

		local blockId = WorldManager.getBlock(position.X, position.Y, position.Z):GetID()

		local itemData = ItemDataProvider:GetData(blockId)
		local playerInventory = InventoryManager.getInventory(player)
		
		--playerInventory:AddItem(Item.new(id))

		WorldManager.delete(position.X, position.Y, position.Z)
	end
end)]]
