local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseController = require(script.Parent.BaseController)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Text = require(ReplicatedStorage.UI.Components.Text)
local children = Fusion.Children
local event = Fusion.OnEvent

--[[
Image = "rbxassetid://130406054362730",
ImageHovered = "rbxassetid://76456082035992",
ImagePressed = "rbxassetid://108276672955665",
]]

local ShopController = {
	Instance = nil :: Instance?,
	Pages = {},
	Page = nil :: Fusion.ScopedObject?,
}

function ShopController.CreatePage(self: Scope, name: string): Scope
	assert(self.Instance == nil, "Shop UI must not init !")
	assert(self.Pages[name] == nil, "Page already exist !")

	self.Pages[name] = {
		Products = {},
	}

	return self
end

type ProductType = "GamePass" | "Product"

type PageElement = {
	Type: ProductType,
	ID: number,
	Color: ColorSequence,
}

function ShopController:CreateProduct(name: string, type: ProductType, id: number, color: ColorSequence?): Scope
	assert(self.Instance == nil, "Shop UI must not init !")
	assert(self.Pages[name] ~= nil, "Page already exist !")

	table.insert(self.Pages[name].Products, {
		Type = type,
		Color = color or ColorSequence.new(Color3.new(1, 1, 1)),
		ID = id,
	})

	return self
end

function ShopController.GetProductInfo(_: Scope, id: number, type: ProductType)
	local info = MarketplaceService:GetProductInfo(id, Enum.InfoType[type])

	return info
end

function ShopController.createPages(self: Scope)
	local pages = {}

	local function createPageElements(page: { PageElement })
		local elements = {}

		for index, element in page do
			local btnScale = self:Value(1)

			local text = "BUY-"

			if element.ID ~= 0 then
				local productInfo = self:GetProductInfo(element.ID, element.Type)

				text ..= productInfo.PriceInRobux
			else
				text ..= "0"
			end

			elements[index] = self:New("ImageLabel")({
				Size = UDim2.fromOffset(103, 153),
				LayoutOrder = index,
				BackgroundTransparency = 1,
				Image = "rbxassetid://71375518160877",
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ScaleType = Enum.ScaleType.Fit,
				[children] = {
					self:New("UIGradient")({
						Color = element.Color,
						Rotation = -90,
					}),
					self:New("ImageButton")({
						Image = "rbxassetid://130406054362730",
						HoverImage = "rbxassetid://76456082035992",
						PressedImage = "rbxassetid://108276672955665",
						ResampleMode = Enum.ResamplerMode.Pixelated,
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 71, 16),
						Position = UDim2.new(0.5, 0, 1, -10),
						AnchorPoint = Vector2.new(0.5, 1),
						Size = UDim2.fromOffset(text:len() * 7 + (text:len() - 1) * 2 + 10, 21),
						[event("MouseEnter")] = function()
							btnScale:set(1.05)
						end,
						[event("MouseLeave")] = function()
							btnScale:set(1)
						end,
						[children] = {
							self:New("UIScale")({
								Scale = btnScale,
							}),
							Text(self, {
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

	for name, page in self.Pages do
		local uiPage = self:New("ScrollingFrame")({
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
				self:New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 3),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
				}),
				self:New("UIPadding")({
					PaddingBottom = UDim.new(0, 4),
				}),
				createPageElements(page.Products),
			},
		})

		pages[name] = uiPage
	end

	return pages
end

function ShopController.createPageSeletionBar(self: Scope)
	--assert(ShopController.Instance == nil, "Do not call Init twice!")

	local selectionBar = {}

	local size = 0

	for name, _ in self.Pages do
		local xSize = name:len() * 7 + (name:len() - 1) * 2 + 12

		local ui = self:New("ImageButton")({
			Name = name,
			Size = UDim2.fromOffset(xSize, 21),
			Position = UDim2.fromOffset(size, 0),
			ResampleMode = Enum.ResamplerMode.Pixelated,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(6, 6, 8, 7),
			BackgroundTransparency = 1,
			Image = self:Computed(function(use)
				return use(self.Page) == name and "rbxassetid://123355134162438" or "rbxassetid://130516409121801"
			end),
			[event("Activated")] = function()
				self.Page:set(name)
			end,
			[children] = {
				Text(self, { Text = name, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) }),
			},
		})
		table.insert(selectionBar, ui)

		size += xSize - 1
	end

	return selectionBar
end

function ShopController.Init(self: Scope)
	assert(self.Instance == nil, "Do not call Init twice!")

	local pages = self:createPages()

	self.Page = self:Value("")

	self.Instance = self:New("ScreenGui")({
		ResetOnSpawn = false,
		Name = "Shop",
		[children] = {
			self:New("Frame")({
				Transparency = 1,
				Size = UDim2.fromOffset(320, 182),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				[children] = {
					self:createPageSeletionBar(),
					self:Scale(3),
					self:New("ImageLabel")({
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.fromOffset(320, 165),
						Image = "rbxassetid://81669210308364",
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						ResampleMode = Enum.ResamplerMode.Pixelated,
						[children] = {
							self:New("UIGradient")({
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromHex("02029d")),
									ColorSequenceKeypoint.new(1, Color3.fromHex("#3c1678")),
								}),
								Rotation = 90,
							}),
							self:New("UIPadding")({
								PaddingBottom = UDim.new(0, 6),
								PaddingLeft = UDim.new(0, 3),
								PaddingRight = UDim.new(0, 2),
								PaddingTop = UDim.new(0, 2),
							}),
							self:Computed(function(use)
								return pages[use(self.Page)]
							end),
						},
					}),
				},
			}),
		},
	})
end

function ShopController.SetPage(self: Scope, name: string)
	assert(self.Instance ~= nil, "Must be init !")

	self.Page:set(name)
end

local scope = BaseController(ShopController)

type Scope = typeof(scope)

return scope
