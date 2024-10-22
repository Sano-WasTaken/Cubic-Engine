local ChunkBitBuffer = {}

function ChunkBitBuffer.create12BitBuffer(size: number): buffer
	assert(size % 2 == 0, "The size must be even.")

	return buffer.create(size * 1.5)
end

function ChunkBitBuffer.encode12BitAtIndex(buf: buffer, value: number, index: number)
	assert(value >= 0 and value < 2 ^ 12, "The value must be include in [0; 4095].")

	local bitOffset = index * 12

	local byteOffset = bitOffset // 8
	local bitInByte = bitOffset % 8

	local currentValue = buffer.readu16(buf, byteOffset)

	local mask = bit32.bnot(bit32.lshift(0xFFF, bitInByte))
	currentValue = bit32.band(currentValue, mask)
	local newValue = bit32.bor(currentValue, bit32.lshift(value, bitInByte))

	buffer.writeu16(buf, byteOffset, newValue)
end

function ChunkBitBuffer.decode12BitAtIndex(buf: buffer, index: number)
	local bitOffset = index * 12

	local byteOffset = bitOffset // 8
	local bitInByte = bitOffset % 8

	local value = buffer.readu16(buf, byteOffset)

	return bit32.extract(value, bitInByte, 12) --bit32.band(bit32.rshift(value, bitInByte), 0xFFF)
end

return ChunkBitBuffer
