local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Raycast = require(ReplicatedStorage.Utils.MouseRaycast)
local MouseNetwork = require(ReplicatedStorage.Networks.MouseNetwork)
local InventoryManager = require(ServerStorage.Managers.InventoryManager)
local BlockPosingManager = require(ServerStorage.Managers.BlockPosingManager)

local MouseRay = MouseNetwork.MouseRay:Server()

local function verifyDistance(raycastResult: RaycastResult, player: Player): boolean
	return (raycastResult.Position - player.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude < 30
end

MouseRay:On(function(player: Player, ray: Ray)
	local raycastResult = Raycast.Raycast(ray, 500, player.Character:GetChildren())

	if raycastResult and raycastResult.Instance and verifyDistance(raycastResult, player) then
		local handledItem = InventoryManager.getHandledItem(player)

		local position = (raycastResult.Instance.Position / 3)

		if handledItem then
			-- TODO: find a way to do it better (A Item Manager or Block Manager | optional)
			local isBlock, blockId = handledItem:IsBlock()
			local handledSlot = InventoryManager.getHandledSlot(player) + 3 * 9
			local inventory = InventoryManager.getInventory(player)

			if isBlock then
				--local correctPos = position + raycastResult.Normal
				BlockPosingManager(blockId, position, ray.Direction, raycastResult.Normal)
				inventory:IncrementItemAtIndex(handledSlot, -1)
			else
				print("not a block")
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
