local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Screen = script.Parent
local loadingBar = Screen.MainFrame.CanvasGroup.LoadingBar
local loadingText = Screen.MainFrame.CanvasGroup.LoadingText

Screen.Parent = player.PlayerGui
Screen.Enabled = true

local function setBar(sizeX: number, text: string)
	loadingText.Text = text

	local tween = TweenService:Create(loadingBar.Bar, TweenInfo.new(0.5), { Size = UDim2.fromScale(sizeX, 1) })
	tween:Play()
end

setBar(0, "Chunks Decompression...")

local LoadingScreenNetwork = require(ReplicatedStorage:WaitForChild("Networks").LoadingScreenNetwork)

LoadingScreenNetwork.IncrementLoadingBar.listen(function(data)
	setBar(data.index / data.max, `Loading chunks: {data.index}/{data.max}`)
end)

LoadingScreenNetwork.LoadingSuccess.listen(function()
	setBar(1, "Welcome To Our Game !")

	local tween1 = TweenService:Create(Screen.MainFrame, TweenInfo.new(2.5), { Transparency = 1 })
	local tween2 = TweenService:Create(Screen.MainFrame.CanvasGroup, TweenInfo.new(2.5), { GroupTransparency = 1 })

	tween1:Play()
	tween2:Play()

	tween1.Completed:Wait()

	Screen:Destroy()
end)
