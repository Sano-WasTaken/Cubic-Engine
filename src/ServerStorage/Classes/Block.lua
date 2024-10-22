local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BlockContent = require(ReplicatedStorage.Classes.BlockContent)
local TileEntitiesManager = require(ServerStorage.Managers.TileEntitiesManager)
local TileEntity = require(script.Parent.TileEntity)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)
local BlockDataProvider = require(ReplicatedStorage.Providers.BlockDataProvider)

local Block = {}

export type IBlock = typeof(Block) & {
	entity: {},
	facing: number,
	inverted: boolean,
	active: boolean,
	ID: number,
}

local function new(id: number, entity: {}?): IBlock
	local self = setmetatable({
		entity = entity,
		facing = 0,
		inverted = false,
		active = false,
		ID = id,
	}, {
		__index = Block,
	})

	local entityData = TileEntitiesManager.Provider:GetData(id)

	if entity == nil and entityData then
		self.entity = entityData:create()
	end

	return self :: IBlock
end

function Block:_setId(id: number)
	self.ID = id
end

function Block:SetPosition(x: number, y: number, z: number): IBlock
	self.X = x
	self.Y = y
	self.Z = z

	return self
end

function Block:GetPosition(): (number, number, number)
	return self.X or 0, self.Y or 0, self.Z or 0
end

function Block:GetEntity(): TileEntity.TileEntity?
	return self.entity
end

export type Facing = "NORTH" | "SOUTH" | "EAST" | "WEST"

local Facings = {
	[0] = "NORTH", -- Basic facing
	[1] = "SOUTH",
	[2] = "EAST",
	[3] = "WEST",
}

function Block:SetFacing(facing: Facing): IBlock
	local content: BlockContent.BlockContent = self:GetContent()

	if content.Faced then
		local facingId = table.find(Facings, facing)

		self.facing = facingId or 0
	end

	return self
end

function Block:SetInverted(inverted: boolean): IBlock
	local content: BlockContent.BlockContent = self:GetContent()

	if content.Inverted then
		self.inverted = inverted
	end

	return self
end

function Block:GetInverted(): boolean
	return self.inverted
end

function Block:GetContent(): BlockContent.BlockContent
	return BlockDataProvider:GetData(self.ID)
end

function Block:GetFacing(): Facing
	return Facings[self.facing]
end

function Block:GetID(): number
	return self.ID
end

-- **Deprecated**: use `BlockContent` instead with associated lootTables
function Block:GetLoot(): number?
	local itemId = ItemEnum[BlockEnum[self:GetID()]]

	return itemId
end

return {
	new = new,
	--BufferSize = defaultBuffer:GetSize(),
}
