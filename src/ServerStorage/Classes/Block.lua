local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Facing = require(ServerStorage.Components.Facing)
local TileEntity = require(script.Parent.TileEntity)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local Block = {}

export type IBlock = typeof(Block)

local function new(id: number, entity: {}?): IBlock
	local self = setmetatable({
		entity = entity,
		ID = id,
	}, {
		__index = Block,
	})

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

function Block:SetFacing(facing: Facing.Facing): IBlock
	local entity: TileEntity.TileEntity = self:GetEntity()

	if entity then
		local facingComp: Facing.FacingComponent? = entity:GetComponent("Facing") :: any

		if facingComp then
			facingComp:SetFacing(facing)
		else
			warn("no facing !")
		end
	else
		warn("no entity !")
	end

	return self
end

function Block:GetFacing(): Facing.Facing
	local entity: TileEntity.TileEntity = self:GetEntity()

	if entity then
		local facing: Facing.FacingComponent? = entity:GetComponent("Facing") :: any

		if facing then
			return facing:GetFacing()
		end
	end

	return "NORTH"
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
