local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)
local BlockContent = require(ReplicatedStorage.Classes.BlockContent)

local Blocks = ReplicatedStorage.Contents.Blocks
local BlockDataProvider: DataProvider.DataProvider<BlockContent.BlockContent> = DataProvider.new(BlockEnum)

local function AppendContents(module: ModuleScript)
	local ok, result: BlockContent.BlockContent = pcall(require, module)

	if not ok then
		warn(result)
	else
		BlockDataProvider:InsertData(result:GetID(), result)
	end
end

for _, module in Blocks:GetChildren() do
	if module:IsA("ModuleScript") then
		AppendContents(module)
	end
end

return BlockDataProvider
