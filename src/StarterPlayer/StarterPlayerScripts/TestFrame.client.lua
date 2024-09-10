local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local FramedController = require(ReplicatedStorage.UI.Controllers.FramedController)

local test = FramedController.new("Structures")

local fullContentSize = test:GetFullContentSize()

test:SetSize(Vector2.new(400, 500))
	:ToggleCloseButton(true)
	:SetChildren("2Scrolling1", FramedController.FramedScrollingframe({ Size = UDim2.new(1, 0, 0, 150) }))
	:SetChildren(
		"3Text",
		FramedController.FramedTextLabel({ Size = Vector2.new(fullContentSize.X, 50), Text = "Settings" })
	)
	:SetChildren(
		"4Scrolling2",
		FramedController.FramedScrollingframe({ Size = UDim2.new(1, 0, 0, fullContentSize.Y - 110 + 55 - 150 - 5) })
	)

local toggle = false

UserInputService.InputBegan:Connect(function(input, _)
	if input.KeyCode == Enum.KeyCode.F2 then
		toggle = not toggle

		if toggle then
			test:Mount()
		else
			test:Unmount()
		end
	end
end)
