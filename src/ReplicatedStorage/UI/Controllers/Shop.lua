local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Text = require(ReplicatedStorage.UI.Components.Text)
local children = Fusion.Children
local event = Fusion.OnEvent
local ScaleController = require(ReplicatedStorage.UI.Controllers.ScaleController)

--[[
Image = "rbxassetid://130406054362730",
ImageHovered = "rbxassetid://76456082035992",
ImagePressed = "rbxassetid://108276672955665",
]]

local ShopController = {
	Instance = nil :: Instance?,
	Scope = Fusion.scoped(Fusion),
	Pages = {},
	Page = nil :: Fusion.ScopedObject?,
}

function ShopController:CreatePage(name: string): typeof(ShopController)
	assert(ShopController.Instance == nil, "Shop UI must not init !")
	assert(ShopController.Pages[name] == nil, "Page already exist !")

	ShopController.Pages[name] = {
		Products = {},
	}

	return self
end

type PageElement = {
	Type: "DP" | "GP",
	ID: number,
	Color: ColorSequence,
}

function ShopController:CreateProduct(
	name: string,
	type: "DP" | "GP",
	id: number,
	color: ColorSequence?
): typeof(ShopController)
	assert(ShopController.Instance == nil, "Shop UI must not init !")
	assert(ShopController.Pages[name] ~= nil, "Page already exist !")

	table.insert(ShopController.Pages[name].Products, {
		Type = type,
		Color = color or ColorSequence.new(Color3.new(1, 1, 1)),
		ID = id,
	})

	return self
end

function ShopController:createPages()
	local scope = ShopController.Scope

	local pages = {}

	local function createPageElements(page: { PageElement })
		local elements = {}

		for index, element in page do
			local btnScale = scope:Value(1)

			local text = "1400"

			elements[index] = scope:New("ImageLabel")({
				Size = UDim2.fromOffset(103, 153),
				LayoutOrder = index,
				BackgroundTransparency = 1,
				Image = "rbxassetid://71375518160877",
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ScaleType = Enum.ScaleType.Fit,
				[children] = {
					scope:New("UIGradient")({
						Color = element.Color,
						Rotation = -90,
					}),
					scope:New("ImageButton")({
						Image = "rbxassetid://130406054362730",
						HoverImage = "rbxassetid://76456082035992",
						PressedImage = "rbxassetid://108276672955665",
						ResampleMode = Enum.ResamplerMode.Pixelated,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 71, 16),
						Position = UDim2.new(0.5, 0, 1, -10),
						AnchorPoint = Vector2.new(0.5, 1),
						Size = UDim2.fromOffset(text:len() * 11 + 10, 21),
						[event("MouseEnter")] = function()
							btnScale:set(1.05)
						end,
						[event("MouseLeave")] = function()
							btnScale:set(1)
						end,
						[children] = {
							scope:New("UIScale")({
								Scale = btnScale,
							}),
							Text(scope, {
								Text = text,
								Position = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.one / 2,
								--TextScale = 075.,
							}),
						},
					}),
				},
			})
		end

		return elements
	end

	for name, page in ShopController.Pages do
		local uiPage = scope:New("ScrollingFrame")({
			Name = name,
			Size = UDim2.fromScale(1, 1),
			ScrollBarImageTransparency = 0.5,
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			CanvasPosition = Vector2.new(0, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollingDirection = Enum.ScrollingDirection.X,
			[children] = {
				scope:New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 3),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
				}),
				scope:New("UIPadding")({
					PaddingBottom = UDim.new(0, 4),
				}),
				createPageElements(page.Products),
			},
		})

		pages[name] = uiPage
	end

	return pages
end

function ShopController:createPageSeletionBar()
	--assert(ShopController.Instance == nil, "Do not call Init twice!")
	local scope = ShopController.Scope

	local selectionBar = {}

	local size = 0

	for name, _ in ShopController.Pages do
		local xSize = name:len() * 7 + (name:len() - 1) * 2 + 12

		local ui = scope:New("ImageButton")({
			Name = name,
			Size = UDim2.fromOffset(xSize, 21),
			Position = UDim2.fromOffset(size, 0),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(6, 6, 8, 7),
			BackgroundTransparency = 1,
			Image = scope:Computed(function(use)
				return use(ShopController.Page) == name and "rbxassetid://123355134162438"
					or "rbxassetid://130516409121801"
			end),
			[event("Activated")] = function()
				ShopController.Page:set(name)
			end,
			[children] = {
				Text(scope, { Text = name, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }),
			},
		})
		table.insert(selectionBar, ui)

		size += xSize - 1
	end

	return selectionBar
end

function ShopController:Init()
	assert(ShopController.Instance == nil, "Do not call Init twice!")
	local scope = ShopController.Scope

	local scale = ScaleController(scope, 3)

	local pages = ShopController:createPages()

	ShopController.Page = scope:Value("")

	ShopController.Instance = scope:New("ScreenGui")({
		ResetOnSpawn = false,
		Name = "Shop",
		[children] = {
			scope:New("Frame")({
				Transparency = 1,
				Size = UDim2.fromOffset(320, 182),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				[children] = {
					ShopController:createPageSeletionBar(),
					scope:New("UIScale")({
						Scale = scale,
					}),
					scope:New("ImageLabel")({
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.fromOffset(320, 165),
						Image = "rbxassetid://81669210308364",
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						ResampleMode = Enum.ResamplerMode.Pixelated,
						[children] = {
							scope:New("UIGradient")({
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromHex("02029d")),
									ColorSequenceKeypoint.new(1, Color3.fromHex("#3c1678")),
								}),
								Rotation = 90,
							}),
							scope:New("UIPadding")({
								PaddingBottom = UDim.new(0, 6),
								PaddingLeft = UDim.new(0, 3),
								PaddingRight = UDim.new(0, 2),
								PaddingTop = UDim.new(0, 2),
							}),
							scope:Computed(function(use)
								return pages[use(ShopController.Page)]
							end),
						},
					}),
				},
			}),
		},
	})
end

function ShopController:SetPage(name: string)
	assert(ShopController.Instance ~= nil, "Must be init !")

	ShopController.Page:set(name)
end

function ShopController:Visible()
	assert(ShopController.Instance ~= nil, "Must be init !")

	ShopController.Instance.Parent = Players.LocalPlayer.PlayerGui
end

function ShopController:Invisible()
	assert(ShopController.Instance ~= nil, "Must be init !")

	ShopController.Instance.Parent = nil
end

return ShopController
