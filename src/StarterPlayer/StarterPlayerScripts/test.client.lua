local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local Text = require(ReplicatedStorage.UI.Components.Text)
local Shop = require(ReplicatedStorage.UI.Controllers.Shop)

Shop:CreatePage("Keys", "rbxassetid://72411379306174", "rbxassetid://93229239291611", 46)
	:CreateProduct("Keys", "DP", 0, ColorSequence.new(Color3.fromHex("#066aa8"), Color3.fromHex("#1446d1")))
	:CreateProduct(
		"Keys",
		"DP",
		0,
		ColorSequence.new(Color3.fromHex("#5d049d"), Color3.new(0.498039, 0.031373, 0.937255))
	)
	:CreateProduct("Keys", "DP", 0, ColorSequence.new(Color3.fromHex("9d0407"), Color3.fromHex("d14414")))
	:CreateProduct("Keys", "DP", 0, ColorSequence.new(Color3.fromHex("#acacac"), Color3.fromHex("#734332")))
	:CreatePage("Packs", "rbxassetid://88150838551306", "rbxassetid://134768540974493", 55)
	:CreateProduct("Packs", "DP", 0, ColorSequence.new(Color3.fromHex("#066aa8"), Color3.fromHex("#1446d1")))
	:CreateProduct(
		"Packs",
		"DP",
		0,
		ColorSequence.new(Color3.fromHex("#5d049d"), Color3.new(0.498039, 0.031373, 0.937255))
	)
	:CreateProduct("Packs", "DP", 0, ColorSequence.new(Color3.fromHex("9d0407"), Color3.fromHex("d14414")))
	:CreateProduct("Packs", "DP", 0, ColorSequence.new(Color3.fromHex("#acacac"), Color3.fromHex("#734332")))
	:Init()

Shop:SetPage("Keys")

Shop:Visible()
