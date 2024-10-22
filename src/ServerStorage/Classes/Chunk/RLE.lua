local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BufferManager = require(ReplicatedStorage.Classes.BufferManager)
local Waiter = require(ReplicatedStorage.Classes.Waiter)

local bufferFunction = BufferManager.bufferFunctions

type parameters = {
	occurencesSize: number,
	idSize: number,
	doWait: boolean?,
}

local function encode(buf: buffer, parameters: parameters): buffer
	local size = buffer.len(buf) / parameters.idSize

	local idSize = parameters.idSize
	local occSize = parameters.occurencesSize

	local totalSize = idSize + occSize

	local pointer, localId, occurences, encodingSize = 0, -1, 0, 0

	local waiter = Waiter.new()

	local encodedChunk = buffer.create(encodingSize)

	local readFId = bufferFunction[idSize]["u"].read

	local writeFId = bufferFunction[idSize]["u"].write
	local writeFOcc = bufferFunction[occSize]["u"].write

	while pointer < size do
		local id = readFId(buf, pointer * idSize)

		if id == localId then
			occurences += 1
		else
			if localId ~= -1 then
				local newBuf = buffer.create(encodingSize + totalSize)

				buffer.copy(newBuf, 0, encodedChunk, 0, encodingSize)

				writeFId(newBuf, encodingSize, localId)
				writeFOcc(newBuf, encodingSize + idSize, occurences)

				encodingSize += totalSize

				encodedChunk = newBuf
			end

			localId = id
			occurences = 1
		end

		if parameters.doWait then
			waiter:Update()
		end

		pointer += 1
	end

	local newBuf = buffer.create(encodingSize + totalSize)

	buffer.copy(newBuf, 0, encodedChunk, 0, encodingSize)

	writeFId(newBuf, encodingSize, localId)
	writeFOcc(newBuf, encodingSize + idSize, occurences)

	return newBuf
end

local function decode(buf: buffer, parameters: parameters, bufferSize: number): (buffer, number)
	local localPointer, occurences = 0, 0
	local id, occ, amount = 0, 0, 0

	local waiter = Waiter.new()

	local idSize = parameters.idSize
	local occSize = parameters.occurencesSize

	local totalSize = idSize + occSize

	local decodedBuffer = buffer.create(bufferSize * idSize)

	local occurenceSize = 2 ^ (2 * occSize)

	local readFId = bufferFunction[idSize]["u"].read
	local readFOcc = bufferFunction[occSize]["u"].read

	local writeFId = bufferFunction[idSize]["u"].write

	while bufferSize > occurences do
		occ = readFOcc(buf, localPointer + idSize)
		id = readFId(buf, localPointer)

		occ = occ == 0 and occurenceSize or occ

		if id ~= 0 then
			waiter:Start()

			for j = occurences, occurences + occ - 1 do
				writeFId(decodedBuffer, j * idSize, id)
			end

			waiter:Update()
			amount += occ
		end

		occurences += occ

		localPointer += totalSize
	end

	return decodedBuffer, amount
end

return {
	encode = encode,
	decode = decode,
}
