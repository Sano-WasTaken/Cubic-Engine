local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Raycast = require(ReplicatedStorage.Utils.MouseRaycast)
local MouseNetwork = require(ReplicatedStorage.Networks.MouseNetwork)

local MouseRay = MouseNetwork.MouseRay:Client()

local player = Players.LocalPlayer

local mouse = player:GetMouse()

local highlight = Raycast.CreateHighlight()

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

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if player.Character == nil then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
		if #player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y) ~= 0 then
			return
		end

		MouseRay:Fire(Raycast.GetRay(mouse.X, mouse.Y))
	end
end)
