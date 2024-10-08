local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local AnimationController = require(ReplicatedStorage.Modules.AnimationController)
local InventoryNetwork = require(ReplicatedStorage.Networks.InventoryNetwork)
local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
local BlockLifeBarController = require(ReplicatedStorage.UI.Controllers.BlockLifeBarController)
local HotbarController = require(ReplicatedStorage.UI.Controllers.HotbarController)
local Raycast = require(ReplicatedStorage.Utils.MouseRaycast)

local player = Players.LocalPlayer

local mouse = player:GetMouse()

local highlight = Raycast.CreateHighlight()
BlockLifeBarController:Init()

local transparency = 0

RunService.RenderStepped:Connect(function()
	if player.Character == nil then
		return
	end

	local ray = Raycast.GetRay(mouse.X, mouse.Y)

	local raycastResult = Raycast.Raycast(ray, 500, player.Character:GetChildren())

	if raycastResult and raycastResult.Instance then
		local instance = raycastResult.Instance :: Part

		if highlight.Parent then
			highlight.Parent.Transparency = transparency
		end

		highlight.Parent = instance
		highlight.Adornee = instance

		transparency = instance.Transparency

		instance.Transparency = instance.Transparency > 0 and instance.Transparency or 0
	else
		if highlight.Parent then
			highlight.Parent.Transparency = transparency
		end

		highlight.Parent = nil
		highlight.Adornee = nil
	end
end)

local function Interact(id): (boolean, boolean?)
	local itemContent = ItemDataProvider:GetData(id)

	local isUsable = itemContent:IsUsable()

	if not isUsable then
		return false
	end

	if itemContent:IsA("BlockItem") then
		print(BlockEnum[id])
		return true, false
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

	--track.Looped = true
	--track:AdjustSpeed(speed ~= 0 and speed or 0.5)

	--track:Play()
	BlockLifeBarController:Set(1)
	BlockLifeBarController:Adornee(highlight.Adornee)

	highlight:GetPropertyChangedSignal("Adornee"):Connect(function()
		stop = true
	end)

	while total < speed do
		task.wait()

		local mouseButtonDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

		if not mouseButtonDown then
			BlockLifeBarController:Adornee()
			--track:Stop()
			AnimationController:Stop("Swing")
			return false
		end

		if stop and mouseButtonDown then
			id = HotbarController:GetItemIdInSelectedSlot()

			if id then
				BlockLifeBarController:Adornee()
				AnimationController:Stop("Swing")
				--track:Stop()

				return Interact(id)
			end
			--track:Stop()

			return false
		end

		dt = os.clock() - start

		BlockLifeBarController:Set(1 - (math.floor((total / speed) * 5) / 5))

		total += dt
		start = os.clock()
	end

	AnimationController:Stop("Swing")
	BlockLifeBarController:Adornee()
	--track:Stop()

	return true, true
end

local function Use(id: number?)
	local selectedSlot = HotbarController:GetSelectedSlot()
	id = id or HotbarController:GetItemIdInSelectedSlot()

	--local itemContent = ItemDataProvider:GetData(id :: number)

	if selectedSlot == 0 or id == nil then
		return
	end

	--local track: AnimationTrack = itemContent:Animate()

	--task.spawn(Animate, track, track.Length / itemContent.Speed)

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

		task.wait(0.1)

		Use(id)
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if player.Character == nil then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
		if #player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y) ~= 0 then
			return
		end

		Use()
	end
end)
