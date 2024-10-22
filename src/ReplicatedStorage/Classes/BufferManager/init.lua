--!strict
--!native

--[[
            MADE BY SANO_WASTAKEN
]]

export type valueType = "u" | "f" | "i" | "str"

type dataProvider = { name: string, size: number, type: valueType }

type functions = {
	read: (b: buffer, o: number) -> (),
	write: (b: buffer, o: number, v: number) -> (),
}

type strFunctions = {
	read: (b: buffer, offset: number, count: number) -> string,
	write: (b: buffer, offset: number, value: string, count: number?) -> (),
}

local functions: { [number]: { [valueType?]: functions }, ["str"]: strFunctions } = {
	[1] = {
		["u"] = {
			read = buffer.readu8,
			write = buffer.writeu8,
		},
		["i"] = {
			read = buffer.readi8,
			write = buffer.writei8,
		},
	},
	[2] = {
		["u"] = {
			read = buffer.readu16,
			write = buffer.writeu16,
		},
		["i"] = {
			read = buffer.readi16,
			write = buffer.writei16,
		},
	},
	[4] = {
		["u"] = {
			read = buffer.readu32,
			write = buffer.writeu32,
		},
		["i"] = {
			read = buffer.readi32,
			write = buffer.writei32,
		},
		["f"] = {
			read = buffer.readf32,
			write = buffer.writef32,
		},
	},
	[8] = {
		["f"] = {
			read = buffer.readf64,
			write = buffer.writef64,
		},
	},
	["str"] = {
		read = buffer.readstring,
		write = buffer.writestring,
	},
}

local function getReadFunction(size: number, type: valueType, isString: boolean)
	assert((functions[size] and functions[size][type]) or isString, "size not supported")

	return (not isString) and functions[size][type].read or functions["str"].read
end

local function getWriteFunction(size: number, type: valueType, isString: boolean)
	assert((functions[size] and functions[size][type]) or isString, "size not supported")

	return (not isString) and functions[size][type].write or functions["str"].write
end

local function verifyData(dataProvider: { name: string, size: number, type: valueType }, data: any)
	if dataProvider.type == "str" and string.len(data) > dataProvider.size then
		error(`{data} is to lenght for the size of {dataProvider.size}`)
	end
end

local buffering = {}

local function new(buf: buffer?, size: number?, container: { dataProvider }?)
	local self = setmetatable({
		container = container or {} :: { dataProvider },
		buffer = buf or buffer.create(size or 0),
		locked = false,
	}, {
		__index = buffering,
	})

	return self
end

export type buffering = typeof(new())

--[[
register data for the buffer (auto resize the buffer)

use a size of **1, 2, 4, 8** for number and **any** size for strings.
]]
function buffering:SetDataInBuffer(name: string, size: number, type: valueType)
	assert(not self.locked, "manager locked")

	local newData = {
		name = name,
		size = size,
		type = type,
	}

	table.insert(self.container, newData)

	if buffer.len(self.buffer) ~= self:GetSize() then
		local newBuf = buffer.create(self:GetSize())
		buffer.copy(newBuf, 0, self.buffer)
		self.buffer = newBuf
	end

	return self :: buffering
end

--[[
Write data directly in the buffer by providing a name and the data.
]]
function buffering.WriteData(self: buffering, name: string, data: number | string)
	local scope = 0
	local address = 0

	for i = 1, table.maxn(self.container) do
		if self.container[i] == nil then
			continue
		end

		local needle = self.container[i]

		if needle.name == name then
			scope = i
			break
		end

		address += needle.size
	end

	assert(scope ~= 0, "data not found")

	local dataProvider = self.container[scope]

	verifyData(dataProvider, data)

	local writeF =
		getWriteFunction(dataProvider.size, dataProvider.type, dataProvider.type == "str") :: (buffer, number, number | string) -> nil

	writeF(self.buffer, address, data)

	return self
end

--[[
Read data directly in the buffer by providing the name
]]
function buffering.ReadData(self: buffering, name: string): number | string
	local scope = 0
	local address = 0

	for i = 1, table.maxn(self.container) do
		if self.container[i] == nil then
			continue
		end

		local needle = self.container[i]

		if needle.name == name then
			scope = i
			break
		end

		address += needle.size
	end

	assert(scope ~= 0, "data not found")

	local dataProvider = self.container[scope]

	local readF =
		getReadFunction(dataProvider.size, dataProvider.type, dataProvider.type == "str") :: (buffer, number, number?) -> number | string

	return readF(self.buffer, address, dataProvider.size)
end

--[[
Get the correct size of all the data in the Buffer.

It not take directly the lenght of it.
]]
function buffering.GetSize(self: buffering)
	local size = 0

	for _, i in self.container do
		size += i.size
	end

	return size
end

--[[
Clone the buffer with the data in it
]]
function buffering:CloneBuffer(): (buffer, { dataProvider })
	local copy = buffer.create(buffer.len(self.buffer))

	buffer.copy(copy, 0, self.buffer)

	return copy, self.container
end

--[[
Gives you a copy of the buffer with the provided data provider but locked (you can't :SetDataProvider() if it's locked)

**/!\ IT DO NOT COPY THE DATA PROVIDER CONTAINER**
]]
function buffering:CloneObject(buf: buffer?): buffering
	local copy: buffer = nil

	if buf then
		assert(buffer.len(buf) == self:GetSize(), "the buffer has not the proper size...")
		copy = buf
	else
		copy = self:CloneBuffer()
	end

	local newBuf = new(copy, 0, self.container)

	newBuf.locked = true

	return newBuf
end

--[[
Get the buffer.
]]
function buffering:GetBuffer(): (buffer, { dataProvider })
	return self.buffer, self.container
end

--[[
Destroy the object.
]]
function buffering:Destroy()
	self = {}
	setmetatable(self, nil)
end

return {
	new = new,
	bufferFunctions = functions,
	bitBuffer = require(script.bitBuffer),
	chunkBuffer = require(script.chunkBuffer),
}
