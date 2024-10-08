local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
--local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local function GetMesh(id: number): ((BasePart | Model)?, Camera?)
	--assert(ItemEnum[id] ~= nil, "no item")

	local data = ItemDataProvider:GetData(id)

	if data == nil then
		return --Instance.new("Part")
	end

	local itemMesh
	local camera = Instance.new("Camera")

	if data:IsA("BlockItem") then
		itemMesh = data:GetClonedMesh()
		itemMesh.CFrame = CFrame.new(Vector3.zero)

		camera.CFrame = CFrame.lookAt(Vector3.new(1, 0.35, 1) * 3.5, Vector3.new(0, -0.1, 0))
	else
		local mesh = data:GetClonedMesh()

		itemMesh = Instance.new("Model")

		mesh.Parent = itemMesh

		itemMesh:ScaleTo(1.5)

		itemMesh:PivotTo(CFrame.new())

		camera.CFrame = CFrame.lookAt(Vector3.new(1, 0.75, 0.55) * 3.5, Vector3.new(0, 0.2, 0.2))
	end

	return itemMesh, camera
end

return GetMesh
