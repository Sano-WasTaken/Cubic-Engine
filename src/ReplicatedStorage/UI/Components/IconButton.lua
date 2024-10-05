local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local event = Fusion.OnEvent

type props = {
	IconId: Fusion.UsedAs<string>,
	Order: Fusion.UsedAs<number>?,
	Activated: ((input: InputObject, clickCount: number) -> nil)?,
}

local function createIcon(scope: Fusion.Scope<typeof(Fusion)>, props: props)
	return scope:New("ImageButton")({
		Image = props.IconId,
		ResampleMode = Enum.ResamplerMode.Pixelated,
		BackgroundTransparency = 1,
		LayoutOrder = props.Order,
		Size = UDim2.fromOffset(32, 32),
		[event("Activated")] = props.Activated,
	})
end

return createIcon
