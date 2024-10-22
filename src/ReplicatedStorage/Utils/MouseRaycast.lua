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

local function CreateSelectionBox(): SelectionBox
	local sb = Instance.new("SelectionBox")

	sb.LineThickness = 0.005
	sb.SurfaceTransparency = 1
	sb.Color3 = Color3.new()

	return sb
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
	CreateSelectionBox = CreateSelectionBox,
	GetOverlap = GetOverlap,
}
