local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IconsController = require(ReplicatedStorage.UI.Controllers.IconsController)
local ShopController = require(ReplicatedStorage.UI.Controllers.ShopController)

ShopController:CreatePage("Support")
	:CreateProduct(
		"Support",
		"GamePass",
		938237969,
		ColorSequence.new(Color3.fromHex("#066aa8"), Color3.fromHex("#1446d1"))
	)
	:CreatePage("Donations")
	:CreateProduct(
		"Donations",
		"Product",
		2147509557,
		ColorSequence.new(Color3.fromHex("#066aa8"), Color3.fromHex("#1446d1"))
	)
	:CreateProduct(
		"Donations",
		"Product",
		2147509819,
		ColorSequence.new(Color3.fromHex("#a82406"), Color3.fromHex("#d11440"))
	)
	:Init()

ShopController:SetPage("Support")

IconsController:AddButtonIcon("rbxassetid://96354796118569", function(_: InputObject, _: number): nil
	print("activate shop")

	ShopController:Toggle()

	return
end):Init()

IconsController:Visible()
