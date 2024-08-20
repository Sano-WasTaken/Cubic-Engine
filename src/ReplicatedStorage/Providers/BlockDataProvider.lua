local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local BlockRenderEnum = require(ReplicatedStorage.Enums.BlockTypeEnum)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)

type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }
export type BlockData = {
	Textures: Textures?,
	BlockType: number,
	Unbreakable: boolean?,
	CustomProperties: {
		Mesh: BasePart?,
		Size: Vector3?,
		Material: Enum.Material,
		Color3: Color3,
	}?,
}

local BlockDataProvider: DataProvider.DataProvider<BlockData> = DataProvider.new(BlockEnum)

BlockDataProvider:InsertData(BlockEnum.Stone, {
	Textures = "rbxassetid://18640418536",
	BlockType = BlockRenderEnum.Block,
})
	:InsertData(BlockEnum.SpawnBlock, {
		Textures = "rbxassetid://18724299526",
		BlockType = BlockRenderEnum.Block,
		Unbreakable = true,
	})
	:InsertData(BlockEnum.Dirt, {
		Textures = "rbxassetid://18724462831",
		BlockType = BlockRenderEnum.Block,
	})
	:InsertData(BlockEnum.Grass, {
		Textures = {
			Top = "rbxassetid://18945124745",
			Bottom = "rbxassetid://18945125137",
			Front = "rbxassetid://18945124943",
			Back = "rbxassetid://18945124943",
			Right = "rbxassetid://18945124943",
			Left = "rbxassetid://18945124943",
		},
		BlockType = BlockRenderEnum.Block,
	})

return BlockDataProvider
