local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

-- buffered

-- tabled
--[[
{
	[1] = 0, -- id
	[2] = x, -- x position
	[3] = y, -- y position
	[4] = z, -- z position
	[5] = x, -- x orientation
	[6] = y, -- y orientation
	[7] = z, -- z orientation
}
]]

local Block = {}

export type IBlock = typeof(Block)

local function new(id: number): IBlock
	local self = setmetatable({
		--buffer = defaultBuffer:CloneObject(buf),
		ID = id,
	}, {
		__index = Block,
	})

	return self :: IBlock
end

function Block:_setId(id: number)
	--self.buffer:WriteData("ID", id)

	self.ID = id
end

function Block:SetPosition(x: number, y: number, z: number)
	--local buffer: BufferManager.buffering = self.buffer

	--buffer:WriteData("X", x):WriteData("Y", y):WriteData("Z", z)
	self.X = x
	self.Y = y
	self.Z = z

	return self
end

function Block:GetPosition(): (number, number, number)
	return self.X, self.Y, self.Z
end

function Block:SetOrientation(rx: number, ry: number, rz: number)
	--self.X = rx
	error("cannot touch it")

	--return self
end

function Block:GetOrientation() --: (number, number, number)
	error("cannot touch it")
	--local buffer: BufferManager.buffering = self.buffer

	--return buffer:ReadData("RX"), buffer:ReadData("RY"), buffer:ReadData("RZ")
end

function Block:GetID(): number
	--local buffer: BufferManager.buffering = self.buffer

	--return buffer:ReadData("ID")
	return self.ID
end

-- **Deprecated**: use `BlockContent` instead with associated lootTables
function Block:GetLoot(): number?
	local itemId = ItemEnum[BlockEnum[self:GetID()]]

	return itemId
end

function Block:GetBuffer() --: (BufferManager.buffering, buffer)
	error("cannot touch it")
	--return self.buffer, self.buffer:GetBuffer()
end

return {
	new = new,
	--BufferSize = defaultBuffer:GetSize(),
}
