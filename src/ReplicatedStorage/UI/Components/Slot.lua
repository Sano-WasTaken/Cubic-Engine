local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local children = Fusion.Children
local event = Fusion.OnEvent

type UsedAs<T> = Fusion.UsedAs<T>

type props = {
	Image: UsedAs<string>?,
	LayoutOrder: UsedAs<number>?,
	Activated: ((input: InputObject, clickCount: number) -> nil)?,
	Childrens: { Instance }?,
}

return function(scope: Fusion.Scope<typeof(Fusion)>, props: props)
	return scope:New("ImageButton")({
		Image = props.Image,
		Size = UDim2.fromOffset(32, 32),
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		ResampleMode = Enum.ResamplerMode.Pixelated,
		[children] = props.Childrens,
		[event("Activated")] = props.Activated,
	})
end
