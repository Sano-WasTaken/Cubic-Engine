local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local StatsNetwork = require(ReplicatedStorage.Networks.ServerStatsNetwork)

local Text = require(ReplicatedStorage.UI.Components.Text)
local DragFrame = require(ReplicatedStorage.UI.Components.DragFrame)
local ScreenGui = require(ReplicatedStorage.UI.Components.ScreenGui)

local player = Players.LocalPlayer

local updateStats = StatsNetwork.UpdateStats:Client()
local getStats = StatsNetwork.GetStats

local text, updateText = Text({
	Size = UDim2.fromScale(1, 1),
	AnchorPoint = Vector2.zero,
})

local dragger = DragFrame.CreateDraggedFrame(
	UDim2.fromOffset(200, 100),
	UDim2.fromOffset(200, 100),
	Vector2.zero,
	Roact.createFragment({ Text = text })
)

local screenGui, updateScreenGui, enabled = ScreenGui({ DraggedFrame = dragger })

local function UpdateText(stats: StatsNetwork.Stats)
	updateText({
		Text = `Total Memory : {math.floor(stats.Memory)} / 6500MB\nTotal Blocks : {stats.BlockCreated}\nTotal Block Rendered : {stats.BlockRendered}`,
	})
end

Roact.mount(screenGui, player:WaitForChild("PlayerGui"))

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.X and not gameProcessedEvent then
		updateScreenGui(not enabled:getValue())

		if enabled:getValue() then
			local success, stats = getStats:Call(true):Await()

			if success then
				UpdateText(stats)
			else
				warn(stats)
			end
		end
	end
end)

updateStats:On(function(stats: StatsNetwork.Stats)
	UpdateText(stats)
end)
