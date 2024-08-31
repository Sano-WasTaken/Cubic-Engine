local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)
local ItemContent = require(ReplicatedStorage.Classes.ItemContent)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local BlockItemContent = require(ReplicatedStorage.Classes.BlockItemContent)

local items = ReplicatedStorage.Contents.Items

type ItemDataProvider = DataProvider.DataProvider<ItemContent.ItemContent>

local ItemDataProvider: ItemDataProvider = DataProvider.new(ItemEnum)

local function AppendContents(module: ModuleScript)
	local ok, result: ItemContent.ItemContent = pcall(require, module)

	if not ok then
		warn(result)
	else
		ItemDataProvider:InsertData(result:GetID(), result)
	end
end

for _, name in BlockEnum do
	local itemID = ItemEnum[name]

	if itemID then
		local blockItem = BlockItemContent:extends({ Id = itemID })

		ItemDataProvider:InsertData(blockItem:GetID(), blockItem)
	end
end

for _, module in items:GetDescendants() do
	if module:IsA("ModuleScript") then
		AppendContents(module)
	end
end

return ItemDataProvider
