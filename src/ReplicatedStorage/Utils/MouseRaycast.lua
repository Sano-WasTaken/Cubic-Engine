local Debris = game:GetService("Debris")

local currentCamera = workspace.CurrentCamera

local debugging = false

local function GetRay(x: number, y: number): Ray
	return currentCamera:ScreenPointToRay(x, y)
end

local function Raycast(ray: Ray, depth: number, exclude: { Instance } | Model): RaycastResult?
	local params = RaycastParams.new()

	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclude

	return workspace:Raycast(ray.Origin, ray.Direction * depth, params)
end

local function CreateHighlight(): Highlight
	local ss = Instance.new("Highlight")

	ss.FillTransparency = 1
	ss.OutlineTransparency = 0.3
	ss.OutlineColor = Color3.new(0.262745, 0.262745, 0.262745)
	ss.Enabled = true

	return ss
end

local function GetOverlap(Position: Vector3): boolean
	local parts = workspace:GetPartBoundsInBox(CFrame.new(Position), Vector3.one)

	if debugging then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Size = Vector3.one
		part.Position = Position
		part.Transparency = 0.5
		part.Color = Color3.new(1, 0, 0)
		part.Parent = workspace

		Debris:AddItem(part, 5)
	end

	return #parts == 0
end

return {
	GetRay = GetRay,
	Raycast = Raycast,
	CreateHighlight = CreateHighlight,
	GetOverlap = GetOverlap,
}
