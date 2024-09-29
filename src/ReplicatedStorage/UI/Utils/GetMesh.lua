local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDataProvider = require(ReplicatedStorage.Providers.ItemDataProvider)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)

local function GetMesh(id: number): (BasePart?, Camera?)
	--assert(ItemEnum[id] ~= nil, "no item")

	local data = ItemDataProvider:GetData(id)

	if data == nil then
		return --Instance.new("Part")
	end

	local itemMesh = data:GetClonedMesh()
	local camera = Instance.new("Camera")

	itemMesh.Position = Vector3.zero

	camera.CFrame = CFrame.lookAt(Vector3.new(1, 0.35, 1) * 3.5, Vector3.new(0, -0.1, 0))

	return itemMesh, camera
end

return GetMesh
