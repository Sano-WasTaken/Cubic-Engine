local ReplicatedStorage = game:GetService("ReplicatedStorage")

local meshes = ReplicatedStorage.Meshes

local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)

type Textures = string | { Top: string, Bottom: string, Right: string, Left: string, Front: string, Back: string }
export type ItemData = {
	BlockData: BlockDataProvider.BlockData?,
	Mesh: BasePart,
	MaxStackSize: number?,
}

type ItemDataProvider = DataProvider.DataProvider<ItemData>

local ItemDataProvider: ItemDataProvider = DataProvider.new(ItemEnum)

local part = Instance.new("Part")

for id, name in BlockEnum do
	local itemID = ItemEnum[name]

	if itemID then
		ItemDataProvider:InsertData(itemID, {
			BlockData = BlockDataProvider:GetData(id),
			MaxStackSize = 64,
			Mesh = part,
		})
	end
end

ItemDataProvider:InsertData(ItemEnum["Test_Pickaxe"], {
	Mesh = meshes["Pickaxe/1"],
	MaxStackSize = 1,
})

return ItemDataProvider
