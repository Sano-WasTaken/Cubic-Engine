local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TileEntity = require(ServerStorage.Classes.TileEntity)
local DataProvider = require(ReplicatedStorage.Classes.DataProvider)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local Block = require(ServerStorage.Classes.Block)

type TileEntity = TileEntity.TileEntity

type ExecutionService = {
	Event: RBXScriptSignal,
	Init: (tileEntity: TileEntity) -> nil,
} | (tileEntity: TileEntity) -> nil

local Provider: DataProvider.DataProvider<{ Class: TileEntity, new: ({ any }) -> TileEntity }> =
	DataProvider.new(BlockEnum)

local Manager = {
	ExecutionServices = {
		default = {
			Event = RunService.Heartbeat,
			Init = function(tile: TileEntity)
				tile:Init()
			end,
		},
		justinit = function(tile: TileEntity)
			tile:Init()
		end,
	} :: { [string]: ExecutionService },
	TileEntities = {} :: { [string]: { TileEntity } },
}

--export type ExecutionServices = keyof<typeof(Manager.ExecutionServices)>

function Manager:_loadServices()
	local services = self.ExecutionServices

	for name, execution in services do
		if type(execution) == "table" then
			if execution.Event then
				self.TileEntities[name] = self.TileEntities[name] or {}

				local entities = self.TileEntities[name]

				execution.Event:Connect(function(...)
					for _, entity in entities do
						entity:Tick(...)
					end
				end)
			end
		end
	end
end

function Manager:_getInit(context: string): (tileEntity: TileEntity) -> nil
	local service = self.ExecutionServices[context]

	local init

	if type(service) == "table" then
		init = service.Init
	else
		init = service
	end

	return init
end

function Manager:_insert(tileEntity: TileEntity, context: string)
	self.TileEntities[context] = self.TileEntities[context] or {}

	self:_getInit(context)(tileEntity)

	table.insert(self.TileEntities[context], tileEntity)
end

function Manager:_remove(tileEntity: TileEntity, context: string)
	self.TileEntities[context] = self.TileEntities[context] or {}

	local index = table.find(self.TileEntities[context], tileEntity)

	self.TileEntities[context][index] = nil
end

function Manager:init()
	for _, module in ServerStorage.Contents.TileEntities:GetChildren() do
		if module:IsA("ModuleScript") then
			local ok, result: { Class: TileEntity, new: (any) -> TileEntity } = pcall(require, module)

			if ok then
				Provider:InsertData(result.Class:GetID(), result)
			else
				warn(result)
			end
		end
	end

	self:_loadServices()
end

function Manager:Insert(tileEntity: TileEntity)
	local context: string = tileEntity.ExecutionContext

	assert(self.ExecutionServices[context], string.format("%s is'nt a correct Executionner.", context))

	task.defer(self._insert, self, tileEntity, context)
end

function Manager:Delete(tileEntity: TileEntity)
	local context: string = tileEntity.ExecutionContext

	self:_remove(tileEntity, context)
end

function Manager:GetTileEntityFromBlock(block: Block.IBlock, content: {}): TileEntity
	local id = block:GetID()

	local TileEntityClass = Provider:GetData(id)

	if TileEntityClass then
		local x, y, z = block:GetPosition()

		content.Position = { x, y, z }

		return TileEntityClass.new(content)
	end
end

Manager:init()

return {
	Manager = Manager,
	Provider = Provider,
}
