local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shop = require(ReplicatedStorage.UI.Controllers.Shop)

Shop:CreatePage("Keys")
	:CreateProduct(
		"Keys",
		"GamePass",
		938237969,
		ColorSequence.new(Color3.fromHex("#066aa8"), Color3.fromHex("#1446d1"))
	)
	:CreateProduct(
		"Keys",
		"Product",
		2147446427,
		ColorSequence.new(Color3.fromHex("#5d049d"), Color3.new(0.498039, 0.031373, 0.937255))
	)
	:CreateProduct("Keys", "Product", 0, ColorSequence.new(Color3.fromHex("9d0407"), Color3.fromHex("d14414")))
	:CreateProduct("Keys", "Product", 0, ColorSequence.new(Color3.fromHex("#acacac"), Color3.fromHex("#734332")))
	:CreatePage("Packs")
	:CreatePage("ehehehehehah")
	:CreateProduct("Packs", "Product", 0, ColorSequence.new(Color3.fromHex("#066aa8"), Color3.fromHex("#1446d1")))
	:CreateProduct(
		"Packs",
		"Product",
		0,
		ColorSequence.new(Color3.fromHex("#5d049d"), Color3.new(0.498039, 0.031373, 0.937255))
	)
	:CreateProduct("Packs", "Product", 0, ColorSequence.new(Color3.fromHex("9d0407"), Color3.fromHex("d14414")))
	:CreateProduct("Packs", "Product", 0, ColorSequence.new(Color3.fromHex("#acacac"), Color3.fromHex("#734332")))
	:Init()

Shop:SetPage("Keys")

Shop:Visible()
