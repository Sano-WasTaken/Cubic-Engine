local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local _, Block, WorldManager = BlockContent.Class:GetServices()

local Grass = {
	Id = BlockEnum.Grass,
	Textures = {
		Top = "rbxassetid://18945124745",
		Bottom = "rbxassetid://18945125137",
		Front = "rbxassetid://18945124943",
		Back = "rbxassetid://18945124943",
		Right = "rbxassetid://18945124943",
		Left = "rbxassetid://18945124943",
	},
}

Grass = BlockContent.Class:extends(Grass)

function Grass:UpdateContent(block: BlockContent.Block, _)
	BlockContent.assertContext()

	local x, y, z = block:GetPosition()

	local upNeighbor = WorldManager:GetNeighbor(x, y, z, Vector3.new(0, 1, 0))

	if upNeighbor then
		WorldManager:SwapId(block, BlockEnum.Dirt)
	end
end

return Grass
