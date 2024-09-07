local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)
local ItemEnum = require(ReplicatedStorage.Enums.ItemEnum)
local BlockEnum = require(ReplicatedStorage.Enums.BlockEnum)

local defaultBuffer = BufferManager.new()

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

defaultBuffer
	:SetDataInBuffer("X", 4, "i")
	:SetDataInBuffer("Y", 4, "i")
	:SetDataInBuffer("Z", 4, "i")
	:SetDataInBuffer("RX", 1, "u") -- 1, 2, 3, 4
	:SetDataInBuffer("RY", 1, "u")
	:SetDataInBuffer("RZ", 1, "u")
	:SetDataInBuffer("ID", 2, "u")

local Block = {}

export type IBlock = {
	SetPosition: (self: IBlock, x: number, y: number, z: number) -> IBlock,
	GetPosition: (self: IBlock) -> (number, number, number),
	GetOrientation: (self: IBlock) -> (number, number, number),
	SetOrientation: (self: IBlock, rx: number, ry: number, rz: number) -> IBlock,
	GetBuffer: (self: IBlock) -> (BufferManager.buffering, buffer),
	GetID: (self: IBlock) -> number,
	GetLoot: (self: IBlock) -> number?,
}

local function new(id: number?, buf: buffer?): IBlock
	local self = setmetatable({
		buffer = defaultBuffer:CloneObject(buf),
	}, {
		__index = Block,
	})

	if id then
		self.buffer:WriteData("ID", id) -- id % 2^(8*2)
	end

	return self :: IBlock
end

function Block:_setId(id: number)
	self.buffer:WriteData("ID", id)
end

function Block:SetPosition(x: number, y: number, z: number)
	local buffer: BufferManager.buffering = self.buffer

	buffer:WriteData("X", x):WriteData("Y", y):WriteData("Z", z)

	return self
end

function Block:GetPosition(): (number, number, number)
	local buffer: BufferManager.buffering = self.buffer

	return buffer:ReadData("X"), buffer:ReadData("Y"), buffer:ReadData("Z")
end

function Block:SetOrientation(rx: number, ry: number, rz: number)
	local buffer: BufferManager.buffering = self.buffer

	buffer:WriteData("RX", rx):WriteData("RY", ry):WriteData("RZ", rz)

	return self
end

function Block:GetOrientation(): (number, number, number)
	local buffer: BufferManager.buffering = self.buffer

	return buffer:ReadData("RX"), buffer:ReadData("RY"), buffer:ReadData("RZ")
end

function Block:GetID(): number
	local buffer: BufferManager.buffering = self.buffer

	return buffer:ReadData("ID")
end

-- **Deprecated**: use `BlockContent` instead with associated lootTables
function Block:GetLoot(): number?
	local itemId = ItemEnum[BlockEnum[self:GetID()]]

	return itemId
end

function Block:GetBuffer(): (BufferManager.buffering, buffer)
	return self.buffer, self.buffer:GetBuffer()
end

return {
	new = new,
	BufferSize = defaultBuffer:GetSize(),
}
