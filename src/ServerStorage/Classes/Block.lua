local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)

local defaultBuffer = BufferManager.new()

defaultBuffer
	:SetDataInBuffer("X", 4, "i")
	:SetDataInBuffer("Y", 4, "i")
	:SetDataInBuffer("Z", 4, "i")
	:SetDataInBuffer("RX", 1, "u")
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
}

local function new(id: number?, buf: buffer?): IBlock
	local self = setmetatable({
		buffer = defaultBuffer:CloneObject(buf),
	}, {
		__index = Block,
	})

	if id then
		self.buffer:WriteData("ID", id)
	end

	return self :: IBlock
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

function Block:GetBuffer(): (BufferManager.buffering, buffer)
	return self.buffer, self.buffer:GetBuffer()
end

return {
	new = new,
	BufferSize = defaultBuffer:GetSize(),
}
