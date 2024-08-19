local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local function CreateDraggedFrame(Position: UDim2, Size: UDim2, AnchorPoint: Vector2, Childs: Roact.Fragment?)
	return Roact.createElement("Frame", {
		Position = Position,
		Size = Size,
		AnchorPoint = AnchorPoint,
	}, {
		UIDragDetector = Roact.createElement("UIDragDetector", {}),
		Fragment = Childs,
	})
end

return {
	CreateDraggedFrame = CreateDraggedFrame,
}
