local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local DEFAULT_SPEED = 16
local SPEED_MULTIPLIER = 1.4

player.CharacterAdded:Connect(function(character)
	character = character
end)

UserInputService.InputBegan:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.LeftShift and character then
		character:FindFirstChildOfClass("Humanoid").WalkSpeed = DEFAULT_SPEED * SPEED_MULTIPLIER
	end
end)

UserInputService.InputEnded:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.LeftShift and character then
		character:FindFirstChildOfClass("Humanoid").WalkSpeed = DEFAULT_SPEED
	end
end)
