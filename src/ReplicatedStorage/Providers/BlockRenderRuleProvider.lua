local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockRenderEnum = require(ReplicatedStorage.Enums.BlockTypeEnum)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)

type TexturesRule = {
	Top: boolean,
	Bottom: boolean,
	Right: boolean,
	Left: boolean,
	Front: boolean,
	Back: boolean,
}

export type BlockRenderRule = {
	SelfBlock: TexturesRule,
	CanBeDeleted: boolean,
}

local BlockRenderRuleProvider: DataProvider.DataProvider<BlockRenderRule> = DataProvider.new(BlockRenderEnum)

BlockRenderRuleProvider:InsertData(BlockRenderEnum.Block, {
	SelfBlock = {
		Top = true,
		Bottom = true,
		Right = true,
		Left = true,
		Front = true,
		Back = true,
	},
	CanBeDeleted = true,
})
	:InsertData(BlockRenderEnum.Stairs, {
		SelfBlock = {
			Top = false,
			Bottom = true,
			Right = true,
			Left = true,
			Front = false,
			Back = true,
		},
		CanBeDeleted = false,
	})
	:InsertData(BlockRenderEnum.Glass, {
		SelfBlock = {
			Top = false,
			Bottom = false,
			Right = false,
			Left = false,
			Front = false,
			Back = false,
		},
		CanBeDeleted = false,
	})

return table.freeze(BlockRenderRuleProvider)
