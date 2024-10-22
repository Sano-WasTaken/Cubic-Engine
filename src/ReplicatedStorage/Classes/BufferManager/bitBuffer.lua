--!strict

local BitBufferManager = {}

function BitBufferManager.create(size: number): buffer
	assert(size % 8 == 0, "The size must bu divisible by 8.")

	local buf = buffer.create(size / 8)

	return buf
end

export type BitBuffer = typeof(BitBufferManager) & { buffer: buffer }

function BitBufferManager.GetBitBufferSize(buf: buffer): number
	return buffer.len(buf) / 8
end

function BitBufferManager.WriteBit(buf: buffer, index: number, value: number)
	assert(value == 0 or value == 1, "The bit value must be 0 or 1 (boolean)")

	local byteIndex = index // 8
	local bitIndex = index % 8

	local byte = buffer.readu8(buf, byteIndex)

	byte = bit32.replace(byte, value, bitIndex, 1)

	buffer.writeu8(buf, byteIndex, byte)
end

function BitBufferManager.ReadBit(buf: buffer, index: number): number
	local byteIndex = index // 8
	local bitIndex = index % 8

	local byte = buffer.readu8(buf, byteIndex)

	return bit32.extract(byte, bitIndex, 1)
end

export type NBitBuffer = {
	buf: buffer,
	n: number,
	readF: typeof(buffer.readu8),
	writeF: typeof(buffer.writeu8),
}

local function getReadFunctionFromBits(bits: number): typeof(buffer.readu8)
	if bits < 5 then
		return buffer.readu8
	else
		return buffer.readu16
	end
end

local function getWriteFunctionFromBits(bits: number): typeof(buffer.writeu8)
	if bits < 5 then
		return buffer.writeu8
	else
		return buffer.writeu16
	end
end

function BitBufferManager.createNBitBuffer(n: number, sizeN: number, buf: buffer?): NBitBuffer
	return {
		n = n,
		buf = buf or BitBufferManager.create((n * sizeN)),
		readF = getReadFunctionFromBits(n),
		writeF = getWriteFunctionFromBits(n),
	}
end

function BitBufferManager.ReadNBit(buf: NBitBuffer, index: number): number
	local bitOffset = index * buf.n

	local readF = buf.readF

	local byteIndex = bitOffset // 8
	local bitIndex = bitOffset % 8

	local byte = readF(buf.buf, byteIndex)

	return bit32.extract(byte, bitIndex, buf.n)
end

function BitBufferManager.WriteNBit(buf: NBitBuffer, index: number, value: number)
	local bitOffset = index * buf.n

	local readF = buf.readF
	local writeF = buf.writeF

	local byteIndex = bitOffset // 8
	local bitIndex = bitOffset % 8

	local byte = readF(buf.buf, byteIndex)

	byte = bit32.replace(byte, value, bitIndex, buf.n)

	writeF(buf.buf, byteIndex, byte)
end

return BitBufferManager
