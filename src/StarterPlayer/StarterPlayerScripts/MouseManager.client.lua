local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AnimationController = require(ReplicatedStorage.Modules.AnimationController)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)
local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
local BlockLifeBarController = require(ReplicatedStorage.UI.Controllers.BlockLifeBarController)
local HotbarController = require(ReplicatedStorage.UI.Controllers.HotbarController)
local Raycast = require(ReplicatedStorage.Utils.MouseRaycast)

local player = Players.LocalPlayer

local mouse = player:GetMouse()

local selectionBox = Raycast.CreateSelectionBox()
BlockLifeBarController:Init()

local transparency = 0

local part = Instance.new("Part")

part.Size = Vector3.one / 4
part.Shape = Enum.PartType.Ball
part.BrickColor = BrickColor.Red()
part.Material = Enum.Material.Neon
part.CanCollide = false
part.CanQuery = false

local DEBUG = RunService:IsStudio()

RunService.RenderStepped:Connect(function()
	if player.Character == nil then
		return
	end

	local ray = Raycast.GetRay(mouse.X, mouse.Y)

	local raycastResult = Raycast.Raycast(ray, 500, player.Character:GetChildren())

	if raycastResult and raycastResult.Instance then
		local instance = raycastResult.Instance :: Part

		if DEBUG then
			part.Parent = workspace
			part.Position = raycastResult.Position
		end

		if selectionBox.Parent then
			selectionBox.Parent.Transparency = transparency
		end

		selectionBox.Parent = instance
		selectionBox.Adornee = instance

		transparency = instance.Transparency

		instance.Transparency = instance.Transparency > 0 and instance.Transparency or 0
	else
		if selectionBox.Parent then
			selectionBox.Parent.Transparency = transparency
		end

		part.Parent = nil
		selectionBox.Parent = nil
		selectionBox.Adornee = nil
	end
end)

local function Interact(id): (boolean, boolean?)
	local itemContent = ItemDataProvider:GetData(id)
	local blockContent = BlockDataProvider:GetData(selectionBox.Parent and tonumber(selectionBox.Parent.Name) or 0)

	local isUsable = itemContent:IsUsable()

	local delta = UserInputService:GetMouseDelta().Magnitude

	if UserInputService.TouchEnabled and not (delta < 0.1 and delta > -0.1) then
		return false
	end

	if not isUsable then
		return false
	end

	if itemContent:IsA("BlockItem") then
		AnimationController:Animate("Swing", itemContent)

		return true, false
	end

	if blockContent == nil or blockContent:IsUnbreakable() then
		return false
	end

	if not itemContent:IsA("Tool") then
		return false
	end

	local start = os.clock()
	local dt = 0
	local total = 0
	local stop = false
	local speed = itemContent.Speed

	AnimationController:Animate("Swing", itemContent)
	BlockLifeBarController:Set(1)
	BlockLifeBarController:Adornee(selectionBox.Adornee)

	local connection = selectionBox:GetPropertyChangedSignal("Adornee"):Connect(function()
		stop = true
	end)

	while total < speed do
		task.wait()

		local mouseButtonDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		--or UserInputService.TouchEnabled

		--print(UserInputService.TouchEnabled)

		if not mouseButtonDown then
			BlockLifeBarController:Adornee()
			AnimationController:Stop("Swing")
			connection:Disconnect()
			return false
		end

		if stop and mouseButtonDown then
			id = HotbarController:GetItemIdInSelectedSlot()
			connection:Disconnect()
			if id then
				BlockLifeBarController:Adornee()
				AnimationController:Stop("Swing")

				return Interact(id)
			end

			return false
		end

		dt = os.clock() - start

		BlockLifeBarController:Set(1 - (math.floor((total / speed) * 5) / 5))

		total += dt
		start = os.clock()
	end

	AnimationController:Stop("Swing")
	BlockLifeBarController:Adornee()

	local part = selectionBox.Adornee

	connection:Disconnect()

	if part then
		selectionBox.Parent = nil
		part:Destroy()
		selectionBox.Adornee = nil
	end

	return true, true
end

local function Use(id: number?)
	local selectedSlot = HotbarController:GetSelectedSlot()
	id = id or HotbarController:GetItemIdInSelectedSlot()

	if selectedSlot == 0 or id == nil then
		return
	end

	local success, canBeReUse = Interact(id)

	if not success then
		return
	end

	local ray = Raycast.GetRay(mouse.X, mouse.Y)

	InventoryNetwork.MouseInteraction.sendToServer({
		origin = ray.Origin,
		direction = ray.Direction,
		selectedSlot = selectedSlot,
	})

	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and canBeReUse then
		id = HotbarController:GetItemIdInSelectedSlot()

		task.wait()

		Use(id)
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if player.Character == nil then
		return
	end

	if
		(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		and not gameProcessedEvent
	then
		if not UserInputService.TouchEnabled and #player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y) ~= 0 then
			return
		end
		Use()
	end
end)

UserInputService.TouchStarted:Connect(function(a0: InputObject, a1: boolean)
	print(a0, a1)
end)

UserInputService.TouchPan:Connect(function(...)
	print(...)
end)

UserInputService.TouchEnded:Connect(function(a0: InputObject, a1: boolean)
	print(a0, a1)
end)
