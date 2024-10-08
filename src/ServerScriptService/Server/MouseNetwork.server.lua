local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockItemContent = require(ReplicatedStorage.Classes.BlockItemContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local WorldManager = require(ServerStorage.Managers.WorldManager)
local Block = require(ServerStorage.Classes.Block)
local PlayerInventoryGetter = require(ServerStorage.Managers.PlayerInventoryGetter)

local function verifyDistance(raycastResult: RaycastResult, character: Model & { HumanoidRootPart: Part }): boolean
	return (raycastResult.Position - character.HumanoidRootPart.Position).Magnitude < 30
end

InventoryNetwork.SelectSlot.listen(function(slot: number, player: Player): nil
	local character = player.Character or player.CharacterAdded:Wait()

	local inventory = PlayerInventoryGetter.getInventory(player)

	local item

	if slot ~= 0 then
		item = inventory:GetItemAtIndex(slot + 3 * 9)
	end

	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		tool:Destroy()
		tool = nil
	end

	if item then
		local content = item:GetContent()

		tool = content:GetTool()

		tool.Parent = character
	end

	return
end)

InventoryNetwork.MouseInteraction.listen(
	function(data: { direction: Vector3, origin: Vector3, selectedSlot: number }, player: Player)
		local result = WorldManager:LocalRaycastV2(data.origin, data.direction, 100)
		local selectedSlot = data.selectedSlot

		if result and result.Block and selectedSlot ~= 0 then
			local block = result.Block
			local inventory = PlayerInventoryGetter.getInventory(player)

			local item = inventory:GetItemAtIndex(selectedSlot + 3 * 9)

			if item == nil then
				return
			end

			local content = item:GetContent()

			if not content:IsUsable() then
				return
			end

			--print(item, content:IsUsable(), content:IsA("BlockItem"), content:IsA("Tool"))

			if content:IsA("BlockItem") then
				local blockContent: BlockContent.BlockContent = content:GetBlock()

				local position = Vector3.new(block:GetPosition()) + result.Normal

				local newBlock = Block.new(blockContent:GetID()):SetPosition(position.X, position.Y, position.Z)

				WorldManager:Insert(newBlock)

				return
			end

			if content:IsA("Tool") then
				WorldManager:Delete(block:GetPosition())

				return
			end
		end
	end
)

--[[MouseRay:On(function(player: Player, ray: Ray)
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
end)]]

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
